provider "aws" {
    profile = "default"
    region  = "us-east-1"
}

module "bucket" {
    source = "./modules/bucket"

    handler_path = "${path.module}/assets/index.js"
    output_path  = "${path.module}/assets/tmp/lambda.zip"
}

module "dynamodb" {
    source = "./modules/dynamodb"

    source_path = "${path.module}/assets/players.json"
}

module "api" {
    source = "./modules/api"
}

module "lambda" {
    source = "./modules/lambda"

    bucket_name  = module.bucket.name
    handler_key  = module.bucket.key
    api_exec_arn = module.api.exec_arn

    depends_on = [
        module.bucket ]
}

module "integration" {
    source = "./modules/integration"

    api_data          = module.api.data
    lambda_invoke_arn = module.lambda.invoke_arn
    lambda_name       = module.lambda.name

    depends_on = [
        module.api,
        module.lambda ]
}

module "deploy" {
    source = "./modules/deploy"

    api_id               = module.api.data.api_id
    integration_name     = module.integration.name
    invoke_url_save_path = "${path.module}/assets/tmp/invoke-url"

    depends_on = [
        module.integration ]
}