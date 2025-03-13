# Create the S3 bucket for MongoDB backups
resource "aws_s3_bucket" "mongo_backup" {
  bucket = "wizinsecurity-mongo-backups"

  tags = {
    Name        = "MongoDB Backups"
    Environment = "Production"
  }
}

# Apply public-read ACL using the recommended aws_s3_bucket_acl resource
resource "aws_s3_bucket_acl" "mongo_backup_acl" {
  bucket = aws_s3_bucket.mongo_backup.id
  acl    = "public-read"
}

# Disable public access blocking (required for public policies)
resource "aws_s3_bucket_public_access_block" "mongo_backup" {
  bucket = aws_s3_bucket.mongo_backup.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Attach a policy that makes the backups publicly readable
resource "aws_s3_bucket_policy" "mongo_backup_public" {
  bucket = aws_s3_bucket.mongo_backup.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowPublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "arn:aws:s3:::${aws_s3_bucket.mongo_backup.bucket}/*"
      },
      {
        Sid       = "AllowListBucket"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:ListBucket"]
        Resource  = "arn:aws:s3:::${aws_s3_bucket.mongo_backup.bucket}"
      }
    ]
  })
}

# IAM Policy for Backup User (Optional: Attach to EC2 if using AWS CLI for backups)
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

# Attach the IAM policy to an IAM Role (if backing up from an EC2 instance)
resource "aws_iam_role_policy_attachment" "mongo_backup_attachment" {
  role       = "mongo-backup-role" # Make sure this IAM role exists on your instance
  policy_arn = aws_iam_policy.mongo_backup_policy.arn
}
