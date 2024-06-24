
- [HCL](#hcl)
  - [Variable](#variable)
  - [Datasource](#datasource)
  - [Interpolation](#interpolation)
  - [Built-in Function](#built-in-function)
- [State](#state)
- [Reference](#reference)

This is the playground for Terraform.

Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently.
Terraform can manage existing and popular service providers as well as custom in-house solutions.

Ansible, Chef, Puppet, Saltstsck have a focus on automating the installation and
configuration of software, they are used in keeping the machines in compliance, in a certain state.
Terraform can automate provisioning of the infrastructure itself.

However, though it provides configuration manager on an infrastructure level, Terraform
is not fit to do that on the software on machines.
Tool like Ansible is better than Terraform when it comes to automate the machine itself.
So it's good to use Ansible to install software after infrastructure is provisioned by Terraform.

To provision AWS services via demo codes provided, create a user on AWS and store the credential in a file like "terraform.tfvars":

```
AWS_ACCESS_KEY = "xxx"
AWS_SECRET_KEY = "xxx"
AWS_REGION = "xxx"
```


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

Terrform will interpret any file ending with ".tf".
A sample variable file for Terraform would be:
```
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

To keep credential secure, it's highly recommended to have a file ending with ".tfvars"
and have it included in ".gitignore".
Normally, Terraform would check ".tfvars" file to retrieve actual values, then parse
them into any ".tf" file needed.


### Datasource
- For certain providers, Terraform provides datasources
- Datasources provides with dynamic information
    - a lot of data is available by AWS in a structured format using AWS API
    - Terraform exposes this information using data sources


### Interpolation
There are multiple types of interpolation:
- variable: `var.<variable>`
- resource: `<service>.<name>.<attribute>`
- data source: `data.<template>.<name>.rendered`
- module: `module.<service>.<output`
- meta: `terraform.<field>`
- count: `count.<field>`
- path: `path.<type>`


### Built-in Function
Table below display common used built-in functions:

| Function | Description | Example |
| --- | --- | --- |
| `basename(<path>)` | get the filename (last element) of a path | `basename("/var/demo.txt"` -> "demo.txt" |
| `coalesce(<str1>, <str2>, ...)` | get the first non-empty element | `coalesce("", "", "hi")` -> "hi" |
| `element(<list>, <index>)` | get a single element from a list at the given index | `element(module.vpc.public_subnets, count.index)` |
| `format(<format>, <variable>, ...)` | format a string | `format("server-%03d", count.index + 1)` -> "server-001" |
| `index(<list>, <element>)` | find the index of a given element in a list |  |
| `join(<delim>, <list>)` | joins a list together with a delimiter | `join(",", var.AMIS` -> "ami-123,ami-456" |
| `list(<item1>, <item2>, ...)` | create a new list | `list("a", "b", "c")` |
| `lower(<string>` | get lower case of the string | `lower("DEMO")` -> "demo" |
| `upper(<string>` | get upper case of the string | `upper("demo")` -> "DEMO" |
| `map(<key>, <value>, ...)` | create a map | `map("k1", "v1", "k2", "v2")` -> {"k1"="v1", "k2"="v2"} |
| `merge(<map1>, <map2>, ...)` | merge maps | `merge(map("k1", "v1"), map("k2", "v2"))` -> {"k1"="v1", "k2"="v2"} |
| `lookup(<map>, <key>, [<default>])` | look up on a map | `lookup(map("k", "v"), "a", "not found")` -> "not found" |
| `replace(<string>, <search>, <replace>` | replace substring | `replace("aba", "a", "b")` -> "aaa" |
| `split(<delim>, <string>)` | split a string into a list | `split(",", "a, b, c, d")` -> ["a", "b", "c", "d"] |
| `substre(<string>, <offset>, <length>)` | extract substring from a string | `substr("abcde", -3, 3)` -> "cde" |
| `timestamp()` | return RFC 3339 timestamp | `timestamp()` -> "2020-08-29T 10:03:23Z" |
| `uuid()` | return a UUID string in RFC 4122 v4 format | |
| `values(<map>)` | retrieve values of a map | `values(map("k1", "v1", "k2", "v2"))` -> ["v1", "v2"] |


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
- Terraform demo codes: https://github.com/wardviaene/terraform-course
- Amazon EC2 AMI Locator: https://cloud-images.ubuntu.com/locator/ec2/
- AWS Provider in Terraform: https://www.terraform.io/docs/providers/aws/
- Interpolation Syntax: https://www.terraform.io/docs/configuration-0-11/interpolation.html
- Terraform AWS modules: https://github.com/terraform-aws-modules
