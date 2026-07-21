output "rds_endpoint" {

  description = "The endpoint of the PostgreSQL database"

  value = aws_db_instance.postgres.endpoint

}

output "backend_public_ip" {

  description = "Public IP of backend EC2"

  value = aws_instance.backend.public_ip

}

output "load_balancer_dns" {

  description = "Application Load Balancer DNS"

  value = aws_lb.main.dns_name

}

output "jenkins_public_ip" {

  value = aws_instance.jenkins.public_ip

}

output "ecr_repository_url" {

  description = "ECR repository URL"

  value = aws_ecr_repository.backend.repository_url

}