terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.27.0"
    }
  }
}

provider "aws" {
  region= '"ap-south-1"
}
resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.27.0"
    }
  }
}

provider "aws" {
  region= "ap-south-1"
}
resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}
resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.test_role.name
  policy_arn = aws_iam_policy.policy.arn
}
