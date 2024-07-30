terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.60.0"
    }
  }
}

provider "aws" {
  region     = "us-west-2"
  access_key = "AKIATCKASNF2QNWCLBOU"
  secret_key = "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"
}

resource "aws_iam_role" "lambda_role" {
  name = "terraform_lambda_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
  name        = "lambda_policy"
  path        = "/"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

data "archive_file" "zip_the_python_code" {
    type = "zip"
    source_dir = "${path.module}/python/"
    output_path = "${path.module}/python/hello-python.zip"

}


resource "aws_lambda_function" "terraform_lambda_func" {
  filename = "${path.module}/python/hello-python.zip"
  function_name = "jhooq-lambda-function"
  role = aws_iam_role.lambda_role.arn
  handler = "hello-python.lambda_handler"
  runtime = "python3.8"
  depends_on = [ aws_iam_role_policy_attachment.test-attach ]
}