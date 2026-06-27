resource "aws_s3_bucket" "neo_bucket" {
  bucket_prefix = "neo-data-lake-"

  tags = {
    Name        = "neo-bucket"
  }
}