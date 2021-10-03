provider "aws" {
    profile = "challenge"
    region = "us-east-2"
}

resource "aws_vpc" "cocus-vpc" {
    cidr_block           = var.cocus-vpc-cidr
    enable_dns_hostnames = true
    tags = {
        Name = "awslab-vpc"
  }
}

resource "aws_internet_gateway" "cocus-ig" {
    vpc_id = aws_vpc.cocus-vpc.id
    tags = {
    Name = "${var.project-tag.Name}-ig"
  }
  
}


resource "aws_eip" "cocus-eip" {
  vpc = true
  tags = {
    Name = "${var.project-tag.Name}-eip"
  }
}

resource "aws_nat_gateway" "cocus-ng" {
  allocation_id = aws_eip.cocus-eip.id
  subnet_id     = aws_subnet.cocus-public-subnet.id

  tags = {
    Name = "${var.project-tag.Name}-nat_gateway"
  }
}


resource "aws_subnet" "cocus-public-subnet" {
  vpc_id                  = aws_vpc.cocus-vpc.id
  cidr_block              = var.aws_subnet.pub
  availability_zone       = var.azs
  map_public_ip_on_launch = true
  tags = {
    Name = "awslab-subnet-public"
  }
}

resource "aws_subnet" "cocus-private-subnet" {
  vpc_id                  = aws_vpc.cocus-vpc.id
  cidr_block              = var.aws_subnet.priv
  availability_zone       = var.azs
#   map_public_ip_on_launch = true
  tags = {
    Name = "awslab-subnet-private"
  }
}

resource "aws_route_table" "awslab-rt-internet" {
    vpc_id = aws_vpc.cocus-vpc.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.cocus-ig.id
    }
    tags = {
    Name = "awslab-rt-internet"
    }  
}

resource "aws_route_table_association" "cocus-public" {
  subnet_id      = aws_subnet.cocus-public-subnet.id
  route_table_id = aws_route_table.awslab-rt-internet.id
}



resource "aws_default_route_table" "cocus_default" {
  default_route_table_id = aws_vpc.cocus-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.cocus-ng.id
    }
  
}


resource "aws_security_group" "public" {
  name        = "Security-Group-Public-Ports"
  description = "Security Group Public Ports"
  vpc_id      = aws_vpc.cocus-vpc.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "ICMP"
    from_port        = "-1"
    to_port          = "-1"
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

   ingress {
    description      = "internal communication"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    self             = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
        Name = "${var.project-tag.Name}-public-sg"
  }
}


resource "aws_security_group" "private" {
  name        = "Security-Group-Private-Ports"
  description = "Security-Group-Private-Ports"
  vpc_id      = aws_vpc.cocus-vpc.id

  ingress {
    description      = "DB Port"
    from_port        = 3110
    to_port          = 3110
    protocol         = "tcp"
    cidr_blocks      = ["172.16.1.0/24"]
  }

  ingress {
    description      = "ICMP"
    from_port        = "-1"
    to_port          = "-1"
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["172.16.1.0/24"]
  }

   ingress {
    description      = "internal communication"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    self             = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
        Name = "${var.project-tag.Name}-private-sg"
  }
}


resource "aws_key_pair" "cocus_key" {
    key_name = "cocus"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCa/GFH+xFclCfu2EE3QMsxfxwOK+3HV07sOhtM7+zhGcSA/KsA3evR7Bfx7BlVagz9QZY3l3mMbzqGhhSujwMF1UmHdPqBFzDZeAN+km7xiBRtYfszG/DnE7p7QhyY3mFzPwLtsTXV6GiowZVKrS6aXm98Sn5busUL1hqAUR0jxOM/gLi1i3SafCYrWmm2k63xhFnj+SYXr5F+zZTYxRGo5dH84ROYEic/PagpbSU5aKl5bteoIASB1jVWzVS6MBQ7ZIYPfjiMnzO/fs/IjfdkarDApKNWvpmLEnhThkn7zWQMxkY7v0EThnk8M2PrVvhqYo2ye3gjBcHcSQR5xbsl"
}


data "template_file" "apache" {
  template = "${file("files/apache.tpl")}"

  vars = {
    mysql_endpoint = "${aws_instance.db.private_dns}"
  }
}

data "template_file" "mysql" {
  template = "${file("files/mysql.tpl")}"
}

resource "aws_instance" "app" {
  ami                         = var.instance_info.ami
  instance_type               = var.instance_info.instance_type 
  subnet_id                   = aws_subnet.cocus-public-subnet.id
  key_name                    = "cocus"
  user_data = data.template_file.apache.rendered
  tags = {
    Name = "${var.project-tag.Name}-webserver"
  }
  vpc_security_group_ids = [aws_security_group.public.id]
}


resource "aws_instance" "db" {
  ami                         = var.instance_info.ami
  instance_type               = var.instance_info.instance_type 
  subnet_id                   = aws_subnet.cocus-private-subnet.id
  key_name                    = "cocus"
  user_data = data.template_file.mysql.rendered
  tags = {
    Name = "${var.project-tag.Name}-database"
  }
  vpc_security_group_ids = [aws_security_group.private.id]
  depends_on = [
    aws_nat_gateway.cocus-ng
  ]
}


