resource "aws_iam_role" "this" {
  name = "ecs_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "task_role" {
  name = "task_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "this" {
  name = "ecs_execution_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}


resource "aws_iam_role" "task" {
  name = "ecs_task_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

}

resource "aws_iam_policy" "task" {
  name = "ecs-task_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "ssmmessages:OpenDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:CreateControlChannel"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "task" {
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.task.arn
}


resource "aws_ecs_task_definition" "application-iaac" {
  family                   = "application-iaac"
  execution_role_arn       = aws_iam_role.this.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.task_role.arn
  cpu                      = "1024"
  memory                   = "3072"
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "wordpress",
    "image": "docker.io/zain1824/web:latest",
    "cpu": 0,
    "portMappings": [
      {
        "name": "wordpress-80-tcp",
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp",
        "appProtocol": "http"
      }
    ],
    "essential": true,
    "environment": [],
    "environmentFiles": [],
    "mountPoints": [],
    "volumesFrom": [],
    "ulimits": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/application",
        "awslogs-create-group": "true",
        "awslogs-region": "us-east-2",
        "awslogs-stream-prefix": "ecs"
      },
      "secretOptions": []
    },
    "systemControls": []
  }
]
TASK_DEFINITION
}



resource "aws_ecs_service" "wordpress-app" {
  name            = "wordpress-app"
  cluster         = "class3"
  task_definition = aws_ecs_task_definition.application-iaac.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    assign_public_ip = true
    subnets = [
      aws_default_subnet.default_az1.id,
      aws_default_subnet.default_az2.id,
    ]
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "${var.region}a"
  tags = {
    Name = "Default subnet for ${var.region}a"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "${var.region}b"
  tags = {
    Name = "Default subnet for ${var.region}b"
  }
}