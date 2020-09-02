variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "state_storage_s3" {}
variable "state_lock_dynamodb" {}
variable "key_name" {
  default = "Default"
}
variable "network_address_space" {
  default = "10.1.0.0/16"
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
 key = "vpc/aws"
 }
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block = var.network_address_space
  enable_dns_hostnames = "true"

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

}

resource "aws_subnet" "subnet" {
  cidr_block        = var.subnet_address_space
  vpc_id            = aws_vpc.vpc.id
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[0]

}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta-subnet" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rtb.id
}


output "aws_vpc_id" {
    value = aws_vpc.vpc.id
}


output "aws_subnet_subnet_id" {
   value = aws_subnet.subnet.id
}
