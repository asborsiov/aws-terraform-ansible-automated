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
 key = "masters/aws"
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
resource "aws_security_group" "k8s-master-sg" {
  name        = "k8s_master_sg"
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
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.subnet_address_space]
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = [var.subnet_address_space]
  }

  ingress {
    from_port   = 10250
    to_port     = 10252
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


resource "aws_security_group" "k8s-master-elb" {              
  name        = "k8s_elb_sg"
  vpc_id      =  data.terraform_remote_state.vpc.outputs.aws_vpc_id

  #Allow HTTP from anywhere
  ingress {
    from_port   = 6443
    to_port     = 6443
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

resource "aws_instance" "k8s_masters" {
  count = "2"
  ami           = "ami-01e36b7901e884a10"
  instance_type = "t2.micro"
  subnet_id     = data.terraform_remote_state.vpc.outputs.aws_subnet_subnet_id
  vpc_security_group_ids = [aws_security_group.k8s-master-sg.id]
  key_name        = var.key_name
  root_block_device {
    delete_on_termination = true
 }
}



resource "aws_elb" "k8s-master-cluster" {
  name = "k8s-masters-elb"
  internal = true
  subnets         = [data.terraform_remote_state.vpc.outputs.aws_subnet_subnet_id]
  security_groups = [aws_security_group.k8s-master-elb.id]
  instances       = aws_instance.k8s_masters.*.id

  listener {
    instance_port     = 6443
    instance_protocol = "tcp"
    lb_port           = 6443
    lb_protocol       = "tcp"
  }
  
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:6443"
    interval            = 5
  }

}

output "k8s_masters_internal" {
    value = join("\\n",aws_instance.k8s_masters.*.private_ip)
}

output "k8s_masters_public" {
    value = join("\\n",aws_instance.k8s_masters.*.public_ip)
}

output "k8s_masters_elb" {                         
     value = aws_elb.k8s-master-cluster.dns_name
}

