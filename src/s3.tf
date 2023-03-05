resource "random_integer" "bucket_id" {
  min = 1
  max = 50000
}

resource "aws_s3_bucket" "raw-input" {
  bucket = "raw-input-gtakeout-files-${random_integer.bucket_id.result}"
}

resource "aws_s3_bucket" "enriched-input" {
  bucket = "enriched-output-files-${random_integer.bucket_id.result}"
}

resource "aws_s3_bucket" "pre-processing-input" {
  bucket = "pre-processing-output-files-${random_integer.bucket_id.result}"
}