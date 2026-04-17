const express = require("express");
const fs = require("fs");
const path = require("path");

loadEnvFile();

const app = express();
const port = Number(process.env.PORT || 3000);
const publicDir = path.join(__dirname, "public");

app.use(express.json());
app.use(express.static(publicDir));

app.get("/health", (_req, res) => {
  res.json({
    ok: true,
    app: "aws-order-system-ui",
    step: 2,
    apiConfigured: Boolean(getOrderPostUrl()),
    message: "UI backend is running. MCP and Ollama wiring will come in later steps."
  });
});

app.get("/api/config", (_req, res) => {
  res.json({
    ok: true,
    step: 2,
    apiConfigured: Boolean(getOrderPostUrl()),
    orderPostUrl: getOrderPostUrl() || null,
    orderGetBaseUrl: getOrderBaseUrl() || null
  });
});

app.post("/api/orders", async (req, res) => {
  const apiUrl = getOrderPostUrl();

  if (!apiUrl) {
    return res.status(500).json({
      message: "ORDER_API_URL or ORDER_API_BASE_URL is not configured on the local UI server."
    });
  }

  try {
    const upstream = await fetch(apiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(req.body || {})
    });

    const data = await readJson(upstream);
    return res.status(upstream.status).json(data);
  } catch (error) {
    console.error("Create order proxy error:", error.message);
    return res.status(502).json({
      message: "Unable to reach the AWS order API.",
      detail: error.message
    });
  }
});

app.get("/api/orders/:orderId", async (req, res) => {
  try {
    const order = await fetchOrder(req.params.orderId);
    return res.json({ order });
  } catch (error) {
    return handleOrderFetchError(res, error);
  }
});

app.get("/api/orders/:orderId/status", async (req, res) => {
  try {
    const order = await fetchOrder(req.params.orderId);
    return res.json({
      order_id: getOrderId(order),
      status: order.status || "UNKNOWN",
      payment_status: order.paymentStatus || order.payment_status || null,
      shipping_status: order.shippingStatus || order.shipping_status || null
    });
  } catch (error) {
    return handleOrderFetchError(res, error);
  }
});

app.get("/api/orders/:orderId/summary", async (req, res) => {
  try {
    const order = await fetchOrder(req.params.orderId);
    return res.json({
      order_id: getOrderId(order),
      summary: buildOrderSummary(order)
    });
  } catch (error) {
    return handleOrderFetchError(res, error);
  }
});

app.get("*", (_req, res) => {
  res.sendFile(path.join(publicDir, "index.html"));
});

app.listen(port, () => {
  console.log(`aws-order-system UI running at http://localhost:${port}`);
});

function getOrderPostUrl() {
  const directUrl = process.env.ORDER_API_URL?.trim();
  if (directUrl) {
    return directUrl;
  }

  const baseUrl = getOrderBaseUrl();
  return baseUrl ? `${baseUrl}/order` : "";
}

function getOrderBaseUrl() {
  const baseUrl = process.env.ORDER_API_BASE_URL?.trim();
  if (baseUrl) {
    return baseUrl.replace(/\/+$/, "");
  }

  const directUrl = process.env.ORDER_API_URL?.trim();
  if (!directUrl) {
    return "";
  }

  return directUrl.replace(/\/order\/?$/, "");
}

async function fetchOrder(orderId) {
  const trimmedId = String(orderId || "").trim();
  if (!trimmedId) {
    const error = new Error("Order ID is required.");
    error.statusCode = 400;
    throw error;
  }

  const baseUrl = getOrderBaseUrl();
  if (!baseUrl) {
    const error = new Error("ORDER_API_URL or ORDER_API_BASE_URL is not configured on the local UI server.");
    error.statusCode = 500;
    throw error;
  }

  const upstream = await fetch(`${baseUrl}/order/${encodeURIComponent(trimmedId)}`);
  const data = await readJson(upstream);

  if (!upstream.ok) {
    const error = new Error(data.error || data.message || "Failed to fetch order.");
    error.statusCode = upstream.status;
    throw error;
  }

  return data.order || data;
}

async function readJson(response) {
  const text = await response.text();
  if (!text) {
    return {};
  }

  try {
    return JSON.parse(text);
  } catch {
    return { raw: text };
  }
}

function buildOrderSummary(order) {
  const orderId = getOrderId(order);
  const customerName = order.customer_name || order.customerName || "Customer";
  const productId = order.product_id || order.productId || "unknown-product";
  const quantity = order.quantity ?? 0;
  const totalAmount = order.total_amount ?? order.totalAmount ?? 0;
  const status = order.status || "UNKNOWN";

  return `Order ${orderId} for ${customerName} contains ${quantity} unit(s) of ${productId}. Current status is ${status}. Total amount is ${totalAmount}.`;
}

function getOrderId(order) {
  return order.order_id || order.orderId || "unknown";
}

function handleOrderFetchError(res, error) {
  console.error("Order lookup proxy error:", error.message);
  return res.status(error.statusCode || 502).json({
    message: error.message || "Unable to fetch order details."
  });
}

function loadEnvFile() {
  const envPath = path.join(__dirname, ".env");
  if (!fs.existsSync(envPath)) {
    return;
  }

  const lines = fs.readFileSync(envPath, "utf8").split(/\r?\n/);
  for (const rawLine of lines) {
    const line = rawLine.trim();
    if (!line || line.startsWith("#") || !line.includes("=")) {
      continue;
    }

    const separatorIndex = line.indexOf("=");
    const key = line.slice(0, separatorIndex).trim();
    const value = line.slice(separatorIndex + 1).trim().replace(/^['"]|['"]$/g, "");

    if (key && !process.env[key]) {
      process.env[key] = value;
    }
  }
}
