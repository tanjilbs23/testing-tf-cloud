provider "aws" {}

resource "aws_s3_bucket" "b" {
  bucket = "my-test-bucket-sharebus-september21"

  tags = {
    Name        = "my-test-bucket-sharebus-september21"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}