# AWS Kubernetes EC2 cluster one-liner
<br>
Deploy Kubernetes cluster with ansbile and terrafrom, fully automated. <br>

![Terraform and AWS](https://p2zk82o7hr3yb6ge7gzxx4ki-wpengine.netdna-ssl.com/wp-content/uploads/terraform-x-aws-1.png)

## Sample code
```bash
cd /aws-terraform/remote-state && terraform apply -var-file='/aws-terraform/aws.tfvars' -auto-approve &&
cd /aws-terraform/vpc && terraform apply -var-file='/aws-terraform/aws.tfvars' -auto-approve &&
cd /aws-terraform/master && terraform apply -var-file='/aws-terraform/aws.tfvars' -auto-approve && 
cd /aws-terraform/worker && terraform apply -var-file='/aws-terraform/aws.tfvars' -auto-approve && 
cd /aws-terraform/template && terraform apply -var-file='/aws-terraform/aws.tfvars' -auto-approve && 
sleep 300 && 
cd /aws-terraform/ansible && ansible-playbook -i /aws-terraform/hosts /aws-terraform/ansible/docker.yml /aws-terraform/ansible/kubernetes-bins.yml /aws-terraform/ansible/kubernetes-masters-bootstrap.yml /aws-terraform/ansible/kubernetes-workers-join.yml
```
