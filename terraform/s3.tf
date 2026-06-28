resource "aws_s3_bucket" "neo_bucket_extract" {
  bucket_prefix = "neo-extracted-"
  force_destroy = true
  tags = {
    Name = "neo-bucket-extract"
  }
}

resource "aws_s3_bucket" "neo_bucket_transform" {
  bucket_prefix = "neo-transformed-"
  force_destroy = true
  tags = {
    Name = "neo-bucket-transform"
  }
}