resource "aws_db_instance" "mysql" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  publicly_accessible  = false
  multi_az             = true

  db_subnet_group_name   = aws_db_subnet_group.db_sub_groups.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    "Name" = "large-ap2-mysql"
  }
}

resource "aws_db_subnet_group" "db_sub_groups" {
  name       = "large-ap-db-sub-group"
  subnet_ids = [aws_subnet.large_pri_a.id, aws_subnet.large_pri_c.id]

  tags = {
    Name = "large-ap-db-sub-group"
  }
}