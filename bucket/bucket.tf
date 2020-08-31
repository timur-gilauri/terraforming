terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "1.4.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

locals {
  bucket_data_path = "../bucket_data.json"
  zip_name         = "lambda.zip"
  handler_path     = "../assets/index.js"
  output_path      = "../assets/tmp/${local.zip_name}"
  salt             = filemd5(local.handler_path)
  bucket_name      = "my.bucket.to.test.terraform"
  handler_key      = "my.handler.to.test.lambda.${local.salt}"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = local.handler_path
  output_path = local.output_path
}

resource "aws_s3_bucket" "bucket" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_object" "object" {
  depends_on = [
  aws_s3_bucket.bucket]

  bucket = local.bucket_name
  key    = local.handler_key
  source = local.output_path

  provisioner "local-exec" {
    command    = "rm -rf ${local.bucket_data_path}"
    on_failure = continue
  }
}

resource "local_file" "test" {
  depends_on = [
  aws_s3_bucket_object.object]
  content = jsonencode({
    bucket_name = local.bucket_name,
    handler_key = local.handler_key
  })
  filename = local.bucket_data_path
}
