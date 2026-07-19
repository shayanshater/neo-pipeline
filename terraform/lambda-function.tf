# Package the extract Lambda function code
data "archive_file" "extract_function" {
  type        = "zip"
  source_file = "${path.module}/../lambda/extract.py"
  output_path = "${path.module}/../lambda/extract.zip"
}

# extract Lambda function
resource "aws_lambda_function" "lambda_function_extract" {
  filename      = data.archive_file.extract_function.output_path
  function_name = "neo_extract_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "extract.lambda_handler"
  runtime       = var.python_runtime
  layers        = [aws_lambda_layer_version.extract_layer.arn]
  timeout       = 30  # seconds — increase this
  memory_size   = 128 # MB — optionally increase if needed

  source_code_hash = data.archive_file.extract_function.output_base64sha256

  environment {
    variables = {
      NASA_API_KEY   = var.nasa_api_key
      S3_BUCKET_NAME = aws_s3_bucket.neo_bucket_extract.bucket
    }
  }

  tags = {
    Name = "neo-lambda-function-extract"
  }
}


############################
#transform lambda function


data "archive_file" "transform_function" {
  type        = "zip"
  source_file = "${path.module}/../lambda/transform.py"
  output_path = "${path.module}/../lambda/transform.zip"
}

resource "aws_lambda_function" "lambda_function_transform" {
  filename      = data.archive_file.transform_function.output_path
  function_name = "neo_transform_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "transform.lambda_handler"
  runtime       = var.python_runtime
  layers = [
    var.aws_wrangler_ami
  ]
  timeout     = 120 # seconds — increase this
  memory_size = 256 # MB — optionally increase if needed

  source_code_hash = data.archive_file.transform_function.output_base64sha256

  environment {
    variables = {
      S3_BUCKET_NAME           = aws_s3_bucket.neo_bucket_extract.bucket
      S3_TRANSFORM_BUCKET_NAME = aws_s3_bucket.neo_bucket_transform.bucket
    }
  }

  tags = {
    Name = "neo-lambda-function-transform"
  }
}

data "aws_caller_identity" "current" {}


# S3 bucket notification - triggers Lambda on object creation
resource "aws_s3_bucket_notification" "uploads" {
  bucket = aws_s3_bucket.neo_bucket_extract.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_function_transform.arn
    events              = ["s3:ObjectCreated:*"]

    # Only trigger for files in the "raw/" prefix
    filter_prefix = "raw/"

    # Only trigger for JSON files
    filter_suffix = ".json"
  }

  # This depends on the Lambda permission being created first
  depends_on = [aws_lambda_permission.s3_invoke_transform]
}

# Permission for S3 to invoke the Lambda function
resource "aws_lambda_permission" "s3_invoke_transform" {
  statement_id   = "AllowS3Invoke"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.lambda_function_transform.function_name
  principal      = "s3.amazonaws.com"
  source_arn     = aws_s3_bucket.neo_bucket_extract.arn
  source_account = data.aws_caller_identity.current.account_id
}



###########################################
##LOAD lmabda function


data "archive_file" "load_function" {
  type        = "zip"
  source_file = "${path.module}/../lambda/load.py"
  output_path = "${path.module}/../lambda/load.zip"
}

resource "aws_lambda_function" "lambda_function_load" {
  filename      = data.archive_file.load_function.output_path
  function_name = "neo_load_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "load.lambda_handler"
  runtime       = var.python_runtime
  layers = [
    var.aws_wrangler_ami,
    aws_lambda_layer_version.extract_layer.arn
  ]
  timeout     = 120 # seconds — increase this
  memory_size = 256 # MB — optionally increase if needed

  source_code_hash = data.archive_file.load_function.output_base64sha256

  environment {
    variables = {
      DB_HOST     = var.db_host
      DB_PORT     = var.db_port
      DB_NAME     = var.db_name
      DB_USER     = var.db_user
      DB_PASSWORD = var.db_password
    }
  }

  tags = {
    Name = "neo-lambda-function-load"
  }
}



# S3 bucket notification - triggers Lambda on object creation
resource "aws_s3_bucket_notification" "uploads_transform" {
  bucket = aws_s3_bucket.neo_bucket_transform.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_function_load.arn
    events              = ["s3:ObjectCreated:*"]

    # Only trigger for files in the "raw/" prefix
    filter_prefix = "processed/"

    # Only trigger for JSON files
    filter_suffix = ".parquet"
  }

  # This depends on the Lambda permission being created first
  depends_on = [aws_lambda_permission.s3_invoke_load]
}

# Permission for S3 to invoke the Lambda function
resource "aws_lambda_permission" "s3_invoke_load" {
  statement_id   = "AllowS3Invoke"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.lambda_function_load.function_name
  principal      = "s3.amazonaws.com"
  source_arn     = aws_s3_bucket.neo_bucket_transform.arn
  source_account = data.aws_caller_identity.current.account_id
}