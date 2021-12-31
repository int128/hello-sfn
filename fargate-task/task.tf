data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_ecs_task_definition" "this_task" {
  family                   = "hello-sfn-fargate-task"
  task_role_arn            = aws_iam_role.this_task.arn
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
          "awslogs-group"         = aws_cloudwatch_log_group.this_task.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    },
  ])
}

resource "aws_cloudwatch_log_group" "this_task" {
  name              = "/ecs/hello-sfn-fargate-task"
  retention_in_days = 180
}

resource "aws_iam_role" "this_task" {
  name               = "hello-sfn-fargate-task-task"
  assume_role_policy = data.aws_iam_policy_document.this_task_assume_role_policy.json
}

data "aws_iam_policy_document" "this_task_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "this_task" {
  role   = aws_iam_role.this_task.id
  name   = "this"
  policy = data.aws_iam_policy_document.this_task.json
}

data "aws_iam_policy_document" "this_task" {
  statement {
    effect = "Allow"
    actions = [
      # TODO: fix later
    ]
    resources = ["*"]
  }
}
