resource "aws_s3_bucket" "example" {
  bucket_prefix = "neo-data-lake-"

  tags = {
    Name        = "neo-bucket"
  }
}

