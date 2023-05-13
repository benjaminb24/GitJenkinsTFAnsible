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
