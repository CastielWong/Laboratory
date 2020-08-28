
This is the playground for Terraform.

Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

Ansible, Chef, Puppet, Saltstsck have a focus on automating the installation and configuration of software, they are used in keeping the machines in compliance, in a certain state. Terraform can automate provisioning of the infrastructure itself. However, though it provides configuration manager on an infrastructure level, Terraform is not fit to do that on the software on machines. Tool like Ansible is better than Terraform when it comes to automate the machine itself. So it's good to use Ansible to install software after the infrastucture is provisioned by Terraform.



Common Commands:

```sh
terraform plan -out {file}.terraform

terraform apply {file}.terraform

terraform destroy

# display current state
terraform show

# display state in JSON
cat terraform.tfstate
```

`terraform apply` is the short cut of:

```sh
terraform plan -out {file}
terraform apply {file}
rm {file}
```


## HCL

HCL: HashiCorp Configuration Language

Terrform will interpret any file ending with ".tf". A sample varibale file for Terraform would be:

```tf
variable "demo_var" {
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

Note that only "*.tf" file in the same path with CLI can be recognized by Terraform.

### Variable

Types:
- simple:
    - String
    - Number
    - Bool
- complex:
    - List(type)
    - Set(type)
    - Map(type)
    - Object: like a map, yet each element can have a different type
    - Tuple: like a list, yet each element can have a different type

To keep credential secure, it's highly recommended to have a file ending with ".tfvars" and have it in gitignore. Normally, Terraform would check ".tfvars" file to retrieve actual values, then parse them into any ".tf" file needed.

### Datasource

- For certain providers, Terraform provides datasources
- Datasources provides with dynamic information
    - a lot of data is available by AWS in a structured format using AWS API
    - Terraform exposes this information using data sources



## State

- Terraform keeps the remote state of the infrastructure
- Terraform stores it in a file called __terraform.tfstate__
- there is also a backup of previous state in __terraform.tfstate.backup__
- when `terraform apply` is ran, a new __terraform.tfstate__ and backup is written
- the state can be saved remote by using the backend functionality
- the default is a local backend
- using a remote store for the state will ensure that the team always has the latest version of the state



## Reference

- Introduction to Terraform: https://www.terraform.io/intro/index.html
- Infrastructure Automation With Terraform: https://www.udemy.com/course/learn-devops-infrastructure-automation-with-terraform/
- Terrafrom demo codes: https://github.com/wardviaene/terraform-course
- Amazon EC2 AMI Locator: https://cloud-images.ubuntu.com/locator/ec2/
- AWS Provider in Terraform: https://www.terraform.io/docs/providers/aws/
