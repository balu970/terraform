## Creating a VPC 
resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"

  tags = {
    Name = "myvpc"
  }
}
## availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

## Creating a subnet01 in us-east-2a
resource "aws_subnet" "sub01" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  cidr_block        = "${var.sub1_cidr}"

  tags = {
    Name = "subnet01"
  }
}
## Creating a subnet02 in us-east-2b
resource "aws_subnet" "sub02" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  cidr_block        = "${var.sub2_cidr}"

  tags = {
    Name = "subnet02"
  }
}
## Creating an Internet Gateway and attched to VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "My_Internet_gateway"
  }
}
## Creating a Route Table
resource "aws_route_table" "route" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "${var.route_cidr}"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "My_Route_table"
  }
}
## Associating Route Table to subnet01
resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.sub01.id}"
  route_table_id = "${aws_route_table.route.id}"
}
## Associating Route Table to subnet02
resource "aws_route_table_association" "Ra" {
  subnet_id      = "${aws_subnet.sub02.id}"
  route_table_id = "${aws_route_table.route.id}"
}

### Creating a new security group
resource "aws_security_group" "My_security" {
  name        = "My_security"
  description = "this SG for allowing all the ports"
  vpc_id      = "${aws_vpc.main.id}"

  ### Adding a new Inbound rules

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ### Adding a new outbound rule with All Traffic

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

### Getting registered AMI ID from AWS
data "aws_ami" "ubuntu" {
  
  most_recent = true
  owners = ["099720109477"] 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]

  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

   filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

}

### Creating a key pair for instance 

resource "aws_key_pair" "My_key" {
  key_name   = "My_key"
  public_key = "${var.key_name}"
}

### Creating user data 

data "template_file" "setup" {
  template = "${file("${path.module}/Templates/first_page.sh")}"
}


### Creating an instance 
resource "aws_instance" "web" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  key_name                    = "${aws_key_pair.My_key.key_name}"
  subnet_id                   = "${aws_subnet.sub01.id}"
  vpc_security_group_ids      = ["${aws_security_group.My_security.id}"]
  user_data                   = "${data.template_file.setup.rendered}"


  tags = {
   Name = "webserver"
  }
}