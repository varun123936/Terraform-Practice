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

  createOrderResult.textContent = pretty({
    step: 1,
    status: "UI only",
    message: "This is the payload that will be sent to the backend in Step 2.",
    payload
  });
});

lookupForm.querySelectorAll("[data-action]").forEach((button) => {
  button.addEventListener("click", () => {
    const formData = new FormData(lookupForm);
    const orderId = String(formData.get("order_id") || "").trim();
    const action = button.dataset.action;

    lookupResult.textContent = pretty({
      step: 1,
      status: "UI only",
      message: `This will call the ${action} flow once the backend is added in Step 2.`,
      request: {
        action,
        order_id: orderId
      }
    });
  });
});

aiForm.addEventListener("submit", (event) => {
  event.preventDefault();

  const formData = new FormData(aiForm);
  const orderId = String(formData.get("order_id") || "").trim();
  const question = String(formData.get("question") || "").trim();

  aiResult.textContent = pretty({
    step: 1,
    status: "Placeholder",
    message: "Ollama and MCP are not connected yet. This panel is ready for the next steps.",
    next_steps: [
      "Step 2: Add Node backend routes",
      "Step 3: Add MCP tools",
      "Step 4: Connect Ollama chat"
    ],
    request: {
      order_id: orderId,
      question
    }
  });
});
