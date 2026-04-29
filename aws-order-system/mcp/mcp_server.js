// mcp_server.js
// ─── AWS Order System — Production MCP Server ────────────────────────────────
//
// Two transports are supported via MCP_TRANSPORT env var:
//
//   MCP_TRANSPORT=stdio  (default)
//     → Uses the official SDK StdioServerTransport.
//     → Works with MCP Inspector, Claude Desktop, and any stdio MCP client.
//     → Run:     node mcp_server.js
//     → Inspect: npx @modelcontextprotocol/inspector node mcp_server.js
//                (set DANGEROUSLY_OMIT_AUTH=true to skip auth prompt)
//
//   MCP_TRANSPORT=http
//     → Express REST server at /mcp/tools and /mcp/call
//     → Used by the web UI (web/server.js)
//     → Run:  node mcp_server.js --http
//             or  MCP_TRANSPORT=http node mcp_server.js

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

// ─────────────────────────────────────────────────────────────────────────────
// SERVER METADATA
// ─────────────────────────────────────────────────────────────────────────────
const SERVER_INFO = {
  name:    "aws-order-system-mcp",
  version: "2.0.0",
};

// ─────────────────────────────────────────────────────────────────────────────
// TOOL SCHEMAS  (Zod — used by SDK for auto-validation + Inspector schema gen)
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
// TOOL RESULT HELPER
// ─────────────────────────────────────────────────────────────────────────────
function textResult(text) {
  return { content: [{ type: "text", text: String(text) }] };
}

// ─────────────────────────────────────────────────────────────────────────────
// BUILD McpServer  (SDK-based — handles all JSON-RPC framing automatically)
// ─────────────────────────────────────────────────────────────────────────────
function buildMcpServer() {
  const server = new McpServer(SERVER_INFO);

  // ── place_order ────────────────────────────────────────────────────────────
  server.tool(
    "place_order",
    "Create a new order through the AWS API Gateway → SQS → Lambda pipeline.",
    PlaceOrderSchema,
    async ({ customer_name, product_id, quantity, price_per_unit = 0 }) => {
      const { data, statusCode } = await placeOrder({
        customer_name,
        product_id,
        quantity,
        price_per_unit,
      });
      return textResult(
        `Order placed. API HTTP ${statusCode}. ` +
        `Order ID: ${data?.order_id ?? "pending"}.\n\n` +
        JSON.stringify(data, null, 2)
      );
    }
  );

  // ── get_order ──────────────────────────────────────────────────────────────
  server.tool(
    "get_order",
    "Fetch the full order record from DynamoDB by order ID.",
    OrderIdSchema,
    async ({ orderId }) => {
      const order = await getOrder(orderId);
      return textResult(JSON.stringify(order, null, 2));
    }
  );

  // ── get_order_status ───────────────────────────────────────────────────────
  server.tool(
    "get_order_status",
    "Return the current status of an order (RECEIVED → PROCESSING → PROCESSED).",
    OrderIdSchema,
    async ({ orderId }) => {
      const order  = await getOrder(orderId);
      const status = getOrderStatusPayload(order);
      const parts  = [`Order #${orderId} — Status: ${status.status}`];
      if (status.payment_status)  parts.push(`Payment: ${status.payment_status}`);
      if (status.shipping_status) parts.push(`Shipping: ${status.shipping_status}`);
      return textResult(parts.join(" | "));
    }
  );

  // ── summarize_order ────────────────────────────────────────────────────────
  server.tool(
    "summarize_order",
    "Generate a human-readable one-paragraph summary of an order.",
    OrderIdSchema,
    async ({ orderId }) => {
      const order   = await getOrder(orderId);
      const summary = buildSummary(order);
      return textResult(summary);
    }
  );

  // ── answer_customer_query ──────────────────────────────────────────────────
  server.tool(
    "answer_customer_query",
    "Answer a customer support question about an order using Gemini 2.5 Flash. Falls back to a rule-based reply when GEMINI_API_KEY is not set.",
    AnswerQuerySchema,
    async ({ orderId, question }) => {
      const order  = await getOrder(orderId);
      const answer = await answerCustomerQuery(order, question);
      return textResult(answer);
    }
  );

  // ── get_workshop_config ────────────────────────────────────────────────────
  server.tool(
    "get_workshop_config",
    "Return the active runtime configuration: AWS region, DynamoDB table, API URL, Gemini status.",
    {},   // no input parameters
    async () => {
      const config = getRuntimeConfig();
      return textResult(JSON.stringify(config, null, 2));
    }
  );

  return server;
}

// ═════════════════════════════════════════════════════════════════════════════
// TRANSPORT A — stdio  (official SDK StdioServerTransport)
// Works with MCP Inspector v0.15+, Claude Desktop, and any stdio MCP client.
// ═════════════════════════════════════════════════════════════════════════════
async function runStdioServer() {
  console.error("[aws-order-system-mcp] Starting stdio transport…");

  const server    = buildMcpServer();
  const transport = new StdioServerTransport();

  await server.connect(transport);

  console.error("[aws-order-system-mcp] stdio transport ready.");
  console.error("[aws-order-system-mcp] Inspector: set DANGEROUSLY_OMIT_AUTH=true && npx @modelcontextprotocol/inspector node mcp_server.js");
}

// ═════════════════════════════════════════════════════════════════════════════
// TRANSPORT B — HTTP Express  (for web UI / curl / Postman)
// The TOOLS list here mirrors the SDK definitions above — kept in sync manually.
// ═════════════════════════════════════════════════════════════════════════════

// JSON schema representation of tools (for GET /mcp/tools endpoint)
const HTTP_TOOLS = [
  {
    name: "place_order",
    description: "Create a new order through the AWS API Gateway → SQS → Lambda pipeline.",
    inputSchema: {
      type: "object",
      properties: {
        customer_name:  { type: "string",  description: "Full name of the customer" },
        product_id:     { type: "string",  description: "Product SKU or identifier" },
        quantity:       { type: "integer", minimum: 1, description: "Number of units to order" },
        price_per_unit: { type: "number",  description: "Price per unit in USD (optional)" },
      },
      required: ["customer_name", "product_id", "quantity"],
      additionalProperties: false,
    },
  },
  {
    name: "get_order",
    description: "Fetch the full order record from DynamoDB by order ID.",
    inputSchema: {
      type: "object",
      properties: { orderId: { type: "string" } },
      required: ["orderId"],
      additionalProperties: false,
    },
  },
  {
    name: "get_order_status",
    description: "Return the current status of an order (RECEIVED → PROCESSING → PROCESSED).",
    inputSchema: {
      type: "object",
      properties: { orderId: { type: "string" } },
      required: ["orderId"],
      additionalProperties: false,
    },
  },
  {
    name: "summarize_order",
    description: "Generate a human-readable summary of an order.",
    inputSchema: {
      type: "object",
      properties: { orderId: { type: "string" } },
      required: ["orderId"],
      additionalProperties: false,
    },
  },
  {
    name: "answer_customer_query",
    description: "Answer a customer support question using Gemini 2.5 Flash.",
    inputSchema: {
      type: "object",
      properties: {
        orderId:  { type: "string" },
        question: { type: "string" },
      },
      required: ["orderId", "question"],
      additionalProperties: false,
    },
  },
  {
    name: "get_workshop_config",
    description: "Return active runtime configuration.",
    inputSchema: { type: "object", properties: {}, additionalProperties: false },
  },
];

async function httpDispatch(toolName, args = {}) {
  switch (toolName) {
    case "place_order": {
      const { customer_name, product_id, quantity, price_per_unit = 0 } = args;
      if (!customer_name || !product_id || !quantity) {
        const e = new Error("customer_name, product_id, and quantity are required."); e.httpCode = 400; throw e;
      }
      const { data, statusCode } = await placeOrder({ customer_name, product_id, quantity: Number(quantity), price_per_unit: Number(price_per_unit) });
      return { content: [{ type: "text", text: `Order placed. HTTP ${statusCode}. Order ID: ${data?.order_id ?? "pending"}.\n\n${JSON.stringify(data, null, 2)}` }], structuredContent: { statusCode, response: data } };
    }
    case "get_order": {
      const order = await getOrder(args.orderId);
      return { content: [{ type: "text", text: JSON.stringify(order, null, 2) }], structuredContent: { order } };
    }
    case "get_order_status": {
      const order  = await getOrder(args.orderId);
      const status = getOrderStatusPayload(order);
      return { content: [{ type: "text", text: `Order #${args.orderId} — Status: ${status.status}` }], structuredContent: status };
    }
    case "summarize_order": {
      const order   = await getOrder(args.orderId);
      const summary = buildSummary(order);
      return { content: [{ type: "text", text: summary }], structuredContent: { summary } };
    }
    case "answer_customer_query": {
      const order  = await getOrder(args.orderId);
      const answer = await answerCustomerQuery(order, args.question);
      return { content: [{ type: "text", text: answer }], structuredContent: { answer } };
    }
    case "get_workshop_config": {
      const config = getRuntimeConfig();
      return { content: [{ type: "text", text: JSON.stringify(config, null, 2) }], structuredContent: config };
    }
    default: {
      const e = new Error(`Unknown tool: "${toolName}"`); e.httpCode = 404; throw e;
    }
  }
}

async function runHttpServer() {
  const host = (process.env.MCP_HTTP_HOST || "127.0.0.1").trim();
  const port = Number(process.env.MCP_HTTP_PORT || 8000);

  const app = express();
  app.use(express.json());

  // CORS
  app.use((req, res, next) => {
    const origin = (process.env.MCP_ALLOWED_ORIGIN || "*").trim() || "*";
    res.setHeader("Access-Control-Allow-Origin",  origin);
    res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
    res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
    if (req.method === "OPTIONS") return res.status(204).end();
    next();
  });

  app.get("/health", (_req, res) => {
    const cfg = getRuntimeConfig();
    res.json({ status: "ok", serverInfo: SERVER_INFO, geminiConfigured: cfg.geminiConfigured });
  });

  app.get("/mcp/tools", (_req, res) => {
    res.json({ serverInfo: SERVER_INFO, tools: HTTP_TOOLS });
  });

  app.post("/mcp/call", async (req, res) => {
    const { name, arguments: args = {} } = req.body || {};
    try {
      const result = await httpDispatch(name, args);
      return res.json({ ok: true, result });
    } catch (err) {
      const code = err.httpCode || (err.statusCode === 404 ? 404 : 500);
      return res.status(code).json({ ok: false, error: { message: err.message } });
    }
  });

  await new Promise((resolve, reject) => {
    app.listen(port, host, (err) => {
      if (err) return reject(err);
      console.error(`[aws-order-system-mcp] HTTP transport ready.`);
      console.error(`[aws-order-system-mcp]   Health:     http://${host}:${port}/health`);
      console.error(`[aws-order-system-mcp]   List tools: http://${host}:${port}/mcp/tools`);
      console.error(`[aws-order-system-mcp]   Call tool:  POST http://${host}:${port}/mcp/call`);
      resolve();
    });
  });
}

// ═════════════════════════════════════════════════════════════════════════════
// ENTRY POINT
// ═════════════════════════════════════════════════════════════════════════════
(async () => {
  try {
    const forceHttp = process.argv.includes("--http");
    const transport = (process.env.MCP_TRANSPORT || "stdio").toLowerCase();

    if (forceHttp || transport === "http") {
      await runHttpServer();
    } else {
      await runStdioServer();
    }
  } catch (err) {
    console.error("[aws-order-system-mcp] Fatal startup error:", err);
    process.exit(1);
  }
})();
