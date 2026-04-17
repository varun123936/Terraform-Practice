const express = require("express");
const path = require("path");

const app = express();
const port = Number(process.env.PORT || 3000);
const publicDir = path.join(__dirname, "public");

app.use(express.static(publicDir));

app.get("/health", (_req, res) => {
  res.json({
    ok: true,
    app: "aws-order-system-ui",
    step: 1,
    message: "UI is running. Backend, MCP, and AI wiring will come in later steps."
  });
});

app.get("*", (_req, res) => {
  res.sendFile(path.join(publicDir, "index.html"));
});

app.listen(port, () => {
  console.log(`aws-order-system UI running at http://localhost:${port}`);
});
