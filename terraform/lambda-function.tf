# Package the Lambda function code
data "archive_file" "extract_function" {
  type        = "zip"
  source_file = "${path.module}/../lambda/extract.py"
  output_path = "${path.module}/../lambda/extract.zip"
}

# Lambda function
resource "aws_lambda_function" "lambda-function" {
  filename      = data.archive_file.extract_function.output_path
  function_name = "neo_extract_function"
  role          = aws_iam_role.example.arn
  handler       = "extract.lambda_handler"
  runtime       = var.python_runtime
  layers = [aws_lambda_layer_version.extract_layer.arn]

  environment {
    variables = {
      NASA_API_KEY = var.nasa_api_key
    }
  }

  tags = {
    Name = "neo-lambda-function"
  }
}