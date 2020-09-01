variable "bucket_data" {
  type = object({
    bucket_name = string,
    handlers    = map(string)
  })
}

variable "api_exec_arn" {
  type = string
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

resource "aws_lambda_function" "lambda" {
  for_each = var.bucket_data.handlers

  function_name = "lambda-${each.key}"

  s3_bucket = var.bucket_data.bucket_name
  s3_key    = each.value

  handler = "${each.key}.handler"
  runtime = "nodejs10.x"

  role = aws_iam_role.role.arn
}

resource "aws_iam_policy" "dynamodb" {
  name = "lambda_dynamodb_policy"

  policy = file("${path.module}/policy.dynamodb.json")
}

resource "aws_lambda_permission" "apigw_lambda" {
  for_each = var.bucket_data.handlers

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "lambda-${each.key}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_exec_arn}/*/*"
}

resource "aws_iam_role_policy_attachment" "dynamodb" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.dynamodb.arn
}

output "data" {
  value = { for k, v in aws_lambda_function.lambda : k => v.invoke_arn }
}