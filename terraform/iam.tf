# IAM role for Lambda execution
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Define the S3 permissions
data "aws_iam_policy_document" "lambda_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = [
      aws_s3_bucket.neo_bucket_extract.arn,
      "${aws_s3_bucket.neo_bucket_extract.arn}/*",
      aws_s3_bucket.neo_bucket_transform.arn,
      "${aws_s3_bucket.neo_bucket_transform.arn}/*"
    ]
  }
}

# Create the policy from the document
resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "neo-lambda-s3-policy"
  description = "Allows Lambda to read and write to the NEO S3 bucket"
  policy      = data.aws_iam_policy_document.lambda_s3_policy.json
}

# Attach to your Lambda role
resource "aws_iam_role_policy_attachment" "lambda_s3_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}



