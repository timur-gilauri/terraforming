resource "aws_api_gateway_rest_api" "api" {
    name = "test-api"

    endpoint_configuration {
        types = [
            "REGIONAL" ]
    }
}

resource "aws_api_gateway_resource" "resource" {
    rest_api_id = aws_api_gateway_rest_api.api.id
    parent_id   = aws_api_gateway_rest_api.api.root_resource_id
    path_part   = "list"
}

resource "aws_api_gateway_method" "method" {
    rest_api_id   = aws_api_gateway_rest_api.api.id
    resource_id   = aws_api_gateway_resource.resource.id
    http_method   = "GET"
    authorization = "NONE"
}

output "data" {
    value = {
        api_id      = aws_api_gateway_rest_api.api.id
        resource_id = aws_api_gateway_resource.resource.id
        http_method = aws_api_gateway_method.method.http_method
    }
}

output "exec_arn" {
    value = aws_api_gateway_rest_api.api.execution_arn
}
