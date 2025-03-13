# Create the S3 bucket for MongoDB backups
resource "aws_s3_bucket" "mongo_backup" {
  bucket = "wizinsecurity-mongo-backups"

  tags = {
    Name        = "MongoDB Backups"
    Environment = "Production"
  }
}

# Ensure the bucket allows public read access (NO ACLs needed)
resource "aws_s3_bucket_policy" "mongo_backup_public" {
  bucket = aws_s3_bucket.mongo_backup.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:GetObject"],
        Resource  = "arn:aws:s3:::${aws_s3_bucket.mongo_backup.bucket}/*"
      },
      {
        Sid       = "PublicListBucket",
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:ListBucket"],
        Resource  = "arn:aws:s3:::${aws_s3_bucket.mongo_backup.bucket}"
      }
    ]
  })
}

# Ensure public access block settings DO NOT block public access
resource "aws_s3_bucket_public_access_block" "mongo_backup" {
  bucket                  = aws_s3_bucket.mongo_backup.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# IAM Role for MongoDB Backup (Ensuring it exists)
resource "aws_iam_role" "mongo_backup_role" {
  name = "mongo-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Backup User (Allows writing to S3)
resource "aws_iam_policy" "mongo_backup_policy" {
  name        = "MongoDBBackupPolicy"
  description = "Allows EC2 instance to write MongoDB backups to S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject"],
        Resource = "arn:aws:s3:::${aws_s3_bucket.mongo_backup.bucket}/*"
      }
    ]
  })
}

# Attach the IAM policy to the backup role
resource "aws_iam_role_policy_attachment" "mongo_backup_attachment" {
  role       = aws_iam_role.mongo_backup_role.name
  policy_arn = aws_iam_policy.mongo_backup_policy.arn
}
