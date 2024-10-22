resource "aws_s3_bucket" "example_bucket" {
  bucket = "my-terraform-generated-bucket-ajs"  # Replace with your bucket name

  tags = {
    Name        = "My S3 Bucket"
    Environment = "Dev"
  }
}
