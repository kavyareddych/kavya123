# provider details
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
# step-1 creating VPC
resource "aws_vpc" "my-vpc-1" {
  cidr_block = var.cidr_block
  tags = {
    Name = "my-vpc"
  }
}
# step-2 creating internet gateway
resource "aws_internet_gateway" "my-igw-1" {
  vpc_id = aws_vpc.my-vpc-1.id
  tags = {
    Name = "my-igw"
  }
}
#step-3 creating route table
resource "aws_route_table" "my-rt-1" {
  vpc_id = aws_vpc.my-vpc-1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw-1.id
  }
  tags = {
    Name = "my-rt"
  }
}
# step-4 creating subnet
resource "aws_subnet" "my-subnet" {
  vpc_id            = aws_vpc.my-vpc-1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zone
  tags = {
    Name = "my-subnet-1"
  }
}
#step-5: associate subnet with route table
resource "aws_route_table_association" "my-rt-association" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-rt-1.id

}
#step-6 : creating security group and allow ports 22,80,443
resource "aws_security_group" "my-sg-1" {
  vpc_id = aws_vpc.my-vpc-1.id
  ingress {

    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "my-sg"
  }
}
#step-7 : create network interface with an IP in subnet created in step-4
resource "aws_network_interface" "my-ni" {
  subnet_id       = aws_subnet.my-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.my-sg-1.id]


}
#step-8: assigning elastic ip to network interface
resource "aws_eip" "name" {
  vpc                       = true
  network_interface         = aws_network_interface.my-ni.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.my-igw-1]

}

#step-9: creating ubuntu instance and downloading apache2

resource "aws_instance" "ubuntu" {
  ami               = var.ami
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.my-ni.id

  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo bash -c 'echo your very first web server > /var/www/html/index.html'
    EOF

  tags = {
    Name = "tf-ubuntu"
  }

}