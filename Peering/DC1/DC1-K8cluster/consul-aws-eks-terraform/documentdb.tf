# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


# DocDB Subnet Group
resource "aws_docdb_subnet_group" "example_docdb_subnet_group" {
  name       = "example-docdb-subnet-group"
  subnet_ids = module.vpc.database_subnets
}

# DocDB Cluster
resource "aws_docdb_cluster" "example_docdb_cluster" {
  cluster_identifier   = "example-docdb-cluster"
  engine       = "docdb"
  master_username = "docadmin"
  master_password = "password"
  db_subnet_group_name = aws_docdb_subnet_group.example_docdb_subnet_group.name
  vpc_security_group_ids = [aws_security_group.docdb_sg.id]

  skip_final_snapshot = true
}

# DocDB Instance
resource "aws_docdb_cluster_instance" "example_docdb_instance" {
  count                   = 1
  cluster_identifier      = aws_docdb_cluster.example_docdb_cluster.id
  instance_class          = "db.t3.medium"
  identifier              = "example-docdb-instance-${count.index}"
  apply_immediately       = true
}

# Security Group
resource "aws_security_group" "docdb_sg" {
  name_prefix = "example-sg"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
      "82.42.185.116/32"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
      "82.42.185.116/32"]
  }

  vpc_id = module.vpc.vpc_id
}
