provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "api" {
  source = "./modules/api"
}

module "lambda" {
  source = "./modules/lambda"

  bucket_data  = jsondecode(file("./bucket_data.json"))
  api_exec_arn = module.api.exec_arn

  depends_on = [
  module.api]
}

module "integration" {
  source = "./modules/integration"

  api_data    = module.api.data
  lambda_data = module.lambda.data

  depends_on = [
    module.api,
  module.lambda]
}

module "deploy" {
  source = "./modules/deploy"

  api_id = module.api.data.api_id
  depends_on = [
  module.integration]
}