variable "api_data" {
    type = object({
        api_id      = string
        resource_id = string
        http_method = string
    })
}

variable "lambda_invoke_arn" {
    type = string
}

variable "lambda_name" {
    type = string
}

locals {
    dependency = join(".", [
        "aws_lambda_function",
        var.lambda_name ])
}

resource "aws_api_gateway_integration" "list" {
    depends_on = [
        local.dependency ]

    rest_api_id             = var.api_data.api_id
    resource_id             = var.api_data.resource_id
    http_method             = var.api_data.http_method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = var.lambda_invoke_arn
}

output "name" {
    value = "list"
}