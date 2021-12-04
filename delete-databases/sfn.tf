resource "aws_sfn_state_machine" "main" {
  name       = "DeleteDatabases"
  definition = file("${path.module}/sfn.json")
  role_arn   = aws_iam_role.sfn.arn
}

resource "aws_iam_role" "sfn" {
  name               = "sfn-DeleteDatabases"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume_role.json
}

data "aws_iam_policy_document" "sfn_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.us-west-2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "sfn" {
  role   = aws_iam_role.sfn.id
  name   = "rds"
  policy = data.aws_iam_policy_document.sfn_policy.json
}

data "aws_iam_policy_document" "sfn_policy" {
  statement {
    actions = [
      "rds:describeDBInstances",
      "rds:deleteDBInstance",
    ]
    resources = ["*"]
  }
}
