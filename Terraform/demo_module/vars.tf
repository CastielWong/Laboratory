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

variable ENV {
  default = "demo"
}

variable PROJECT_TAGS {
  type          = map(string)
  default       = {
    "Environment" = "demo"
  }
}
