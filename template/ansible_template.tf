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

terraform {
 backend "s3" {
 encrypt = true
 bucket = "asborisov-state-storage-lock-s3"
 dynamodb_table = "asborisov-state-lock-dynamodb"
 region = "us-east-2"
 key = "templates/aws"
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

data "terraform_remote_state" "masters" {
 backend = "s3"
 config = {
 bucket = var.state_storage_s3
 region = "us-east-2"
 key = "masters/aws"
}
}


data "terraform_remote_state" "workers" {
 backend = "s3"
 config = {
 bucket = var.state_storage_s3
 region = "us-east-2"
 key = "worker/aws"
}
}


data "template_file" "ansible_template" {
  template = file("./ansible_template.cfg")
  vars = {
    k8s_masters_public = data.terraform_remote_state.masters.outputs.k8s_masters_public
    k8s_masters_internal = data.terraform_remote_state.masters.outputs.k8s_masters_internal
    k8s_masters_elb = data.terraform_remote_state.masters.outputs.k8s_masters_elb
    k8s_workers_public = data.terraform_remote_state.workers.outputs.k8s_workers_public
    k8s_workers_internal = data.terraform_remote_state.workers.outputs.k8s_workers_internal
    k8s_workers_elb = data.terraform_remote_state.workers.outputs.k8s_workers_elb
}
}

resource "null_resource" "k8s-hosts" {
  triggers = {
    template_rendered = data.template_file.ansible_template.rendered
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.ansible_template.rendered}' > /root/hosts" 
 }
}
