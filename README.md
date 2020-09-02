# Fully automated k8s setup on AWS
<br>
This is an another experimental take on task to spin k8s cluster with one console command (granted this is will be very long command to execute tf files one after another and then starting ansible playbooks). <br>

```bash
cd /somewhere/remote-state && terraform apply -var-file='/somewhere/aws.tfvars' -auto-approve &&
cd /somewhere/vpc && terraform apply -var-file='/somewhere/aws.tfvars' -auto-approve &&
cd /somewhere/master && terraform apply -var-file='/somewhere/aws.tfvars' -auto-approve && 
cd /somewhere/worker && terraform apply -var-file='/somewhere/aws.tfvars' -auto-approve && 
cd /somewhere/template && terraform apply -var-file='/somewhere/aws.tfvars' -auto-approve && 
sleep 120 && 
cd /somewhere/ansible && ansible-playbook -i /somewhere/hosts /somewhere/ansible/docker.yml /somewhere/ansible/kubernetes-bins.yml /somewhere/ansible/kubernetes-masters-bootstrap.yml /somewhere/ansible/kubernetes-workers-join.yml
```
