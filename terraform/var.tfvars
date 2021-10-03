cocus-vpc-cidr = "172.16.0.0/16"

project-tag = {
    Name =  "cocus"
}

aws_subnet = {
    priv = "172.16.2.0/24"
    pub = "172.16.1.0/24"
}

azs = "us-east-2a"

instance_info = {
  ami = "ami-023c8dbf8268fb3ca"
  instance_type = "t2.micro"
}