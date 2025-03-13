# Create OIDC Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["74F3A68F16524F15424927704C9506F55A9316BD"]
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.github_oidc.arn}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          "StringLike" = {
            "token.actions.githubusercontent.com:sub" = "repo:nsilver7/wiz-insecurity-demo:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

# Consolidated IAM Policy for EKS & ECR Access
resource "aws_iam_policy" "github_actions_policy" {
  name        = "GitHubActionsAccess"
  description = "Allow GitHub Actions to deploy to EKS and push to ECR"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup",
          "eks:DescribeFargateProfile",
          "eks:ListFargateProfiles",
          "eks:UpdateClusterConfig",
          "eks:AccessKubernetesApi",
          "eks:TagResource"
        ]
        Resource = "arn:aws:eks:us-west-2:586794482281:cluster/eks-cluster"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "arn:aws:ecr:us-west-2:586794482281:repository/app-container-repo"
      }
    ]
  })
}

# Attach the Consolidated IAM Policy to GitHub Actions Role
resource "aws_iam_role_policy_attachment" "github_actions_policy_attachment" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}
