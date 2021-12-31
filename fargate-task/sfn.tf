resource "aws_sfn_state_machine" "sfn" {
  name     = "hello-sfn-fargate-task"
  role_arn = aws_iam_role.sfn.arn
  definition = jsonencode(
    {
      "StartAt" : "RunTask",
      "States" : {
        "RunTask" : {
          "Type" : "Task",
          "Resource" : "arn:aws:states:::ecs:runTask.sync",
          "Parameters" : {
            "LaunchType" : "FARGATE",
            "Cluster" : aws_ecs_cluster.this.arn,
            "TaskDefinition" : aws_ecs_task_definition.task.arn,
            "NetworkConfiguration" : {
              "AwsvpcConfiguration" : {
                "Subnets" : data.aws_subnets.default.ids,
                "AssignPublicIp" : "ENABLED"
              }
            }
          },
          "End" : true
        }
      }
    }
  )
}

resource "aws_iam_role" "sfn" {
  name               = "hello-sfn-fargate-task-sfn"
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
  name   = "this"
  policy = data.aws_iam_policy_document.sfn.json
}

data "aws_iam_policy_document" "sfn" {
  // https://docs.amazonaws.cn/en_us/step-functions/latest/dg/ecs-iam.html
  statement {
    effect = "Allow"
    actions = [
      "ecs:RunTask",
    ]
    resources = [
      aws_ecs_task_definition.task.arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecs:StopTask",
      "ecs:DescribeTasks",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "events:PutTargets",
      "events:PutRule",
      "events:DescribeRule",
    ]
    resources = [
      "arn:aws:events:*:*:rule/StepFunctionsGetEventsForECSTaskRule",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      aws_iam_role.task.arn,
      data.aws_iam_role.ecs_task_execution_role.arn,
    ]
  }
}
