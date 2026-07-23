data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = var.common_tags
}

resource "aws_launch_template" "read" {
  name_prefix   = "${var.project_name}-${var.environment}-read-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.ec2_instance_type

  iam_instance_profile {
    name = var.ecs_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.ecs_security_group_id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.this.name} >> /etc/ecs/ecs.config
    echo 'ECS_INSTANCE_ATTRIBUTES={"node-type":"read"}' >> /etc/ecs/ecs.config
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.project_name}-${var.environment}-read-node"
    })
  }
}

resource "aws_launch_template" "write" {
  name_prefix   = "${var.project_name}-${var.environment}-write-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.ec2_instance_type

  iam_instance_profile {
    name = var.ecs_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.ecs_security_group_id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.this.name} >> /etc/ecs/ecs.config
    echo 'ECS_INSTANCE_ATTRIBUTES={"node-type":"write"}' >> /etc/ecs/ecs.config
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.project_name}-${var.environment}-write-node"
    })
  }
}

resource "aws_autoscaling_group" "read" {
  name                = "${var.project_name}-${var.environment}-read-asg"
  min_size            = var.read_min_size
  max_size            = var.read_max_size
  desired_capacity    = var.read_desired_capacity
  vpc_zone_identifier = var.private_app_subnet_ids

  launch_template {
    id      = aws_launch_template.read.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "write" {
  name                = "${var.project_name}-${var.environment}-write-asg"
  min_size            = var.write_min_size
  max_size            = var.write_max_size
  desired_capacity    = var.write_desired_capacity
  vpc_zone_identifier = var.private_app_subnet_ids

  launch_template {
    id      = aws_launch_template.write.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "read" {
  name = "${var.project_name}-${var.environment}-read-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.read.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 80
    }
  }
}

resource "aws_ecs_capacity_provider" "write" {
  name = "${var.project_name}-${var.environment}-write-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.write.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 80
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = [aws_ecs_capacity_provider.read.name, aws_ecs_capacity_provider.write.name]
}

resource "aws_ecs_task_definition" "read" {
  family                   = "${var.project_name}-${var.environment}-read"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "read-api"
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = concat(var.environment_variables, [
        {
          name  = "SERVICE_MODE"
          value = "read"
        }
      ])
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "read"
        }
      }
    }
  ])

  tags = var.common_tags
}

resource "aws_ecs_task_definition" "write" {
  family                   = "${var.project_name}-${var.environment}-write"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "write-api"
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = concat(var.environment_variables, [
        {
          name  = "SERVICE_MODE"
          value = "write"
        }
      ])
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "write"
        }
      }
    }
  ])

  tags = var.common_tags
}

resource "aws_ecs_service" "read" {
  name            = "${var.project_name}-${var.environment}-read-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.read.arn
  desired_count   = var.read_service_desired_count

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.read.name
    weight            = 1
  }

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.read_target_group_arn
    container_name   = "read-api"
    container_port   = var.container_port
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:node-type == read"
  }

  depends_on = [aws_ecs_cluster_capacity_providers.this]
}

resource "aws_ecs_service" "write" {
  name            = "${var.project_name}-${var.environment}-write-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.write.arn
  desired_count   = var.write_service_desired_count

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.write.name
    weight            = 1
  }

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.write_target_group_arn
    container_name   = "write-api"
    container_port   = var.container_port
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:node-type == write"
  }

  depends_on = [aws_ecs_cluster_capacity_providers.this]
}
