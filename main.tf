provider "aws" {
  access_key = "mock_access_key"
  secret_key = "mock_secret_key"
  region     = "us-east-1"
  endpoints {
    dynamodb = "http://localhost:4566"
    iam      = "http://localhost:4566"
  }
}

resource "aws_dynamodb_table" "parsley" {
  name           = "parsley"
  hash_key       = "Parsley-1"
  range_key      = "Parsley-2"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "Parsley-1"
    type = "S"
  }

  attribute {
    name = "Parsley-2"
    type = "N"
  }
}

resource "aws_iam_policy" "read_write" {
  name        = "read_write"
  description = "Read/Write access policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_dynamodb_table.parsley.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "read_only" {
  name        = "read_only"
  description = "Read-only access policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:Scan",
        "dynamodb:Query"
      ],
      "Effect": "Allow",
      "Resource": "${aws_dynamodb_table.parsley.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_user" "developer" {
  name = "developer"
  path = "/developers/"
}

resource "aws_iam_user" "product_manager" {
  name = "product_manager"
  path = "/product_managers/"
}

resource "aws_iam_user_policy_attachment" "developer_policy_attachment" {
  user       = aws_iam_user.developer.name
  policy_arn = aws_iam_policy.read_write.arn
}

resource "aws_iam_user_policy_attachment" "product_manager_policy_attachment" {
  user       = aws_iam_user.product_manager.name
  policy_arn = aws_iam_policy.read_only.arn
}
