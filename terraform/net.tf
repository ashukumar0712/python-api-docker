# Providing a reference to our default VPC
resource "aws_default_vpc" "default_vpc" {
    tags = {
    Name = "vpcflasktest"
  }
}

# Providing a reference to our default subnets
resource "aws_default_subnet" "default_subnet_a" {
    availability_zone = "eu-west-2a"
    tags = {
        Name = "subnetflasktesta"
    }
}

resource "aws_default_subnet" "default_subnet_b" {
    availability_zone = "eu-west-2b"
    tags = {
        Name = "subnetflasktestb"
    }
}

resource "aws_default_subnet" "default_subnet_c" {
    availability_zone = "eu-west-2c"
    tags = {
        Name = "subnetflasktestc"
    }
}