resource "aws_cloudwatch_event_rule" "sfn" {
  name        = "sfn-DeleteDatabases"
  description = "Delete all databases every night"

  schedule_expression = "cron(10 13 * * ? *)" # JST 22:10
}

resource "aws_cloudwatch_event_target" "sfn" {
  rule     = aws_cloudwatch_event_rule.sfn.name
  arn      = aws_sfn_state_machine.main.arn
  role_arn = aws_iam_role.eventbridge_sfn.arn
}

resource "aws_iam_role" "eventbridge_sfn" {
  name               = "eventbridge-sfn-DeleteDatabases"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_sfn_assume_role.json
}

data "aws_iam_policy_document" "eventbridge_sfn_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "eventbridge_sfn" {
  role   = aws_iam_role.eventbridge_sfn.id
  name   = "rds"
  policy = data.aws_iam_policy_document.eventbridge_sfn_policy.json
}

data "aws_iam_policy_document" "eventbridge_sfn_policy" {
  statement {
    actions = [
      "states:StartExecution",
    ]
    resources = [
      aws_sfn_state_machine.main.arn,
    ]
  }
}
