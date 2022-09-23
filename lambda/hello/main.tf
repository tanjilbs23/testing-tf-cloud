# Building GO Lambda

resource "null_resource" "lambda_build" {
  # triggers = {
  #   always_run = "${timestamp()}"
  # }
  triggers = {
    on_every_apply = uuid()
  }
  provisioner "local-exec" {
    command = "cd lambda/hello/src && wget https://go.dev/dl/go1.19.1.linux-amd64.tar.gz && tar -xzf go1.19.1.linux-amd64.tar.gz && env GOOS=linux GOARCH=amd64 go/bin/go build -o ../bin/hello"
  }
}

# Zip Lambda package

data "archive_file" "lambda_go_zip" {

  type        = "zip"
  source_file = "${path.module}/bin/hello"
  output_path = "${path.module}/bin/hello.zip"
  depends_on = [
      null_resource.lambda_build
  ]
}

# Lambda Module
module "lambda_function" {
  source        = "terraform-aws-modules/lambda/aws"
  function_name = "hello2"
  description   = "testing go function"
  handler       = "hello.lambda_handler"
  runtime       = "go1.x"
  publish       = true

  create_package          = false
  local_existing_package  = "${path.module}/bin/hello.zip"

  trusted_entities = [
    {
      type = "Service",
      identifiers = [
        "appsync.amazonaws.com"
      ]
    }
  ]

  tags = {
    Name = "hello_go"
  }

  depends_on = [
    data.archive_file.lambda_go_zip
  ]
}
module "alias_refresh" {
  source = "terraform-aws-modules/lambda/aws//modules/alias"

  name          = "current-with-refresh"
  function_name = module.lambda_function.lambda_function_name
}