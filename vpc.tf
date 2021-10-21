resource "aws_vpc" "my-vpc" {
	cidr_block = "10.0.0.0/16"
	enable_dns_support = "true"
	enable_dns_hostnames = "true"
	instance_tenancy = "default"
	tags = {
		Name = "my-vpc"
 	}
}

resource "aws_subnet" "public-subnet" {
	vpc_id = "${aws_vpc.my-vpc.id}"
	cidr_block = "10.0.0.0/24"
	map_public_ip_on_launch = "true"
	availability_zone = "ap-south-1b"
	tags = {
		Name = "public-subnet"
	}
}

resource "aws_subnet" "private_subnet" {
	vpc_id = "${aws_vpc.my-vpc.id}"
	cidr_block = "10.0.1.0/24"
	map_public_ip_on_launch = "false"
	availability_zone = "ap-south-1b"
	tags = {
		Name = "private-subnet"
	}
}

resource "aws_internet_gateway" "my-igw" {
	vpc_id = "${aws_vpc.my-vpc.id}"
	tags = {
		Name = "my-igw"
	}
}

resource "aws_route_table" "my-route" {
	vpc_id = "${aws_vpc.my-vpc.id}"
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.my-igw.id}"
	}
	tags = {
		Name = "my-route"
	}
}

resource "aws_route_table_association" "public-igw" {
	subnet_id = "${aws_subnet.public-subnet.id}"
	route_table_id = "${aws_route_table.my-route.id}"
}

resource "aws_instance" "Terraform-EC2" {
	subnet_id = "${aws_subnet.public-subnet.id}"
	ami = "ami-041d6256ed0f2061c"
	instance_type = "t2.micro"
	key_name = "aws_ansible"
	vpc_security_group_ids= ["${aws_security_group.ssh-allowed.id}"]
	tags = {
		Name = "TerraformEC2-public"
	}
}

resource "aws_instance" "TerraformEC2-private" {
	subnet_id = "${aws_subnet.private_subnet.id}"
	ami = "ami-041d6256ed0f2061c"
	instance_type = "t2.micro"
	tags = {
		Name = "TerraformEC2-private"
	}
}

resource "aws_security_group" "ssh-allowed" {
	vpc_id = "${aws_vpc.my-vpc.id}"
	
	egress {
		from_port = 0
		to_port = 0
		protocol = -1
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
		from_port = 22
		to_port = 22
		protocol= "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	tags = {
		Name = "ssh-allowed"
	}
}



