data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2.name
}

locals {
  user_data = <<-EOF
    #!/bin/bash
    set -e

    dnf update -y
    dnf install -y java-21-amazon-corretto-headless

    mkdir -p /opt/app
    cat > /opt/app/start.sh << 'SCRIPT'
    #!/bin/bash
    echo "Aguardando deploy do JAR em /opt/app/app.jar"
    echo "Execute: java -jar /opt/app/app.jar --server.port=${var.app_port}"
    SCRIPT
    chmod +x /opt/app/start.sh

    echo "Instancia ${var.project_name} provisionada com sucesso" > /opt/app/ready.txt
  EOF
}

resource "aws_instance" "app" {
  count = var.instance_count

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[count.index % length(aws_subnet.public)].id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name
  user_data              = local.user_data
  key_name               = var.key_name != "" ? var.key_name : null

  tags = {
    Name = "${var.project_name}-${var.environment}-app-${count.index + 1}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "app" {
  count = var.instance_count

  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app[count.index].id
  port             = var.app_port
}
