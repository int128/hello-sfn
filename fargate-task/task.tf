resource "aws_ecs_task_definition" "task" {
  family                   = "hello-sfn-fargate-task"
  task_role_arn            = aws_iam_role.task.arn
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "this"
      image     = "public.ecr.aws/docker/library/postgres:14"
      command   = ["psql", "--version"]
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        "options" = {
          "awslogs-region"        = local.region
          "awslogs-group"         = aws_cloudwatch_log_group.task.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    },
  ])
}

resource "aws_cloudwatch_log_group" "task" {
  name              = "/ecs/hello-sfn-fargate-task"
  retention_in_days = 180
}

resource "aws_iam_role" "task" {
  name               = "hello-sfn-fargate-task-task"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
}

data "aws_iam_policy_document" "task_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "task" {
  role   = aws_iam_role.task.id
  name   = "this"
  policy = data.aws_iam_policy_document.task.json
}

data "aws_iam_policy_document" "task" {
  statement {
    effect = "Allow"
    actions = [
      # TODO: fix later
      "rds:Describe*",
      "rds:List*",
    ]
    resources = ["*"]
  }
}
