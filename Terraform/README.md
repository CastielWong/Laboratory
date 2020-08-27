
This is the playground for Terraform.

Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

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


## HCL

HCL: HashiCorp Configuration Language

Terrform will interpret any file ending with ".tf". A sample varibale file for Terraform would be:

```tf
variable "demovar" {
  type = string
  default = "Demo Variable"
}

variable "demo_map" {
  type = map(string)
  default = {
    map_key = "Demo Map"
  }
}

variable "demo_list" {
  type = list
  default = [4, 2, 3, 1, 5]
}
```

Variables are accessible via both CLI or other Terraform files, for CLI:

```sh
element(var.demo_list, 4)       # 5
slice("${var.demo_list}", 2, 4) # [3, 1]
```



## Reference

- Introduction to Terraform: https://www.terraform.io/intro/index.html
- Infrastructure Automation With Terraform: https://www.udemy.com/course/learn-devops-infrastructure-automation-with-terraform/
- Terrafrom demo: https://github.com/wardviaene/terraform-course
- AWS Provider in Terraform: https://www.terraform.io/docs/providers/aws/
