
provider "aws" {
  region  = "us-east-1"
}


resource "aws_vpc" "vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "devops-vpc-nov-class"
    Environment = "dev"
    unit        = "web"
  }
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = 1
  cidr_block              = "10.10.6.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name        = "devops-public-subnet-nov-class"
    Environment = "dev"
  }
}

output "public_subnets_id" {
  value       = aws_subnet.public_subnet.*.id
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "devops-igw-nov-class"
    Environment = "dev" 
  }
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "devops-nat-nov-class"
    Environment = "dev"
  }
}


resource "aws_security_group" "default" {
  name        = "devops-sg-nov-class"
  description = "class security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port = "22"
    to_port   = "50"
    protocol  = "-1"
    self      = true
  }
  
  egress {
    from_port = "50"
    to_port   = "100"
    protocol  = "-1"
    self      = "true"
  }
  tags = {
    Name = "devops-sg-nov-class"
    Environment = "dev"
  }
}

