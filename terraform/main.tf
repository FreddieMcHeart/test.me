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

resource "aws_instance" "test-me-server" {
  ami                    = "ami-05f7491af5eef733a"
  instance_type          = "t3.small"
  user_data              = "${file("keys.sh")}"
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  tags = {
    Name = "Test.Me"
  }
  connection {
    type = "ssh"
    user = "root"
    private_key = file("/root/.ssh/private")
    host = file("/home/ansible-host")
  }

  provisioner "remote-exec" {
    inline = [
      "ansible-playbook /opt/test.me/ansible/post.yaml -i '${self.public_ip}'"
    ]
  }

}

resource "aws_elasticsearch_domain" "test-me" {
  domain_name           = "test-me"
  elasticsearch_version = "7.10"

  cluster_config {
    instance_type  = "t2.small.elasticsearch"
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  snapshot_options {
    automated_snapshot_start_hour = 0
  }

  tags = {
    Domain = "Test-Me"
  }
}

resource "aws_elasticsearch_domain_policy" "main" {
  domain_name = aws_elasticsearch_domain.test-me.domain_name

  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Condition": {
                "IpAddress": {"aws:SourceIp": ["178.150.230.152/32, 54.93.0.0/24"]}
            },
            "Resource": "${aws_elasticsearch_domain.test-me.arn}/*"
        }
    ]
}
POLICIES
}