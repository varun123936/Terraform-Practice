import { SQSClient, SendMessageCommand } from "@aws-sdk/client-sqs";
import { randomUUID } from "crypto";

const sqs = new SQSClient({ region: process.env.AWS_REGION });

export const handler = async (event) => {
  try {
    const body = JSON.parse(event.body || "{}");

    const { customer_name, product_id, quantity, price_per_unit } = body;

    // Validate required fields
    if (!customer_name || !product_id || !quantity) {
      return {
        statusCode: 400,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          error: "Missing required fields: customer_name, product_id, quantity"
        })
      };
    }

    const order = {
      order_id:      randomUUID(),
      customer_name: customer_name.trim(),
      product_id:    product_id.trim(),
      quantity:      Number(quantity),
      price_per_unit: Number(price_per_unit) || 0,
      total_amount:  Number(quantity) * (Number(price_per_unit) || 0),
      status:        "RECEIVED",
      timestamp:     new Date().toISOString()
    };

    // Push order to SQS queue
    await sqs.send(new SendMessageCommand({
      QueueUrl:    process.env.SQS_QUEUE_URL,
      MessageBody: JSON.stringify(order),
      MessageAttributes: {
        source: {
          DataType:    "String",
          StringValue: "order-api"
        }
      }
    }));

    console.log(`Order received and queued: ${order.order_id}`);

    // Return instant response to customer
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        success:  true,
        message:  "Order placed successfully!",
        order_id: order.order_id,
        status:   "RECEIVED",
        info:     "Your order is being processed. You will receive confirmation shortly."
      })
    };

  } catch (err) {
    console.error("Error in order-receiver:", err);
    return {
      statusCode: 500,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ error: "Internal server error", detail: err.message })
    };
  }
};