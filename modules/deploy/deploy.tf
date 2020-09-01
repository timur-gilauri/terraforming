variable "api_id" {
  type = string
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = var.api_id
  stage_name  = "test"

  lifecycle {
    create_before_destroy = true
  }
}