// server.js
// ─── AWS Order System — Web UI Backend ───────────────────────────────────────
// Node.js / Express server that acts as a thin proxy between the browser
// and the MCP HTTP server.  Every browser action calls a named MCP tool
// via POST /mcp/call and surfaces the result to the frontend.
//
// Routes (mirrors llmops-claude-mcp-server-intigreation/web/web.py exactly):
//   POST /placeOrder       → MCP tool: place_order
//   POST /getOrder         → MCP tool: get_order
//   POST /getOrderStatus   → MCP tool: get_order_status
//   POST /summarizeOrder   → MCP tool: summarize_order
//   POST /customerQuery    → MCP tool: answer_customer_query  (Gemini-powered)
//   GET  /health           → liveness check

"use strict";

const fs      = require("fs");
const path    = require("path");
const express = require("express");

// ── Load .env before anything else ───────────────────────────────────────────
loadEnvFile();

const app       = express();
const PORT      = Number(process.env.PORT      || 3001);
const MCP_URL   = (process.env.MCP_SERVER_URL  || "http://127.0.0.1:8000").trim();
const publicDir = path.join(__dirname, "public");

app.use(express.json());
app.use(express.static(publicDir));

// ─────────────────────────────────────────────────────────────────────────────
// MCP CLIENT  (same pattern as llmops web.py RemoteMCPClient)
// ─────────────────────────────────────────────────────────────────────────────

class McpClientError extends Error {
  constructor(message, code, statusCode) {
    super(message);
    this.code       = code;
    this.statusCode = statusCode;
  }
}

async function callMcpTool(name, args = {}) {
  const endpoint = `${MCP_URL}/mcp/call`;
  let response;

  try {
    response = await fetch(endpoint, {
      method:  "POST",
      headers: { "Content-Type": "application/json", "Accept": "application/json" },
      body:    JSON.stringify({ name, arguments: args }),
    });
  } catch (networkErr) {
    throw new McpClientError(
      `Unable to reach MCP server at ${endpoint}: ${networkErr.message}`,
      null,
      502
    );
  }

  let body;
  const text = await response.text();
  try   { body = JSON.parse(text); }
  catch { body = { raw: text };    }

  if (body.ok) {
    return body.result || {};
  }

  const errInfo = body.error || {};
  throw new McpClientError(
    errInfo.message || "MCP tool call failed.",
    errInfo.code,
    response.status
  );
}

// Helper: pull plain-text out of MCP content array
function textFromResult(result) {
  return (result.content || [])
    .filter(b => b.type === "text" && b.text)
    .map(b => b.text.trim())
    .join("\n")
    .trim();
}

// Helper: unified MCP error → Express response
function handleMcpError(res, err) {
  console.error("[web] MCP error:", err.message);
  const status = err.statusCode || 502;
  return res.status(status).json({ message: err.message || "MCP tool call failed." });
}

// ─────────────────────────────────────────────────────────────────────────────
// ROUTES
// ─────────────────────────────────────────────────────────────────────────────

app.get("/health", (_req, res) => {
  res.json({
    ok:           true,
    app:          "aws-order-system-ui",
    mcpServerUrl: MCP_URL,
    geminiPowered: true,
  });
});

// POST /placeOrder  { customer_name, product_id, quantity, price_per_unit }
app.post("/placeOrder", async (req, res) => {
  try {
    const result     = await callMcpTool("place_order", req.body || {});
    const structured = result.structuredContent || {};
    return res.status(structured.statusCode || 200).json(structured.response || {});
  } catch (err) {
    return handleMcpError(res, err);
  }
});

// POST /getOrder  { orderId }
app.post("/getOrder", async (req, res) => {
  try {
    const result = await callMcpTool("get_order", { orderId: req.body?.orderId });
    const order  = (result.structuredContent || {}).order;
    return res.json({ order });
  } catch (err) {
    if (err.code === -32001) return res.status(404).json({ message: "Order not found." });
    return handleMcpError(res, err);
  }
});

// POST /getOrderStatus  { orderId }
app.post("/getOrderStatus", async (req, res) => {
  try {
    const result = await callMcpTool("get_order_status", { orderId: req.body?.orderId });
    const sc     = result.structuredContent || {};
    return res.json({ status: sc.status || sc.order_status || textFromResult(result) });
  } catch (err) {
    if (err.code === -32001) return res.status(404).json({ status: "unknown" });
    return handleMcpError(res, err);
  }
});

// POST /summarizeOrder  { orderId }
app.post("/summarizeOrder", async (req, res) => {
  try {
    const result  = await callMcpTool("summarize_order", { orderId: req.body?.orderId });
    const summary = (result.structuredContent || {}).summary || textFromResult(result);
    return res.json({ summary });
  } catch (err) {
    if (err.code === -32001) return res.status(404).json({ message: "Order not found." });
    return handleMcpError(res, err);
  }
});

// POST /customerQuery  { orderId, question }
app.post("/customerQuery", async (req, res) => {
  try {
    const { orderId, question } = req.body || {};
    const result = await callMcpTool("answer_customer_query", { orderId, question });
    const answer = (result.structuredContent || {}).answer || textFromResult(result);
    return res.json({ answer });
  } catch (err) {
    if (err.code === -32001) return res.status(404).json({ message: "Order not found." });
    return handleMcpError(res, err);
  }
});

// SPA fallback
app.get("*", (_req, res) => {
  res.sendFile(path.join(publicDir, "index.html"));
});

// ─────────────────────────────────────────────────────────────────────────────
// START
// ─────────────────────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`[web] AWS Order System UI  →  http://localhost:${PORT}`);
  console.log(`[web] MCP server target    →  ${MCP_URL}`);
});

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
function loadEnvFile() {
  const envPath = path.join(__dirname, ".env");
  if (!fs.existsSync(envPath)) return;
  for (const raw of fs.readFileSync(envPath, "utf8").split(/\r?\n/)) {
    const line = raw.trim();
    if (!line || line.startsWith("#") || !line.includes("=")) continue;
    const sep   = line.indexOf("=");
    const key   = line.slice(0, sep).trim();
    const value = line.slice(sep + 1).trim().replace(/^['"]|['"]$/g, "");
    if (key && !(key in process.env)) process.env[key] = value;
  }
}
