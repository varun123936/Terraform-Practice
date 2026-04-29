// order_service.js
// ─── AWS DynamoDB + API Gateway service layer ─────────────────────────────────
// Handles all AWS interactions and Gemini AI customer support answers.

"use strict";

const fs   = require("fs");
const path = require("path");
const { DynamoDBClient }                   = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand } = require("@aws-sdk/lib-dynamodb");
const { GoogleGenerativeAI }               = require("@google/generative-ai");

// ── 1. Load .env before anything else ────────────────────────────────────────
loadEnvFile();

// ── 2. Config from environment ────────────────────────────────────────────────
const AWS_REGION   = process.env.AWS_REGION   || "us-east-1";
const ORDERS_TABLE = process.env.ORDERS_TABLE || "orders-table";
const ORDER_API_URL = (process.env.ORDER_API_URL || "").trim();
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || "";
const GEMINI_MODEL   = process.env.GEMINI_MODEL   || "gemini-2.5-flash";

// ── 3. AWS clients ────────────────────────────────────────────────────────────
const dynamo = DynamoDBDocumentClient.from(
  new DynamoDBClient({ region: AWS_REGION })
);

// ── 4. Gemini client (lazy — only initialised if API key is present) ──────────
let _genAI = null;
function getGenAI() {
  if (!GEMINI_API_KEY) {
    throw new Error("GEMINI_API_KEY is not set in your .env file.");
  }
  if (!_genAI) {
    _genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
  }
  return _genAI;
}

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC API
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Return runtime configuration visible through the MCP tool get_workshop_config.
 */
function getRuntimeConfig() {
  return {
    awsRegion:        AWS_REGION,
    ordersTable:      ORDERS_TABLE,
    orderApiUrl:      ORDER_API_URL || null,
    geminiModel:      GEMINI_MODEL,
    geminiConfigured: Boolean(GEMINI_API_KEY),
  };
}

/**
 * POST a new order to the API Gateway → Lambda order-receiver.
 * @param {object} payload  { customer_name, product_id, quantity, price_per_unit }
 * @returns {{ data: object, statusCode: number }}
 */
async function placeOrder(payload) {
  if (!ORDER_API_URL) {
    throw createError("ORDER_API_URL is not configured in .env", 500);
  }

  const response = await fetch(ORDER_API_URL, {
    method:  "POST",
    headers: { "Content-Type": "application/json" },
    body:    JSON.stringify(payload),
  });

  const data = await readJson(response);
  return { data, statusCode: response.status };
}

/**
 * Fetch a single order from DynamoDB via API Gateway.
 * Uses GET /order/{order_id} (Lambda order-receiver handles GET).
 * @param {string} orderId
 * @returns {object}  The raw DynamoDB item
 */
async function getOrder(orderId) {
  if (!ORDER_API_URL) {
    throw createError("ORDER_API_URL is not configured in .env", 500);
  }

  // Derive the base URL: strip trailing "/order" to get stage base, then re-add /order/{id}
  const base    = ORDER_API_URL.replace(/\/order\/?$/, "");
  const url     = `${base}/order/${encodeURIComponent(orderId.trim())}`;
  const response = await fetch(url);
  const data     = await readJson(response);

  if (!response.ok) {
    const msg = data?.error || data?.message || "Order not found";
    throw createError(msg, response.status);
  }

  // order-receiver returns { success: true, order: {...} }
  return data.order || data;
}

/**
 * Return a structured status payload for an order.
 */
function getOrderStatusPayload(order) {
  return {
    order_id:        order.order_id || "unknown",
    status:          order.status   || "UNKNOWN",
    payment_status:  order.payment_status  || order.paymentStatus  || null,
    shipping_status: order.shipping_status || order.shippingStatus || null,
  };
}

/**
 * Build a human-readable one-paragraph summary of an order.
 */
function buildSummary(order) {
  const id         = order.order_id     || "unknown";
  const customer   = order.customer_name || "Customer";
  const product    = order.product_id   || "unknown product";
  const qty        = order.quantity     ?? 0;
  const total      = order.total_amount ?? 0;
  const status     = order.status       || "UNKNOWN";
  const receivedAt = order.timestamp    || order.received_at || "unknown time";

  return (
    `Order #${id} for ${customer} — ${qty} unit(s) of "${product}" ` +
    `(total: $${total}). Status: ${status}. Received at: ${receivedAt}.`
  );
}

/**
 * Answer a customer question about their order using Gemini 2.5 Flash.
 * Falls back to a rule-based answer when Gemini is not configured.
 * @param {object} order       Full order object from DynamoDB
 * @param {string} question    Customer's question
 * @returns {Promise<string>}
 */
async function answerCustomerQuery(order, question) {
  if (!GEMINI_API_KEY) {
    return _fallbackAnswer(order, question);
  }
  return _askGemini(order, question);
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE HELPERS
// ─────────────────────────────────────────────────────────────────────────────

async function _askGemini(order, question) {
  const genAI = getGenAI();
  const model = genAI.getGenerativeModel({ model: GEMINI_MODEL });

  const orderContext = JSON.stringify(order, null, 2);
  const prompt = [
    "You are a helpful customer support assistant for an e-commerce order system.",
    "Answer in plain English that is easy for a customer to understand.",
    "Do NOT mention JSON, DynamoDB, Lambda, AWS, or any internal field names.",
    "Be concise but complete. When relevant, mention: item, quantity, order status,",
    "payment status, shipping status, and the likely next step.",
    "",
    `Customer question: ${question}`,
    "",
    `Order data:\n${orderContext}`,
    "",
    "Write your reply as if speaking directly to the customer.",
  ].join("\n");

  const result   = await model.generateContent(prompt);
  const response = result.response;
  return response.text().trim();
}

function _fallbackAnswer(order, question) {
  const q = (question || "").toLowerCase();
  const id = order.order_id || "unknown";

  if (q.includes("status")) {
    return `Order #${id} is currently ${order.status || "UNKNOWN"}.`;
  }
  if (q.includes("payment")) {
    return `Payment for order #${id} is ${order.payment_status || order.paymentStatus || "UNKNOWN"}.`;
  }
  if (q.includes("ship") || q.includes("deliver")) {
    return `Shipping for order #${id} is ${order.shipping_status || order.shippingStatus || "UNKNOWN"}.`;
  }
  return buildSummary(order);
}

async function readJson(response) {
  const text = await response.text();
  if (!text) return {};
  try { return JSON.parse(text); } catch { return { raw: text }; }
}

function createError(message, statusCode) {
  const err = new Error(message);
  err.statusCode = statusCode;
  return err;
}

function loadEnvFile() {
  const envPath = path.join(__dirname, ".env");
  if (!fs.existsSync(envPath)) return;

  const lines = fs.readFileSync(envPath, "utf8").split(/\r?\n/);
  for (const raw of lines) {
    const line = raw.trim();
    if (!line || line.startsWith("#") || !line.includes("=")) continue;

    const sep   = line.indexOf("=");
    const key   = line.slice(0, sep).trim();
    const value = line.slice(sep + 1).trim().replace(/^['"]|['"]$/g, "");

    if (key && !(key in process.env)) {
      process.env[key] = value;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
module.exports = {
  getRuntimeConfig,
  placeOrder,
  getOrder,
  getOrderStatusPayload,
  buildSummary,
  answerCustomerQuery,
};
