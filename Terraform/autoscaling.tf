resource "aws_launch_template" "backend" {

  name = "backend-launch-template"

  image_id = "ami-0c7217cdde317cfec"

  instance_type = "t3.micro"


  vpc_security_group_ids = [
    aws_security_group.backend_sg.id
  ]


  iam_instance_profile {

    name = aws_iam_instance_profile.backend_profile.name

  }


  user_data = base64encode(<<-EOF
              #!/bin/bash

              apt update -y

              apt install docker.io awscli -y

              systemctl start docker

              systemctl enable docker


              aws ecr get-login-password --region us-east-1 | \
              docker login --username AWS --password-stdin \
              ${aws_ecr_repository.backend.repository_url}


              docker pull ${aws_ecr_repository.backend.repository_url}:latest


              docker run -d \
              -p 8080:80 \
              ${aws_ecr_repository.backend.repository_url}:latest


              EOF
)


  tag_specifications {

    resource_type = "instance"

    tags = {

      Name = "Backend ASG Instance"

    }

  }

}

resource "aws_autoscaling_group" "backend" {


  name = "backend-asg"


  min_size = 2


  max_size = 4


  desired_capacity = 2


  vpc_zone_identifier = [

    aws_subnet.private_a.id,

    aws_subnet.private_b.id

  ]


  target_group_arns = [

    aws_lb_target_group.backend_tg.arn

  ]


  launch_template {

    id = aws_launch_template.backend.id

    version = "$Latest"

  }


  health_check_type = "ELB"

}
