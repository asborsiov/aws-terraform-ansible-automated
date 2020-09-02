variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "state_storage_s3" {}
variable "state_lock_dynamodb" {}
variable "key_name" {
  default = "Default"
}

variable "subnet_address_space" {
  default = "10.1.0.0/24"
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "us-east-2"
}

terraform {
 backend "s3" {
 encrypt = true
 bucket = "asborisov-state-storage-lock-s3"
 dynamodb_table = "asborisov-state-lock-dynamodb"
 region = "us-east-2"
 key = "worker/aws"
 }
}

data "terraform_remote_state" "vpc" {
 backend = "s3"
 config = {
 bucket = var.state_storage_s3
 region = "us-east-2"
 key = "vpc/aws"
}
}

resource "aws_security_group" "k8s-sg" {
  name        = "k8s_sg"
  vpc_id      = data.terraform_remote_state.vpc.outputs.aws_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.subnet_address_space]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [var.subnet_address_space]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "elb-sg" {
  name        = "nginx_elb_sg"
  vpc_id      = data.terraform_remote_state.vpc.outputs.aws_vpc_id

  #Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "k8s_workers" {
  count = "1"
  ami           = "ami-01e36b7901e884a10"
  instance_type = "t2.micro"
  subnet_id     = data.terraform_remote_state.vpc.outputs.aws_subnet_subnet_id
  vpc_security_group_ids = [aws_security_group.k8s-sg.id]
  key_name        = var.key_name
  root_block_device {
    delete_on_termination = true
 }
}

resource "aws_elb" "k8s-worker-cluster" {
  name = "nginx-elb"

  subnets         = [data.terraform_remote_state.vpc.outputs.aws_subnet_subnet_id]
  security_groups = [aws_security_group.elb-sg.id]
  instances       = aws_instance.k8s_workers.*.id

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

output "k8s_workers_internal" {
    value = join("\\n",aws_instance.k8s_workers.*.private_ip)
}

output "k8s_workers_public" {
    value = join("\\n",aws_instance.k8s_workers.*.public_ip)
}

output "k8s_workers_elb" {
     value = aws_elb.k8s-worker-cluster.dns_name
}
