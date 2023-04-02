# Create a public s3 bucket with 2 folders
resource "aws_s3_bucket" "is434-last-sem-best-sem" {
  force_destroy = true
  bucket        = "is434-last-sem-best-sem"
}