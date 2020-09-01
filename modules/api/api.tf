resource "aws_api_gateway_rest_api" "api" {
  name = "test-api"

  endpoint_configuration {
    types = [
    "REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "get" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "list"
}

resource "aws_api_gateway_method" "method-get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.get.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_resource" "post" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "items"
}

resource "aws_api_gateway_method" "method-post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.post.id
  http_method   = "POST"
  authorization = "NONE"
}

output "data" {
  value = {
    api_id = aws_api_gateway_rest_api.api.id
    api = {
      get = {
        resource_id = aws_api_gateway_resource.get.id
        http_method = aws_api_gateway_method.method-get.http_method
      }
      post = {
        resource_id = aws_api_gateway_resource.post.id
        http_method = aws_api_gateway_method.method-post.http_method
      }
    }

  }
}

output "exec_arn" {
  value = aws_api_gateway_rest_api.api.execution_arn
}
