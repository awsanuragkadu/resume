terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.2.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }
  }
}
provider "random" {
  #config option
}
provider "aws" {
  region = "us-east-1"
}

resource "random_id" "rand_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "mywebapp-bucket1994" {
  bucket = "my-tf-anurag-s3-bucket-${random_id.rand_id.hex}"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mywebapp-bucket1994.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "mywebapp-bucket1994" {
  bucket = aws_s3_bucket.mywebapp-bucket1994.id
  policy = jsonencode(
    {
    Version = "2012-10-17",
    Statement = [
        {
            Sid = "PublicReadGetObject",
            Effect = "Allow",
            Principal = "*",
            Action = "s3:GetObject"
            Resource = "arn:aws:s3:::${aws_s3_bucket.mywebapp-bucket1994.id}/*"
        }
    ]
}
  )
}

resource "aws_s3_bucket_website_configuration" "mywebapp-bucket1994" {
  bucket = aws_s3_bucket.mywebapp-bucket1994.id

  index_document {
    suffix = "index.html"
  
  }
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.mywebapp-bucket1994.bucket
  source = "./index.html"
  key = "index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "styles_css" {
  bucket = aws_s3_bucket.mywebapp-bucket1994.bucket
  source = "./styles.css"
  key = "styles.css"
  content_type = "text/css"
}

output "name" {
  value = aws_s3_bucket_website_configuration.mywebapp-bucket1994.website_endpoint
}
