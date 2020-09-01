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
  handlers_path    = "../assets/handlers"
  output_path      = "../assets/tmp"
  config           = jsondecode(file("${local.handlers_path}/config.json"))
  bucket_name      = "my.bucket.to.test.terraform"
  handler_key_base = "my.handler.to.test.lambda"
}

data "archive_file" "get_zip" {
  for_each = fileset(local.handlers_path, "*.js")

  type        = "zip"
  source_file = "${local.handlers_path}/${each.value}"
  output_path = "${local.output_path}/${trimsuffix(each.value, ".js")}.zip"
}

resource "aws_s3_bucket" "bucket" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_object" "handler" {
  depends_on = [
  aws_s3_bucket.bucket]


  for_each = fileset(local.handlers_path, "*.js")

  bucket = local.bucket_name
  key    = "${local.handler_key_base}.${filemd5("${local.handlers_path}/${each.value}")}"
  source = "${local.output_path}/${trimsuffix(each.value, ".js")}.zip"

  provisioner "local-exec" {
    command    = "rm -rf ${local.bucket_data_path}"
    on_failure = continue
  }
}

resource "local_file" "test" {
  depends_on = [
  aws_s3_bucket_object.handler]

  content = jsonencode({
    bucket_name = local.bucket_name,
    handlers    = { for handler in local.config : handler["url"] => "${local.handler_key_base}.${filemd5("${local.handlers_path}/${handler["path"]}")}" }
  })
  filename = local.bucket_data_path
}
