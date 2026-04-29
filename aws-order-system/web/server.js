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
    step: 3,
    mcpConfigured: Boolean(getMcpServerUrl()),
    message: "UI backend is running through MCP tools. Gemini wiring will come in the next step."
  });
});

app.get("/api/config", (_req, res) => {
  res.json({
    ok: true,
    step: 3,
    mcpServerUrl: getMcpServerUrl() || null
  });
});

app.post("/api/orders", async (req, res) => {
  try {
    const result = await callMcpTool("place_order", req.body || {});
    const structured = result.structuredContent || {};
    return res.status(structured.statusCode || 200).json(structured.response || {});
  } catch (error) {
    console.error("Create order MCP error:", error.message);
    return res.status(error.statusCode || 502).json({
      message: error.message || "Unable to reach MCP order tool."
    });
  }
});

app.get("/api/orders/:orderId", async (req, res) => {
  try {
    const result = await callMcpTool("get_order", { orderId: req.params.orderId });
    const order = result.structuredContent?.order;
    return res.json({ order });
  } catch (error) {
    return handleMcpError(res, error);
  }
});

app.get("/api/orders/:orderId/status", async (req, res) => {
  try {
    const result = await callMcpTool("get_order_status", { orderId: req.params.orderId });
    return res.json(result.structuredContent || {});
  } catch (error) {
    return handleMcpError(res, error);
  }
});

app.get("/api/orders/:orderId/summary", async (req, res) => {
  try {
    const result = await callMcpTool("summarize_order", { orderId: req.params.orderId });
    return res.json({
      order_id: req.params.orderId,
      summary: result.structuredContent?.summary || textFromResult(result)
    });
  } catch (error) {
    return handleMcpError(res, error);
  }
});

app.get("*", (_req, res) => {
  res.sendFile(path.join(publicDir, "index.html"));
});

app.listen(port, () => {
  console.log(`aws-order-system UI running at http://localhost:${port}`);
});

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

function getMcpServerUrl() {
  return (process.env.MCP_SERVER_URL || "http://127.0.0.1:8000").trim();
}

async function callMcpTool(name, argumentsObject = {}) {
  const response = await fetch(`${getMcpServerUrl()}/mcp/call`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json"
    },
    body: JSON.stringify({
      name,
      arguments: argumentsObject
    })
  });

  const data = await readJson(response);
  if (data.ok) {
    return data.result || {};
  }

  const errorInfo = data.error || {};
  const error = new Error(errorInfo.message || "MCP tool call failed.");
  error.statusCode = response.status;
  error.code = errorInfo.code;
  throw error;
}

function textFromResult(result) {
  const content = result.content || [];
  return content
    .filter((block) => block.type === "text" && block.text)
    .map((block) => block.text.trim())
    .join("\n");
}

function handleMcpError(res, error) {
  console.error("MCP proxy error:", error.message);
  return res.status(error.statusCode || 502).json({
    message: error.message || "Unable to reach MCP tool."
  });
}
