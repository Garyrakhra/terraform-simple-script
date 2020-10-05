locals {
    test = {
        Environ = "Production"
        Product = "Java"
        Owner = "DevOps"
    }
}
resource "aws_instance" "server" {
  count         = var.server_count
  ami           = var.ami_id
  instance_type = var.instance_type[count.index]
  subnet_id     = var.test_subnet
  ##it is declaired in the subnet
  ##associate_public_ip_address = true
  key_name        = "s3"
  vpc_security_group_ids = [var.security_group]
  tags = merge(map("Name", "prod-java-${count.index}"),local.test)
  
}