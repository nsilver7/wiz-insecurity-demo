resource "aws_guardduty_detector" "gd" {
  enable = true
}

resource "aws_securityhub_account" "sh" {}
