data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sqs_send" {
  statement {
    sid = "AllowSendMessageToOrdersQueue"

    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:SendMessage"
    ]

    resources = [var.sqs_queue_arn]
  }
}

data "aws_iam_policy_document" "dynamodb_read" {
  statement {
    sid = "AllowReadOrdersTable"

    actions = [
      "dynamodb:GetItem"
    ]

    resources = [var.dynamodb_table_arn]
  }
}

data "aws_iam_policy_document" "counter_write" {
  statement {
    sid = "AllowUpdateCounterTable"

    actions = [
      "dynamodb:UpdateItem"
    ]

    resources = [var.counter_table_arn]
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(
    var.tags,
    {
      Name      = "${var.function_name}-role"
      Component = "lambda"
    }
  )
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "sqs_send" {
  name   = "${var.function_name}-sqs-send"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.sqs_send.json
}

resource "aws_iam_role_policy" "dynamodb_read" {
  name   = "${var.function_name}-dynamodb-read"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.dynamodb_read.json
}

resource "aws_iam_role_policy" "counter_write" {
  name   = "${var.function_name}-counter-write"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.counter_write.json
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.this.arn
  runtime       = var.runtime
  architectures = [var.architecture]
  handler       = var.handler
  timeout       = var.timeout
  memory_size   = var.memory_size

  filename         = var.package_file
  source_code_hash = filebase64sha256(var.package_file)

  environment {
    variables = merge(
      var.environment_variables,
      {
        SQS_QUEUE_URL  = var.sqs_queue_url
        DYNAMODB_TABLE = var.dynamodb_table_name
        COUNTER_TABLE  = var.counter_table_name
      }
    )
  }

  tags = merge(
    var.tags,
    {
      Name      = var.function_name
      Component = "lambda"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.basic_execution,
    aws_iam_role_policy.sqs_send,
    aws_iam_role_policy.dynamodb_read,
    aws_iam_role_policy.counter_write
  ]
}
