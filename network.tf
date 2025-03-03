# Create VPC for the malware analysis lab
resource "aws_vpc" "lab_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# Create Internet Gateway for public access
resource "aws_internet_gateway" "lab_ig" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

# Public Subnet for FlareVM and Guacamole instances
resource "aws_subnet" "lab_public_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "172.16.10.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet"
    Environment = var.environment
  }
}

# Routing table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = var.environment
  }
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.lab_ig.id
}

# Associate public subnet with the routing table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.lab_public_subnet.id
  route_table_id = aws_route_table.public.id
}

# Security group for FlareVM with internet access
resource "aws_security_group" "security_group_flarevm_internet" {
  name        = "security_group_flarevm_internet"
  description = "Allow RDP access from the internet"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    description      = "Allow RDP inbound traffic"
    from_port        = 3389
    to_port          = 3389
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.environment}-internet"
  }
}

# Security group for FlareVM without internet access
resource "aws_security_group" "security_group_flarevm_no_internet" {
  count       = var.enable_guacamole ? 1 : 0
  name        = "security_group_flarevm_no_internet"
  description = "Allow RDP access from Guacamole"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    description = "Allow RDP inbound traffic"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["172.16.10.5/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.16.10.6/32"]
  }

  tags = {
    Name = "${var.environment}-no-internet"
  }
}

# Security group for Apache Guacamole
resource "aws_security_group" "security_group_guacamole" {
  count       = var.enable_guacamole ? 1 : 0
  name        = "security_group_guacamole"
  description = "Allow HTTPS access from the internet"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    description      = "Allow HTTPS inbound traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.environment}-guacamole"
  }
}

# Security group for INetSim
resource "aws_security_group" "security_group_inetsim" {
  count       = var.enable_inetsim ? 1 : 0
  name        = "security_group_inetsim"
  description = "Allow traffic from FlareVM"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    description = "Allow traffic from FlareVM"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.16.10.4/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.environment}-inetsim"
  }
}

# Network interface for FlareVM
resource "aws_network_interface" "network_interface_flarevm" {
  subnet_id       = aws_subnet.lab_public_subnet.id
  private_ips     = ["172.16.10.4"]
  security_groups = var.enable_guacamole == false ? [aws_security_group.security_group_flarevm_internet.id] : [aws_security_group.security_group_flarevm_no_internet[0].id]

  tags = {
    Name = "${var.environment}-interface-flarevm"
  }
}

# Network interface for Apache Guacamole
resource "aws_network_interface" "network_interface_guacamole" {
  count           = var.enable_guacamole ? 1 : 0
  subnet_id       = aws_subnet.lab_public_subnet.id
  private_ips     = ["172.16.10.5"]
  security_groups = [aws_security_group.security_group_guacamole[0].id]

  tags = {
    Name = "${var.environment}-interface-guacamole"
  }
}

# Network interface for INetSim
resource "aws_network_interface" "network_interface_inetsim" {
  count           = var.enable_inetsim ? 1 : 0
  subnet_id       = aws_subnet.lab_public_subnet.id
  private_ips     = ["172.16.10.6"]
  security_groups = [aws_security_group.security_group_inetsim[0].id]

  tags = {
    Name = "${var.environment}-interface-inetsim"
  }
}