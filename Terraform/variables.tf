variable "db_password" {

  description = "Password for the PostgreSQL database"

  type = string

  sensitive = true

}

variable "db_name" {

  description = "Database name"

  type = string

  default = "db"

}


variable "db_username" {

  description = "Database username"

  type = string

  default = "postgres"

}