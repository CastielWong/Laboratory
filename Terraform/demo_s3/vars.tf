
variable AWS_ACCESS_KEY {
  type = string
}

variable AWS_SECRET_KEY {
  type = string
}

variable AWS_REGION {
  default = "us-east-1"
}

variable KEY_NAME {
  default = "demo_tf_key"
}

variable AMIS {
  type = map
  default = {
    "us-east-1" = "ami-05e00da24aba682c3"
    "us-west-2" = "ami-0e3c30a614395d894"
    "ap-southeast-2" = "ami-02af89c484ddb7278"
  }
}

variable INSTANCE_USERNAME {
  default = "ubuntu"
}

variable BUCKET_NAME {
  default = "demo-laboratory-qweasdzxc"
}
