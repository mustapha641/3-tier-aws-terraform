pipeline {

    agent any


    environment {

        AWS_REGION = "us-east-1"

        ECR_REPO = "cloudyy-backend"

    }


    stages {


        stage('Checkout Code') {

            steps {

                git 'YOUR_GITHUB_REPOSITORY_URL'

            }

        }


        stage('Build Docker Image') {

            steps {

                sh '''
                cd app
                docker build -t cloudyy-backend .
                '''

            }

        }


        stage('Login to ECR') {

            steps {

                sh '''
                aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS --password-stdin \
                $(aws ecr describe-repositories \
                --repository-names $ECR_REPO \
                --query "repositories[0].repositoryUri" \
                --output text)
                '''

            }

        }


        stage('Push Image') {

            steps {

                sh '''
                docker tag cloudyy-backend:latest \
                $(aws ecr describe-repositories \
                --repository-names $ECR_REPO \
                --query "repositories[0].repositoryUri" \
                --output text):latest


                docker push \
                $(aws ecr describe-repositories \
                --repository-names $ECR_REPO \
                --query "repositories[0].repositoryUri" \
                --output text):latest
                '''

            }

        }

    }

}