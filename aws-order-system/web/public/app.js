const createOrderForm = document.getElementById("create-order-form");
const lookupForm = document.getElementById("lookup-form");
const aiForm = document.getElementById("ai-form");

const createOrderResult = document.getElementById("create-order-result");
const lookupResult = document.getElementById("lookup-result");
const aiResult = document.getElementById("ai-result");

function pretty(data) {
  return JSON.stringify(data, null, 2);
}

createOrderForm.addEventListener("submit", (event) => {
  event.preventDefault();

  const formData = new FormData(createOrderForm);
  const payload = {
    customer_name: formData.get("customer_name"),
    product_id: formData.get("product_id"),
    quantity: Number(formData.get("quantity") || 0),
    price_per_unit: Number(formData.get("price_per_unit") || 0)
  };

  createOrderResult.textContent = "Submitting order...";

  fetch("/api/orders", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(payload)
  })
    .then(async (response) => {
      const data = await response.json();
      return { ok: response.ok, status: response.status, data };
    })
    .then(({ ok, status, data }) => {
      createOrderResult.textContent = pretty({
        ok,
        status,
        response: data
      });
    })
    .catch((error) => {
      createOrderResult.textContent = pretty({
        ok: false,
        message: "Unable to submit order from local UI backend.",
        detail: error.message
      });
    });
});

lookupForm.querySelectorAll("[data-action]").forEach((button) => {
  button.addEventListener("click", () => {
    const formData = new FormData(lookupForm);
    const orderId = String(formData.get("order_id") || "").trim();
    const action = button.dataset.action;
    const routeMap = {
      details: `/api/orders/${encodeURIComponent(orderId)}`,
      status: `/api/orders/${encodeURIComponent(orderId)}/status`,
      summary: `/api/orders/${encodeURIComponent(orderId)}/summary`
    };

    lookupResult.textContent = `Loading ${action}...`;

    fetch(routeMap[action])
      .then(async (response) => {
        const data = await response.json();
        return { ok: response.ok, status: response.status, data };
      })
      .then(({ ok, status, data }) => {
        lookupResult.textContent = pretty({
          action,
          ok,
          status,
          response: data
        });
      })
      .catch((error) => {
        lookupResult.textContent = pretty({
          action,
          ok: false,
          message: "Unable to fetch order information from local UI backend.",
          detail: error.message
        });
      });
  });
});

aiForm.addEventListener("submit", (event) => {
  event.preventDefault();

  const formData = new FormData(aiForm);
  const orderId = String(formData.get("order_id") || "").trim();
  const question = String(formData.get("question") || "").trim();

  aiResult.textContent = pretty({
    step: 2,
    status: "Placeholder",
    message: "Ollama and MCP are not connected yet. The UI/backend foundation is ready for the next steps.",
    next_steps: [
      "Step 3: Add MCP tools in Node.js",
      "Step 4: Connect Ollama chat",
      "Step 5: Answer customer questions using order context"
    ],
    request: {
      order_id: orderId,
      question
    }
  });
});
