resource "aws_secretsmanager_secret" "db_password" {

  name = "db-password"

}


resource "aws_secretsmanager_secret_version" "db_password" {

  secret_id = aws_secretsmanager_secret.db_password.id

  

}