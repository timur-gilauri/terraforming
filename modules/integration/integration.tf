variable "api_data" {
  type = object({
    api_id = string
    endpoints = object({
      list = object({
        resource_id = string
        http_method = string
      })
      items = object({
        resource_id = string
        http_method = string
      })
    })
  })
}

variable "lambda_data" {
  type = map(string)
}

resource "aws_api_gateway_integration" "integration" {
  for_each = var.lambda_data

  rest_api_id             = var.api_data.api_id
  resource_id             = var.api_data.endpoints[each.key]["resource_id"]
  http_method             = var.api_data.endpoints[each.key]["http_method"]
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = each.value
}