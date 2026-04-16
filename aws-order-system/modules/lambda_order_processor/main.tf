data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "processor_access" {
  statement {
    sid = "AllowConsumeOrdersQueue"

    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage"
    ]

    resources = [var.sqs_queue_arn]
  }

  statement {
    sid = "AllowWriteOrdersTable"

    actions = [
      "dynamodb:PutItem",
      "dynamodb:UpdateItem"
    ]

    resources = [var.dynamodb_table_arn]
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

resource "aws_iam_role_policy" "processor_access" {
  name   = "${var.function_name}-processor-access"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.processor_access.json
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
        DYNAMODB_TABLE = var.dynamodb_table_name
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
    aws_iam_role_policy.processor_access
  ]
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.this.arn
  batch_size       = var.batch_size
  enabled          = true
}
