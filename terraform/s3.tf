resource "aws_s3_bucket" "mongo_backup" {
  bucket        = "wizinsecurity-mongo-backups-${var.aws_region}"
  force_destroy = true
}

# Enable bucket versioning (optional, but useful)
resource "aws_s3_bucket_versioning" "mongo_backup_versioning" {
  bucket = aws_s3_bucket.mongo_backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable public read access for all objects
resource "aws_s3_bucket_policy" "mongo_backup_public" {
  bucket = aws_s3_bucket.mongo_backup.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:GetObject"],
        Resource  = "${aws_s3_bucket.mongo_backup.arn}/*"
      },
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:ListBucket"],
        Resource  = aws_s3_bucket.mongo_backup.arn
      }
    ]
  })
}
