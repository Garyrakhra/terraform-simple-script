provider "aws" {
	region = "us-west-1"
	profile = "terraform1"
}
#1 create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
   tags = {
     Name = "test_vpc"
  }
}
#2 Create AWS Internet Gateway
resource "aws_internet_gateway" "testIGW" {
 vpc_id = aws_vpc.main.id
  tags = {
    Name = "testIGW"
   }
}


#3 Create Aws Route Table and connect with Internet Gateway
resource "aws_route_table" "publicRt" {
	vpc_id = aws_vpc.main.id
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.testIGW.id
			}
	tags = {
		Name = "publicRT"
		}
	}

#4 Create a subnet and map enable Public IP for Internet access

resource "aws_subnet" "test_subnet" {
 cidr_block = "10.0.0.128/25"
 vpc_id = aws_vpc.main.id #take the id from line 6 
 #availability_zone = us-west-1a
 map_public_ip_on_launch = true
 tags = {
   Name =  "public_subnet"
  }


}
#5 Attache route table with subnet
resource "aws_route_table_association" "public" {
	route_table_id = aws_route_table.publicRt.id
	subnet_id = aws_subnet.test_subnet.id
}

#6 Create a Security Group	
resource "aws_security_group" "security" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_3389"
  }
}

#7 Create a EC2 instance 
resource "aws_instance" "server" {
 #count         = 2
  ami = "ami-022b8726b80fd1330"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.test_subnet.id 
   key_name = "s3"
  security_groups = [aws_security_group.security.id]
  tags = {
    Name = "2016server" 
  }
}