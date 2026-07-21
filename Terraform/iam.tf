resource "aws_iam_role" "ec2_role" {

  name = "backend-ec2-role"


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

resource "aws_iam_role_policy_attachment" "cloudwatch" {

  role = aws_iam_role.ec2_role.name


  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

}

resource "aws_iam_instance_profile" "backend_profile" {

  name = "backend-instance-profile"


  role = aws_iam_role.ec2_role.name

}

resource "aws_iam_policy" "secrets_access" {

  name = "backend-secrets-access"


  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Action = [

          "secretsmanager:GetSecretValue"

        ]

        Resource = aws_secretsmanager_secret.db_password.arn

      }

    ]

  })

}



resource "aws_iam_role_policy_attachment" "secrets_access" {

  role = aws_iam_role.ec2_role.name


  policy_arn = aws_iam_policy.secrets_access.arn

}

resource "aws_iam_policy" "ecr_access" {

  name = "backend-ecr-access"


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

          "ecr:GetDownloadUrlForLayer",

          "ecr:BatchGetImage"

        ]

        Resource = aws_ecr_repository.backend.arn

      }

    ]

  })

}

resource "aws_iam_role_policy_attachment" "ecr_access" {

  role = aws_iam_role.ec2_role.name


  policy_arn = aws_iam_policy.ecr_access.arn

}