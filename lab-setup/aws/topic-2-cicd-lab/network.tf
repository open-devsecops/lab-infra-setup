resource "aws_vpc" "lab_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    instance_tenancy = "default" 
    
    tags = {
        Name = "lab_vpc"
    }
}

/* Lab Public Subnet */
resource "aws_subnet" "lab_public_subnet" {
 vpc_id     = aws_vpc.lab_vpc.id
 cidr_block = "10.0.1.0/24"
 availability_zone = var.availability_zone
 map_public_ip_on_launch = false
 
 tags = {
   Name = "lab_pub_subnet"
 }
}


## Internet Gateway
resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.lab_vpc.id
 
 tags = {
   Name = "lab_vpc_igw"
 }
}

## Route Table for Intenet Gateway
resource "aws_route_table" "lab_public_route_table" {
 vpc_id = aws_vpc.lab_vpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.igw.id
 }
 
 tags = {
   Name = "lab_pub_rt"
 }
}


resource "aws_route_table_association" "lab_pub_sub_rt"{
    subnet_id = aws_subnet.lab_public_subnet.id
    route_table_id = aws_route_table.lab_public_route_table.id
}


resource "aws_security_group" "lab" {
  vpc_id = aws_vpc.lab_vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Jenkins Webhooks"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  ingress {
    description      = "Wireguard"
    from_port        = var.wg_port
    to_port          = var.wg_port
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}