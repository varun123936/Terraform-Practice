import { SQSClient, SendMessageCommand } from "@aws-sdk/client-sqs";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand, UpdateCommand } from "@aws-sdk/lib-dynamodb";

const sqs = new SQSClient({ region: process.env.AWS_REGION });
const dynamo = DynamoDBDocumentClient.from(
  new DynamoDBClient({ region: process.env.AWS_REGION })
);

const TABLE = process.env.DYNAMODB_TABLE;
const COUNTER_TABLE = process.env.COUNTER_TABLE;

export const handler = async (event) => {
  try {
    const method = event?.httpMethod;

    if (method === "GET") {
      return await getOrder(event);
    }

    if (method !== "POST") {
      return response(405, { error: "Method not allowed" });
    }

    const body = JSON.parse(event.body || "{}");
    const { customer_name, product_id, quantity, price_per_unit } = body;

    if (!customer_name || !product_id || !quantity) {
      return response(400, {
        error: "Missing required fields: customer_name, product_id, quantity"
      });
    }

    const order = {
      order_id: await getNextOrderId(),
      customer_name: customer_name.trim(),
      product_id: product_id.trim(),
      quantity: Number(quantity),
      price_per_unit: Number(price_per_unit) || 0,
      total_amount: Number(quantity) * (Number(price_per_unit) || 0),
      status: "RECEIVED",
      timestamp: new Date().toISOString()
    };

    await sqs.send(new SendMessageCommand({
      QueueUrl: process.env.SQS_QUEUE_URL,
      MessageBody: JSON.stringify(order),
      MessageAttributes: {
        source: {
          DataType: "String",
          StringValue: "order-api"
        }
      }
    }));

    console.log(`Order received and queued: ${order.order_id}`);

    return response(200, {
      success: true,
      message: "Order placed successfully!",
      order_id: order.order_id,
      status: "RECEIVED",
      info: "Your order is being processed. You will receive confirmation shortly."
    });
  } catch (err) {
    console.error("Error in order-receiver:", err);
    return response(500, {
      error: "Internal server error",
      detail: err.message
    });
  }
};

async function getOrder(event) {
  const orderId = event?.pathParameters?.order_id?.trim();

  if (!orderId) {
    return response(400, {
      error: "Missing required path parameter: order_id"
    });
  }

  const result = await dynamo.send(new GetCommand({
    TableName: TABLE,
    Key: { order_id: orderId }
  }));

  if (!result.Item) {
    return response(404, {
      error: "Order not found",
      order_id: orderId
    });
  }

  return response(200, {
    success: true,
    order: result.Item
  });
}

async function getNextOrderId() {
  const result = await dynamo.send(new UpdateCommand({
    TableName: COUNTER_TABLE,
    Key: { counter_name: "order" },
    UpdateExpression: "SET current_value = if_not_exists(current_value, :zero) + :one, updated_at = :updated_at",
    ExpressionAttributeValues: {
      ":zero": 0,
      ":one": 1,
      ":updated_at": new Date().toISOString()
    },
    ReturnValues: "UPDATED_NEW"
  }));

  return String(result.Attributes.current_value);
}

function response(statusCode, body) {
  return {
    statusCode,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*"
    },
    body: JSON.stringify(body)
  };
}
