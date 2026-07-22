resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "three-tier-vpc"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-b"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "three-tier-igw"
  }
}

resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Public Route Table"
  }

}

resource "aws_route" "public_internet_access" {

  route_table_id         = aws_route_table.public_rt.id

  destination_cidr_block = "0.0.0.0/0"

  gateway_id             = aws_internet_gateway.igw.id

}

resource "aws_route_table" "private_rt" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Private Route Table"
  }

}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_eip" "nat_eip" {

  domain = "vpc"

  tags = {

    Name = "NAT Elastic IP"

  }

}

resource "aws_nat_gateway" "nat_gw" {

  allocation_id = aws_eip.nat_eip.id

  subnet_id     = aws_subnet.public_a.id

  tags = {

    Name = "NAT GATEWAY"

  }

}

resource "aws_route" "private_nat_access" {

  route_table_id         = aws_route_table.private_rt.id

  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.nat_gw.id

}

resource "aws_security_group" "alb_sg" {

  name = "alb-security-group"

  description = "Allow HTTP and HTTPS traffic"

  vpc_id = aws_vpc.main.id


  ingress {

    description = "HTTP from Internet"

    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }


  ingress {

    description = "HTTPS from Internet"

    from_port = 443

    to_port = 443

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }


  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }


  tags = {

    Name = "ALB Security Group"

  }

}

resource "aws_security_group" "jenkins_sg" {

  name = "jenkins-security-group"

  vpc_id = aws_vpc.main.id


  ingress {

    from_port = 22

    to_port = 22

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }


  ingress {

    from_port = 8080

    to_port = 8080

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }


  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

}

resource "aws_security_group" "backend_sg" {

  name = "backend-security-group"

  description = "Allow traffic from ALB to backend"

  vpc_id = aws_vpc.main.id


  ingress {

    description = "Allow backend traffic from ALB"

    from_port = 8080

    to_port = 8080

    protocol = "tcp"

    security_groups = [aws_security_group.alb_sg.id]

  }


  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }


  tags = {

    Name = "Backend Security Group"

  }

}

resource "aws_security_group" "database_sg" {

  name = "database-security-group"

  description = "Allow database access from backend"

  vpc_id = aws_vpc.main.id


  ingress {

    description = "PostgreSQL access from backend"

    from_port = 5432

    to_port = 5432

    protocol = "tcp"

    security_groups = [aws_security_group.backend_sg.id]

  }


  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }


  tags = {

    Name = "Database Security Group"

  }

}

resource "aws_lb" "main" {

  name = "application-lb"

  load_balancer_type = "application"

  internal = false

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  tags = {

    Name = "Application Load Balancer"

  }

}

resource "aws_lb_target_group" "backend_tg" {

  name = "backend-target-group"

  port = 8080

  protocol = "HTTP"

  vpc_id = aws_vpc.main.id


  health_check {

    enabled = true

    path = "/"

    port = "8080"

    protocol = "HTTP"

  }


  tags = {

    Name = "Backend Target Group"

  }

}

resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.main.arn

  port = 80

  protocol = "HTTP"


  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.backend_tg.arn

  }


}

resource "aws_instance" "backend" {

  ami = "ami-0c7217cdde317cfec"

  instance_type = "t3.micro"

  subnet_id = aws_subnet.private_a.id


  vpc_security_group_ids = [
    aws_security_group.backend_sg.id
  ]


  associate_public_ip_address = false


  user_data = <<-EOF
              #!/bin/bash

              apt update -y


              # Install Docker

              apt install docker.io -y


              systemctl start docker

              systemctl enable docker



              # Install PostgreSQL client

              apt install postgresql-client -y



              # Database configuration

              echo "DB_HOST=${aws_db_instance.postgres.address}" >> /etc/environment

              echo "DB_NAME=${var.db_name}" >> /etc/environment

              echo "DB_USER=${var.db_username}" >> /etc/environment

      



              # Run application container

              docker run -d \
              -p 8080:80 \
              nginx


              EOF


  tags = {

    Name = "Backend Server"

  }

}

resource "aws_lb_target_group_attachment" "backend_attachment" {

  target_group_arn = aws_lb_target_group.backend_tg.arn

  target_id = aws_instance.backend.id

  port = 8080

}


