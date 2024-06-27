variable ENV {
  type = string
}

variable KEY_NAME {
  type = string
}

variable PATH_TO_PUBLIC_KEY {
    type = string
}

variable INSTANCE_TYPE {
  type = string
}

variable VPC_ID {
  type = string
}

variable PUBLIC_SUBNETS {
  type = list
}

variable PROJECT_TAGS {
  type = map(string)
}
