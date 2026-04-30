// mcp_server.js
// ─── AWS Order System — Production MCP Server ────────────────────────────────
//
// Transport is chosen in this priority order:
//   1. CLI flag  --http  or  --stdio          (highest priority)
//   2. MCP_TRANSPORT env var in mcp/.env
//   3. Default: "http"   ← web UI needs HTTP; stdio is opt-in for Inspector
//
// ┌─────────────────────────────────────────────────────────────┐
// │  For the web UI (normal use):                               │
// │    npm start          ← uses MCP_TRANSPORT from .env (http) │
// │    npm run start:http ← explicit --http flag                │
// │                                                             │
// │  For MCP Inspector only:                                    │
// │    npm run mcp:inspect                                      │
// │    node mcp_server.js --stdio                               │
// └─────────────────────────────────────────────────────────────┘

"use strict";

const express = require("express");
const { McpServer }            = require("@modelcontextprotocol/sdk/server/mcp.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");
const { z }                    = require("zod");

const {
  getRuntimeConfig,
  placeOrder,
  getOrder,
  getOrderStatusPayload,
  buildSummary,
  answerCustomerQuery,
} = require("./order_service");
// ↑ order_service loads mcp/.env at require-time via loadEnvFile()

// ─────────────────────────────────────────────────────────────────────────────
// RESOLVE TRANSPORT
// CLI flags override .env. Default is "http" so web UI works out of the box.
// ─────────────────────────────────────────────────────────────────────────────
function resolveTransport() {
  const args = process.argv.slice(2);
  if (args.includes("--http"))  return "http";
  if (args.includes("--stdio")) return "stdio";
  // fall back to .env value (already loaded by order_service)
  const envVal = (process.env.MCP_TRANSPORT || "http").toLowerCase().trim();
  return envVal === "stdio" ? "stdio" : "http";
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVER METADATA
// ─────────────────────────────────────────────────────────────────────────────
const SERVER_INFO = { name: "aws-order-system-mcp", version: "2.0.0" };

// ─────────────────────────────────────────────────────────────────────────────
// ZOD SCHEMAS  (used by SDK stdio transport for auto-validation)
// ─────────────────────────────────────────────────────────────────────────────
const PlaceOrderSchema = {
  customer_name:  z.string().min(1).describe("Full name of the customer"),
  product_id:     z.string().min(1).describe("Product SKU or identifier"),
  quantity:       z.number().int().min(1).describe("Number of units to order"),
  price_per_unit: z.number().min(0).optional().describe("Price per unit in USD (optional)"),
};

const OrderIdSchema = {
  orderId: z.string().min(1).describe("The order_id returned when the order was placed"),
};

const AnswerQuerySchema = {
  orderId:  z.string().min(1).describe("The order_id the customer is asking about"),
  question: z.string().min(1).describe("The customer's question in plain text"),
};

// ─────────────────────────────────────────────────────────────────────────────
// SHARED TOOL LOGIC
// One implementation — called by both transports to avoid duplication.
// ─────────────────────────────────────────────────────────────────────────────
async function runTool(name, args = {}) {
  switch (name) {

    case "place_order": {
      const { customer_name, product_id, quantity, price_per_unit = 0 } = args;
      if (!customer_name || !product_id || !quantity) {
        throw Object.assign(new Error("customer_name, product_id, and quantity are required."), { httpCode: 400 });
      }
      const { data, statusCode } = await placeOrder({
        customer_name,
        product_id,
        quantity:       Number(quantity),
        price_per_unit: Number(price_per_unit),
      });
      return {
        text:      `Order placed. HTTP ${statusCode}. Order ID: ${data?.order_id ?? "pending"}.\n\n${JSON.stringify(data, null, 2)}`,
        structured: { statusCode, response: data },
      };
    }

    case "get_order": {
      const order = await getOrder(args.orderId);
      return {
        text:      JSON.stringify(order, null, 2),
        structured: { order },
      };
    }

    case "get_order_status": {
      const order  = await getOrder(args.orderId);
      const status = getOrderStatusPayload(order);
      const parts  = [`Order #${args.orderId} — Status: ${status.status}`];
      if (status.payment_status)  parts.push(`Payment: ${status.payment_status}`);
      if (status.shipping_status) parts.push(`Shipping: ${status.shipping_status}`);
      return {
        text:      parts.join(" | "),
        structured: status,
      };
    }

    case "summarize_order": {
      const order   = await getOrder(args.orderId);
      const summary = buildSummary(order);
      return {
        text:      summary,
        structured: { summary },
      };
    }

    case "answer_customer_query": {
      const order  = await getOrder(args.orderId);
      const answer = await answerCustomerQuery(order, args.question);
      return {
        text:      answer,
        structured: { answer },
      };
    }

    case "get_workshop_config": {
      const config = getRuntimeConfig();
      return {
        text:      JSON.stringify(config, null, 2),
        structured: config,
      };
    }

    default: {
      throw Object.assign(new Error(`Unknown tool: "${name}"`), { httpCode: 404 });
    }
  }
}

// MCP SDK result shape
const mcpResult  = (text) => ({ content: [{ type: "text", text: String(text) }] });
// HTTP result shape
const httpResult = (text, structured) => ({ content: [{ type: "text", text: String(text) }], structuredContent: structured });

// ═════════════════════════════════════════════════════════════════════════════
// TRANSPORT A — stdio  (MCP Inspector / Claude Desktop)
// Uses the official SDK — handles all JSON-RPC framing automatically.
// ═════════════════════════════════════════════════════════════════════════════
async function runStdioServer() {
  console.error("[mcp] Transport: stdio");
  console.error("[mcp] Start Inspector: set DANGEROUSLY_OMIT_AUTH=true && npx @modelcontextprotocol/inspector node mcp_server.js --stdio");

  const server = new McpServer(SERVER_INFO);

  server.tool("place_order",          "Create a new order through AWS API Gateway → SQS → Lambda.",               PlaceOrderSchema,   async (a) => mcpResult((await runTool("place_order",          a)).text));
  server.tool("get_order",            "Fetch the full order record from DynamoDB by order ID.",                   OrderIdSchema,      async (a) => mcpResult((await runTool("get_order",            a)).text));
  server.tool("get_order_status",     "Return current status of an order (RECEIVED → PROCESSING → PROCESSED).",  OrderIdSchema,      async (a) => mcpResult((await runTool("get_order_status",     a)).text));
  server.tool("summarize_order",      "Generate a human-readable summary of an order.",                           OrderIdSchema,      async (a) => mcpResult((await runTool("summarize_order",      a)).text));
  server.tool("answer_customer_query","Answer a customer question using Gemini 2.5 Flash.",                       AnswerQuerySchema,  async (a) => mcpResult((await runTool("answer_customer_query", a)).text));
  server.tool("get_workshop_config",  "Return active runtime configuration.",                                     {},                 async ()  => mcpResult((await runTool("get_workshop_config",  {})).text));

  const transport = new StdioServerTransport();
  await server.connect(transport);

  console.error("[mcp] stdio ready. Waiting for JSON-RPC messages…");
}

// ═════════════════════════════════════════════════════════════════════════════
// TRANSPORT B — HTTP Express  (web UI at http://localhost:3001)
// ═════════════════════════════════════════════════════════════════════════════
async function runHttpServer() {
  const host = (process.env.MCP_HTTP_HOST || "127.0.0.1").trim();
  const port = Number(process.env.MCP_HTTP_PORT || 8000);

  const app = express();
  app.use(express.json());

  // CORS — allow web UI origin
  app.use((req, res, next) => {
    res.setHeader("Access-Control-Allow-Origin",  process.env.MCP_ALLOWED_ORIGIN || "*");
    res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
    res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
    if (req.method === "OPTIONS") return res.status(204).end();
    next();
  });

  // ── GET /health ────────────────────────────────────────────────────────────
  app.get("/health", (_req, res) => {
    const cfg = getRuntimeConfig();
    res.json({
      status:           "ok",
      serverInfo:       SERVER_INFO,
      geminiConfigured: cfg.geminiConfigured,
      awsRegion:        cfg.awsRegion,
      ordersTable:      cfg.ordersTable,
    });
  });

  // ── GET /mcp/tools ─────────────────────────────────────────────────────────
  app.get("/mcp/tools", (_req, res) => {
    res.json({ serverInfo: SERVER_INFO, tools: HTTP_TOOL_LIST });
  });

  // ── POST /mcp/call  { name, arguments } ───────────────────────────────────
  app.post("/mcp/call", async (req, res) => {
    const { name, arguments: args = {} } = req.body || {};

    if (!name) {
      return res.status(400).json({ ok: false, error: { message: "Request body must include 'name'." } });
    }

    try {
      const { text, structured } = await runTool(name, args);
      return res.json({ ok: true, result: httpResult(text, structured) });
    } catch (err) {
      const httpCode = err.httpCode || (err.statusCode === 404 ? 404 : 500);
      console.error(`[mcp] tool "${name}" error:`, err.message);
      return res.status(httpCode).json({ ok: false, error: { message: err.message } });
    }
  });

  // ── Start listening ────────────────────────────────────────────────────────
  await new Promise((resolve, reject) => {
    app.listen(port, host, (err) => {
      if (err) return reject(err);
      console.error(`[mcp] Transport: HTTP`);
      console.error(`[mcp] Listening on http://${host}:${port}`);
      console.error(`[mcp]   Health:     GET  http://${host}:${port}/health`);
      console.error(`[mcp]   List tools: GET  http://${host}:${port}/mcp/tools`);
      console.error(`[mcp]   Call tool:  POST http://${host}:${port}/mcp/call`);
      resolve();
    });
  });
}

// Human-readable JSON-schema tool list for GET /mcp/tools
const HTTP_TOOL_LIST = [
  { name: "place_order",           description: "Create a new order through AWS API Gateway → SQS → Lambda.",              inputSchema: { type: "object", required: ["customer_name","product_id","quantity"], properties: { customer_name: { type: "string" }, product_id: { type: "string" }, quantity: { type: "integer", minimum: 1 }, price_per_unit: { type: "number" } } } },
  { name: "get_order",             description: "Fetch full order record from DynamoDB.",                                   inputSchema: { type: "object", required: ["orderId"], properties: { orderId: { type: "string" } } } },
  { name: "get_order_status",      description: "Return current status (RECEIVED → PROCESSING → PROCESSED).",              inputSchema: { type: "object", required: ["orderId"], properties: { orderId: { type: "string" } } } },
  { name: "summarize_order",       description: "Generate a human-readable summary of an order.",                          inputSchema: { type: "object", required: ["orderId"], properties: { orderId: { type: "string" } } } },
  { name: "answer_customer_query", description: "Answer a customer question using Gemini 2.5 Flash.",                     inputSchema: { type: "object", required: ["orderId","question"], properties: { orderId: { type: "string" }, question: { type: "string" } } } },
  { name: "get_workshop_config",   description: "Return active runtime configuration.",                                    inputSchema: { type: "object", properties: {} } },
];

// ═════════════════════════════════════════════════════════════════════════════
// ENTRY POINT
// ═════════════════════════════════════════════════════════════════════════════
(async () => {
  try {
    const transport = resolveTransport();
    console.error(`[mcp] aws-order-system-mcp v${SERVER_INFO.version} starting (transport: ${transport})`);

    if (transport === "stdio") {
      await runStdioServer();
    } else {
      await runHttpServer();
    }
  } catch (err) {
    console.error("[mcp] Fatal startup error:", err.message);
    console.error(err.stack);
    process.exit(1);
  }
})();
