terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region     = "eu-central-1"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "vpc-3628b25c"

  ingress {
    description      = "ALL"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_key_pair" "test-me" {
  key_name   = "test-me-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAixZwDbvAjau/O1ZtWBkHIVyKctWcn3M/RSrlqiC9CI/5pq+UtoJejQZQfsPQcyrarE/meJWgvpY+RByf6k2h3Eirkvu6p3iJBzdzB8VJnCp73jBkaCx82qpbn+Cc3KE5l2k2EsG9IIJo4XihJPKNpsF2I3wZZ3OG+kh6AQKf8meRUaBLFq/0/oBJIgDkOJPrb3q4U55J1yYjvAOw0HP4CEbqnGQUZuFH3hOX9sQA8VrfHKwTQ4x+3EjlBHQeIuK6P0nSvz7weo04X635BTxshR73UzTycN05uQgObjVbb3ZAJk7DMuYjS59nsNSC8RyILo/aIiSk4QnrOos+4YgmJQ== Nazarii"
}

resource "aws_key_pair" "anna" {
  key_name = "anna-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5kbBBmPDHfWbxnmAd5CgxRmfc/qSSpZe9upyjFonwixl7dY+25CvsYTX/F2WzrINbjQ0Nv8hfYPFZ/ZT6tdcKbJT2/nQ5VzLeWEoFwIyl8U0JifF84J5sMmcgcejfRnXoXw4Q8FoElASIXJb3vnHvVLQ/EqSVv5Ek1MvbMYOEUGQRrJXu+gBT3UqgJ4zsMjbWsCpkrk9aQonfA/JAPBgzmr2fiYCWl+gV//C77TJWzfSaGtziwDrbWuJMfMbQIlD4uRL+C08W6adpCTUNuKdDqFZDY4Ek3OqvNkNYchQu7T01/hPaFZsdX24G5v2XDQeihtiIfhPtEPS2TwKA0/zJ Anna(root@ans01)"
}

resource "aws_instance" "test-me-server" {
  ami                    = "ami-05f7491af5eef733a"
  instance_type          = "t3.small"
  key_name               = [aws_key_pair.test-me.id, aws_key_pair.anna.id]
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  tags = {
    Name = "Test.Me"
  }
}

resource "aws_elasticsearch_domain" "test-me" {
  domain_name           = "test-me"
  elasticsearch_version = "7.10"

  cluster_config {
    instance_type = "t2.small.elasticsearch"
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 5
  }

  snapshot_options {
    automated_snapshot_start_hour = 0
  }

  tags = {
    Domain = "Test-Me"
  }
}

