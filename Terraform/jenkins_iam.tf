resource "aws_iam_role" "jenkins_role" {

  name = "jenkins-ec2-role"


  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "ec2.amazonaws.com"

        }

        Action = "sts:AssumeRole"

      }

    ]

  })

}

resource "aws_iam_policy" "jenkins_ecr_policy" {

  name = "jenkins-ecr-access"


  policy = jsonencode({

    Version = "2012-10-17"


    Statement = [

      {

        Effect = "Allow"

        Action = [

          "ecr:GetAuthorizationToken"

        ]

        Resource = "*"

      },


      {

        Effect = "Allow"

        Action = [

          "ecr:BatchCheckLayerAvailability",

          "ecr:CompleteLayerUpload",

          "ecr:InitiateLayerUpload",

          "ecr:PutImage",

          "ecr:UploadLayerPart"

        ]

        Resource = aws_ecr_repository.backend.arn

      }

    ]

  })

}

resource "aws_iam_role_policy_attachment" "jenkins_ecr_attachment" {

  role = aws_iam_role.jenkins_role.name


  policy_arn = aws_iam_policy.jenkins_ecr_policy.arn

}

resource "aws_iam_instance_profile" "jenkins_profile" {

  name = "jenkins-instance-profile"


  role = aws_iam_role.jenkins_role.name

}