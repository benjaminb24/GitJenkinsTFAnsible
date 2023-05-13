terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = "ASIAVNWYMEA4GBFM5V7N"
  secret_key = "mrVX1xI57TeGEMcqJZ+L0DobdWUtPobMlxo2kA9d"
  token = "FwoGZXIvYXdzEKv//////////wEaDPMHS4SuLVcHJDqQayK5AYnyyfW/nCDee4OgRnqmOUfy2ibbvdXatJAz5ska4nZtbFjk3qP6BkMFbB96Q8apI8QWq9n5Zin88DNWG1YD+Wrzrq4KqpVmRGJXjniQRKLOzG7cn4yAsSxvqEhZGfof4w5mEQ17V5bd5fF+IJlEBGRzQu+6idl8Q1MDXCDgliOzrgUATvvDhg8HfKDGQDDqP7NwCpr+gOw39yU2XnX2XW90dWULuw65K2lOJL9bMOrmoL5nT+Toj1wRKNa79qIGMi1XOPMWA9yFQwm2Dn+OmxndGxSBx40nqn9MEoaTEcg19F5D8dcAiQq+gLNZkWA="
}

variable "default-ami" {
  type = string
  default = "ami-007855ac798b5175e"
}

output "test-ami" {
  value = "using ami...${var.default-ami}"
}

resource aws_security_group "default-sg" {
  name        = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
    description      = "Allow all connections"
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

output test-sg {
  value = "${aws_security_group.default-sg.name} has been created."
}

resource aws_key_pair "default-key" {
  key_name = "deployer-key"
  public_key = file("/root/.ssh/id_rsa.pub")
}

output "test-key" {
  value = "${aws_key_pair.default-key.key_name} created successfully"
}

resource aws_instance "instance-group" {
  instance_type = "t2.micro"
  ami = var.default-ami
  key_name = aws_key_pair.default-key.key_name
  count = 5
  security_groups = [aws_security_group.default-sg.name]
  
  provisioner "local-exec" {
    command = "echo aws-${count.index} ansible_host=${self.public_ip} ansible_user=ubuntu >> ansible_custom_inventory"
  }
}
