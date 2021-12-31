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
            "TaskDefinition" : aws_ecs_task_definition.this_task.arn,
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
  name               = "hello-sfn-fargate-task"
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
