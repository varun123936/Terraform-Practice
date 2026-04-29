// app.js — AWS Order System frontend
// Mirrors llmops-claude-mcp-server-intigreation/web/static/app.js exactly,
// adapted for the aws-order-system field names and POST-only routes.

// ── shared fetch helper ───────────────────────────────────────────────────────
const postJson = async (url, payload) => {
  const response = await fetch(url, {
    method:  "POST",
    headers: { "Content-Type": "application/json" },
    body:    JSON.stringify(payload),
  });

  const text = await response.text();
  let data;
  try   { data = JSON.parse(text); }
  catch { data = { raw: text };    }

  if (!response.ok) {
    throw new Error(JSON.stringify(data, null, 2));
  }

  return data;
};

// ── display helpers ───────────────────────────────────────────────────────────
const setResult = (id, value) => {
  document.getElementById(id).textContent =
    typeof value === "string" ? value : JSON.stringify(value, null, 2);
};

const formatAiResult = (data) =>
  data.answer  ? data.answer  :
  data.message ? data.message :
  JSON.stringify(data, null, 2);

// ── Create Order ──────────────────────────────────────────────────────────────
document.getElementById("create-order-form").addEventListener("submit", async (e) => {
  e.preventDefault();
  const fd = new FormData(e.currentTarget);
  const payload = {
    customer_name:  fd.get("customer_name"),
    product_id:     fd.get("product_id"),
    quantity:       Number(fd.get("quantity")),
    price_per_unit: Number(fd.get("price_per_unit") || 0),
  };

  setResult("create-order-result", "Submitting order…");
  try {
    const data = await postJson("/placeOrder", payload);
    setResult("create-order-result", data);
  } catch (err) {
    setResult("create-order-result", err.message);
  }
});

// ── Lookup Order ──────────────────────────────────────────────────────────────
document.querySelectorAll("#lookup-form [data-action]").forEach((btn) => {
  btn.addEventListener("click", async () => {
    const orderId = new FormData(document.getElementById("lookup-form")).get("orderId");

    if (!orderId) {
      setResult("lookup-result", "Order ID is required.");
      return;
    }

    const routeMap = {
      status:  "/getOrderStatus",
      details: "/getOrder",
      summary: "/summarizeOrder",
    };

    setResult("lookup-result", "Loading…");
    try {
      const data = await postJson(routeMap[btn.dataset.action], { orderId });
      setResult("lookup-result", data);
    } catch (err) {
      setResult("lookup-result", err.message);
    }
  });
});

// ── Ask AI ────────────────────────────────────────────────────────────────────
document.getElementById("ai-form").addEventListener("submit", async (e) => {
  e.preventDefault();
  const fd = new FormData(e.currentTarget);

  setResult("ai-result", "Thinking…");
  try {
    const data = await postJson("/customerQuery", {
      orderId:  fd.get("orderId"),
      question: fd.get("question"),
    });
    setResult("ai-result", formatAiResult(data));
  } catch (err) {
    try   { setResult("ai-result", formatAiResult(JSON.parse(err.message))); }
    catch { setResult("ai-result", err.message); }
  }
});
