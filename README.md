# Fully automated k8s setup on AWS
<br>
Spin k8s multimaster cluster with ELB in one go. <br>
Inventory for ansible is generated automatically. <br>

```bash
cd /aws-terraform/remote-state && terraform apply -var-file='/aws-terraform/aws.tfvars' -auto-approve &&
cd /aws-terraform/vpc && terraform apply -var-file='/aws-terraform/aws.tfvars' -auto-approve &&
cd /aws-terraform/master && terraform apply -var-file='/aws-terraform/aws.tfvars' -auto-approve && 
cd /aws-terraform/worker && terraform apply -var-file='/aws-terraform/aws.tfvars' -auto-approve && 
cd /aws-terraform/template && terraform apply -var-file='/aws-terraform/aws.tfvars' -auto-approve && 
sleep 120 && 
cd /aws-terraform/ansible && ansible-playbook -i /xxx/hosts /xxx/ansible/docker.yml /aws-terraform/ansible/kubernetes-bins.yml /aws-terraform/ansible/kubernetes-masters-bootstrap.yml /aws-terraform/ansible/kubernetes-workers-join.yml
```
