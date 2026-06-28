resource "aws_cloudwatch_log_group" "extract_lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function_extract.function_name}"
  retention_in_days = 3
  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_cloudwatch_log_group" "transform_lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function_transform.function_name}"
  retention_in_days = 3
  lifecycle {
    ignore_changes = [name]
  }
}