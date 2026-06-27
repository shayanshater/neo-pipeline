resource "aws_s3_bucket" "neo_bucket" {
  bucket_prefix = "neo-data-lake-"
  force_destroy = true
  tags = {
    Name = "neo-bucket"
  }
}