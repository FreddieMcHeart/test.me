## First step
start `terraform init` and after that `terraform apply`

## Second step
Add instance external ip to `./test.me/ansible/host.yaml` to end of string `ansible_host:`
After that on ansible server run following command `ansible-playbook ./test.me/ansible/post.yaml -i ./test.me/ansible/hosts.yaml` 

##Third step
