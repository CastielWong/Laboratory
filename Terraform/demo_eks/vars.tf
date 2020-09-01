
variable AWS_ACCESS_KEY {
  type = string
}

variable AWS_SECRET_KEY {
  type = string
}

variable AWS_REGION {
  default = "us-east-1"
}

variable CLUSTER_NAME {
  default = "terraform-eks-demo"
}
