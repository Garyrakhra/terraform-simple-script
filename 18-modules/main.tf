provider "aws" {
  region  = "us-west-1"
  profile = "terraform1"

}

module "vpc-gary" {
source = "./VPC"
vpc_cidr = var.vpc_cidr
test_vpc = var.vpc_name
testIGW = var.testIGW_1
rt_cidr = var.rt_cidr
public_subnet = var.public_sb
rds_port = var.rds_portnuber

}

module "ec2-instances" {
source = "./EC2"
server_count = var.server_count
ami_id = var.ami_id
instance_type = var.instance_type
test_subnet = module.vpc-gary.subnet
security_group = module.vpc-gary.sg
}