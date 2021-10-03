variable "cocus-vpc-cidr" {
  
}

variable aws_subnet {
    type = object({
        pub = string
        priv = string
    })
}

variable "azs" {
  
}

variable "project-tag" {
  
}

variable "instance_info" {
    type = object({
        ami = string
        instance_type = string
    })
  
}