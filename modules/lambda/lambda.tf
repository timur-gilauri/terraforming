variable "bucket_data" {
  type = object({
    bucket_name = string,
    handler_key = string
  })
}

variable "api_exec_arn" {
  type = string
}

resource "aws_lambda_function" "lambda" {

  function_name = "ServerlessLambdaFunction"

  s3_bucket = var.bucket_data.bucket_name
  s3_key    = var.bucket_data.handler_key

  handler = "index.handler"
  runtime = "nodejs10.x"

  role = aws_iam_role.role.arn
}

resource "aws_iam_role" "role" {
  name = "serverless_lambda"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY

}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_exec_arn}/*/*"
}

resource "aws_iam_policy" "dynamodb" {
  name = "lambda_dynamo_db"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "ReadWriteTable",
        "Effect": "Allow",
        "Action": [
            "dynamodb:Scan"
        ],
        "Resource": "arn:aws:dynamodb:*:*:table/*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "dynamodb" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.dynamodb.arn
}

output "invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}

output "name" {
  value = "lambda"
}