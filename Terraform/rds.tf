resource "aws_security_group" "rds_sg" {

  name = "rds-security-group"

  description = "Allow PostgreSQL traffic"

  vpc_id = aws_vpc.main.id


 ingress {

   from_port = 5432

   to_port = 5432

   protocol = "tcp"

   security_groups = [
      aws_security_group.backend_sg.id
   ]

 }


 egress {

   from_port = 0

   to_port = 0

   protocol = "-1"

   cidr_blocks = ["0.0.0.0/0"]

 }

}

resource "aws_db_subnet_group" "main" {

  name = "database-subnets"

  subnet_ids = [

    aws_subnet.private_a.id,
    aws_subnet.private_b.id

  ]

}

resource "aws_db_instance" "postgres" {

 identifier = "cloudyy-postgres"

 allocated_storage = 20

 storage_type = "gp3"

 engine = "postgres"

 instance_class = "db.t3.micro"

 db_name = "db"

 username = "postgres"


 publicly_accessible = false

 skip_final_snapshot = true

 db_subnet_group_name = aws_db_subnet_group.main.name

 vpc_security_group_ids = [

     aws_security_group.rds_sg.id

 ]

}