resource "aws_sfn_state_machine" "helloworld" {
  name       = "helloworld"
  definition = file("${path.module}/helloworld.json")
  role_arn   = aws_iam_role.helloworld.arn
}

resource "aws_iam_role" "helloworld" {
  name               = "sfn-helloworld"
  assume_role_policy = data.aws_iam_policy_document.helloworld_assume_role.json
}

data "aws_iam_policy_document" "helloworld_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.us-west-2.amazonaws.com"]
    }
  }
}
