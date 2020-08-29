variable "bucket_name" {
    type = string
}

variable "handler_key" {
    type = string
}

variable "api_exec_arn" {
    type = string
}

resource "aws_lambda_function" "lambda" {

    function_name = "ServerlessLambdaFunction"

    s3_bucket = var.bucket_name
    s3_key    = var.handler_key

    handler = "index.handler"
    runtime = "nodejs10.x"

    role = aws_iam_role.role.arn
}

resource "aws_lambda_permission" "apigw_lambda" {
    statement_id  = "AllowExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda.function_name
    principal     = "apigateway.amazonaws.com"

    source_arn = "${var.api_exec_arn}/*/*"
}

resource "aws_iam_role" "role" {
    name = "serverles_lambda"

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

output "invoke_arn" {
    value = aws_lambda_function.lambda.invoke_arn
}

output "name" {
    value = "lambda"
}