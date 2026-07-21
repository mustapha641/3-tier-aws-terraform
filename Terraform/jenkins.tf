resource "aws_instance" "jenkins" {

  ami = "ami-0c7217cdde317cfec"

  instance_type = "t3.micro"

  subnet_id = aws_subnet.public_a.id


  key_name = "jenkins key-pair"
  
iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name

  vpc_security_group_ids = [

    aws_security_group.jenkins_sg.id

  ]


  associate_public_ip_address = true


  user_data = <<-EOF
              #!/bin/bash

              apt update -y

              apt install openjdk-21-jdk -y


              wget -O /usr/share/keyrings/jenkins-keyring.asc \
              https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key


              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
              https://pkg.jenkins.io/debian-stable binary/ \
              | tee /etc/apt/sources.list.d/jenkins.list


              apt update -y

              apt install jenkins -y


              systemctl start jenkins

              systemctl enable jenkins


              apt install docker.io awscli git -y


              systemctl start docker

              systemctl enable docker


              usermod -aG docker jenkins


              systemctl restart jenkins


              EOF


  tags = {

    Name = "Jenkins Server"

  }

}