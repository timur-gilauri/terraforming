variable "integration_name" {
    type = string
}

variable "api_id" {
    type = string
}

variable "invoke_url_save_path" {
    type = string
}

locals {
    integration_name = join(".", [
        "aws_api_gateway_integration",
        var.integration_name ])
}

resource "aws_api_gateway_deployment" "deployment" {
    depends_on = [
        local.integration_name
    ]

    rest_api_id = var.api_id
    stage_name  = "test"

    lifecycle {
        create_before_destroy = true
    }

    provisioner "local-exec" {
        command = "echo invoke url: ${aws_api_gateway_deployment.deployment.invoke_url} >> ${var.invoke_url_save_path}"
    }
}

output "invoke_url" {
    value = aws_api_gateway_deployment.deployment.invoke_url
}