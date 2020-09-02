# Fully automated k8s setup on AWS
<br>
This is an experimental take on task to spin k8s multimaster cluster with ELB in one go. <br>
Inventory for ansible is generated automatically. Ansible tasks is not groomed though. <br>
Done with very scarce compute resources, so it has some specific commands tailored to deal with it.<br>

```bash
cd /somewhere/remote-state && terraform apply -var-file='/somewhere/aws.tfvars' -auto-approve &&
cd /somewhere/vpc && terraform apply -var-file='/somewhere/aws.tfvars' -auto-approve &&
cd /somewhere/master && terraform apply -var-file='/somewhere/aws.tfvars' -auto-approve && 
cd /somewhere/worker && terraform apply -var-file='/somewhere/aws.tfvars' -auto-approve && 
cd /somewhere/template && terraform apply -var-file='/somewhere/aws.tfvars' -auto-approve && 
sleep 120 && 
cd /somewhere/ansible && ansible-playbook -i /somewhere/hosts /somewhere/ansible/docker.yml /somewhere/ansible/kubernetes-bins.yml /somewhere/ansible/kubernetes-masters-bootstrap.yml /somewhere/ansible/kubernetes-workers-join.yml
```
