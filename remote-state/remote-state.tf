variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "state_storage_s3" {}
variable "state_lock_dynamodb" {}
variable "key_name" {
  default = "Default"
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "us-east-2"
}

resource "aws_s3_bucket" "terraform-state-storage-s3" {
    bucket = var.state_storage_s3
 
    versioning {
      enabled = true
    }
 
    lifecycle {
      prevent_destroy = true
    }
 
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = var.state_lock_dynamodb
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

}
