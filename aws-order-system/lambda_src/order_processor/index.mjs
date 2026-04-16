import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand, UpdateCommand } from "@aws-sdk/lib-dynamodb";

const dynamo = DynamoDBDocumentClient.from(
  new DynamoDBClient({ region: process.env.AWS_REGION })
);

const TABLE = process.env.DYNAMODB_TABLE;

export const handler = async (event) => {
  const results = [];

  for (const record of event.Records) {
    let order;

    try {
      order = JSON.parse(record.body);
      console.log(`Processing order: ${order.order_id} for ${order.customer_name}`);

      // Step 1 — Save the order to DynamoDB with PROCESSING status
      await dynamo.send(new PutCommand({
        TableName: TABLE,
        Item: {
          order_id:       order.order_id,
          customer_name:  order.customer_name,
          product_id:     order.product_id,
          quantity:       order.quantity,
          price_per_unit: order.price_per_unit,
          total_amount:   order.total_amount,
          status:         "PROCESSING",
          received_at:    order.timestamp,
          processing_started_at: new Date().toISOString()
        }
      }));
      console.log(`[DynamoDB] Order ${order.order_id} saved with PROCESSING status`);

      // Step 2 — Simulate inventory update
      await updateInventory(order.product_id, order.quantity);

      // Step 3 — Simulate sending confirmation email
      await sendConfirmationEmail(order);

      // Step 4 — Simulate notifying warehouse
      await notifyWarehouse(order);

      // Step 5 — Update order status to PROCESSED in DynamoDB
      await dynamo.send(new UpdateCommand({
        TableName: TABLE,
        Key: { order_id: order.order_id },
        UpdateExpression:
          "SET #s = :status, processed_at = :time",
        ExpressionAttributeNames:  { "#s": "status" },
        ExpressionAttributeValues: {
          ":status": "PROCESSED",
          ":time":   new Date().toISOString()
        }
      }));
      console.log(`[DynamoDB] Order ${order.order_id} marked as PROCESSED`);

      results.push({ order_id: order.order_id, success: true });

    } catch (err) {
      console.error(`Failed to process order ${order?.order_id}:`, err);
      // Throwing here causes SQS to retry this message automatically
      throw err;
    }
  }

  return { statusCode: 200, processed: results };
};


async function updateInventory(productId, quantity) {
  // In real app: query your inventory DB and reduce stock
  console.log(`[INVENTORY] Product ${productId} stock reduced by ${quantity}`);
  await sleep(100);
}

async function sendConfirmationEmail(order) {
  // In real app: call AWS SES or SendGrid API here
  console.log(`[EMAIL] Confirmation email sent to customer for order ${order.order_id}`);
  console.log(`[EMAIL] Total charged: Rs. ${order.total_amount}`);
  await sleep(100);
}

async function notifyWarehouse(order) {
  // In real app: call your warehouse management system API
  console.log(`[WAREHOUSE] Pick & pack request raised for order ${order.order_id}`);
  console.log(`[WAREHOUSE] Product: ${order.product_id} x ${order.quantity} units`);
  await sleep(50);
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}