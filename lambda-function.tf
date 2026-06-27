# Package the Lambda function code
data "archive_file" "function" {
  type        = "zip"
  source_file = "${path.module}/lambda/main.js"
  output_path = "${path.module}/lambda/function.zip"
}

# Lambda function
resource "aws_lambda_function" "lambda-function" {
  filename      = data.archive_file.function.output_path
  function_name = "example_lambda_function"
  role          = aws_iam_role.example.arn
  handler       = "index.handler"
  code_sha256   = data.archive_file.example.output_base64sha256

  runtime = var.python_runtime


  tags = {
    Name = "neo-lambda-function"
  }
}