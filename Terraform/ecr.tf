resource "aws_ecr_repository" "backend" {

  name = "cloudyy-backend"

  image_scanning_configuration {

    scan_on_push = true

  }

}