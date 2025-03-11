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

# this is bad, not sure if im supposed to fix this before deploy yet
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