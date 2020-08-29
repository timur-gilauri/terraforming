variable "handler_path" {
    type = string
}

variable "output_path" {
    type = string
}

locals {
    bucket_name = "my.bucket.to.test.terraform"
    handler_key = "my.handler.to.test.lambda"
}

data "archive_file" "lambda_zip" {
    type        = "zip"
    source_file = var.handler_path
    output_path = var.output_path
}



resource "aws_s3_bucket" "bucket" {
    bucket = local.bucket_name
}

resource "aws_s3_bucket_object" "object" {
    depends_on = [
        aws_s3_bucket.bucket ]

    bucket = local.bucket_name
    key    = local.handler_key
    source = var.output_path

    etag = filemd5(var.output_path)
}

output "key" {
    value = local.handler_key
}

output "name" {
    value = local.bucket_name
}

output "bucket_object_name" {
    value = "object"
}