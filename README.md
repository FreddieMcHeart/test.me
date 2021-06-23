## First step
go to the dir terraform via command `cd terraform`
start `terraform init` and after that `terraform apply`

## Second step
Add instance external ip to `./test.me/ansible/host.yaml` to end of string `ansible_host:`
Login to your new instance and inside the file `/root/.ssh/authorized_keys` delete all commands before your pub key
After that on ansible server run following command `ansible-playbook ./test.me/ansible/post.yaml -i ./test.me/ansible/hosts.yaml` 

##Third step

