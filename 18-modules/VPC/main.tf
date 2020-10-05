resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = var.test_vpc
  }
}
resource "aws_internet_gateway" "testIGW" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = var.testIGW
  }
}

#Syntax for variables:
#var.variable_name

#aws_internet_gateway.testIGW.id
##Resource reference
##resource_name.logical_name.attribute_reference
##aws_vpc.main.owner_id

resource "aws_route_table" "publicRt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = var.rt_cidr
    gateway_id = aws_internet_gateway.testIGW.id
  }
  tags = {
    Name = "publicRT"
  }
}
## or we can use the follwing code for above
##resource "aws_route_table_association" "b" {
##gateway_id     = aws_internet_gateway.foo.id
##route_table_id = aws_route_table.bar.id
##}

resource "aws_subnet" "test_subnet" {

  cidr_block = var.public_subnet
  vpc_id     = aws_vpc.main.id #take the id from line 6 
  #availability_zone = us-west-1a
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet"
  }


}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.publicRt.id
  subnet_id      = aws_subnet.test_subnet.id
}

resource "aws_security_group" "security" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = var.rds_port
    to_port     = var.rds_port
    protocol    = "tcp"
    cidr_blocks = [var.rt_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.rt_cidr]
  }

  tags = {
    Name = "allow_443"
  }
}

output "subnet" {
value = aws_subnet.test_subnet.id
}

output "sg" {
value = aws_security_group.security.id
}