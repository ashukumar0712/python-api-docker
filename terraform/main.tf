# Create ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "flask-app-cluster"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# IAM role to give tasks the correct permissions to execute
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create ECS Task and its Definition
resource "aws_ecs_task_definition" "flask_app_task" {
  family                   = "flask-app-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "flask-app-task",
      "image": "${var.ecr_repo_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # use Fargate as the launch type
  network_mode             = "awsvpc"    # add the AWS VPN network mode as this is required for Fargate
  memory                   = 512         # Specify the memory the container requires
  cpu                      = 256         # Specify the CPU the container requires
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

# Create ECS Service
resource "aws_ecs_service" "flask-app-service" {
    name            = "flask-app-service"                             # Naming our first service
    cluster         = "${aws_ecs_cluster.my_cluster.id}"             # Referencing our created Cluster
    task_definition = "${aws_ecs_task_definition.flask_app_task.arn}" # Referencing the task our service will spin up
    launch_type     = "FARGATE"
    desired_count   = 3 # Setting the number of containers we want deployed to 3

    load_balancer {
        target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our target group
        container_name   = "${aws_ecs_task_definition.flask_app_task.family}"
        container_port   = 5000 # Specifying the container port
    }

    network_configuration {
        subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
        assign_public_ip = true # Providing our containers with public IPs
        security_groups  = ["${aws_security_group.service_security_group.id}"] 
    }
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}



