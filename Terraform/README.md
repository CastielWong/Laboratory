
This is the playground for Terraform.

Ansible, Chef, Puppet, Saltstsck have a focus on automating the installation and configuration of software, they are used in keeping the machines in compliance, in a certain state. Terraform can automate provisioning of the infrastructure itself. However, Terraform is not fit to do configuration management on the software on machines. Tool like Ansible is better than Terraform when it comes to automate the machine itself. So it's good to use Ansible to install software after the infrastucture is provisioned by Terraform.



Common Commands:

```sh
terraform plan -out {file}.terraform

terraform apply {file}.terraform

# display current state
terraform show

# display state in JSON
cat terraform.tfstate
```


## Reference

- Terrafrom demo: https://github.com/wardviaene/terraform-course
- AWS Provider in Terraform: https://www.terraform.io/docs/providers/aws/
