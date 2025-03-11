resource "aws_iam_role" "db_vm_role" {
  name = "db_vm_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Overly permissive policy for the database VM (intentionally insecure for the exercise)
resource "aws_iam_policy" "db_vm_policy" {
  name        = "db_vm_policy"
  description = "Overly permissive policy for the database VM."
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "*",
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "db_vm_attach" {
  role       = aws_iam_role.db_vm_role.name
  policy_arn = aws_iam_policy.db_vm_policy.arn
}

# Create an instance profile for the DB VM so it can assume the above IAM role.
resource "aws_iam_instance_profile" "db_vm_instance_profile" {
  name = "db-vm-instance-profile"
  role = aws_iam_role.db_vm_role.name
}

output "db_vm_instance_profile_name" {
  description = "The name of the instance profile for the database VM."
  value       = aws_iam_instance_profile.db_vm_instance_profile.name
}
