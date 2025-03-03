resource "aws_instance" "flarevm" {
  ami           = var.ami
  instance_type = "t2.medium"

  network_interface {
    network_interface_id = aws_network_interface.network_interface_flarevm.id
    device_index         = 0
  }

  tags = {
    Name = "${var.environment}-flarevm"
  }
}

resource "aws_instance" "guacamole" {
  count = var.enable_guacamole ? 1 : 0
  ami   = "ami-0efacec4309a32a67" # Bitnami Guacamole AMI

  instance_type = "t2.medium"

  network_interface {
    network_interface_id = aws_network_interface.network_interface_guacamole[0].id
    device_index         = 0
  }

  tags = {
    Name = "${var.environment}-guacamole"
  }
}

data "aws_instance" "guacamole_id" {
  count = var.enable_guacamole ? 1 : 0
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  filter {
    name   = "tag:Name"
    values = ["${var.environment}-guacamole"]
  }
  depends_on = [aws_instance.guacamole]
}

# Wait 5 minutes for Guacamole initialization
resource "time_sleep" "wait_5_min" {
  count      = var.enable_guacamole ? 1 : 0
  depends_on = [data.aws_instance.guacamole_id[0]]

  create_duration = "5m"
}

# Get Guacamole credentials from console output
data "external" "guacamole_credentials" {
  count   = var.enable_guacamole ? 1 : 0
  program = ["bash", "get_password.sh"]
  query = {
    "instanceid" = data.aws_instance.guacamole_id[0].id
  }
  depends_on = [time_sleep.wait_5_min]
}

# Linux instance with INetSim
resource "aws_instance" "inetsim" {
  count         = var.enable_inetsim ? 1 : 0
  ami           = "ami-05e786af422f8082a"
  instance_type = "t3.small"

  network_interface {
    network_interface_id = aws_network_interface.network_interface_inetsim[0].id
    device_index         = 0
  }

  tags = {
    Name = "${var.environment}-inetsim"
  }

  user_data = <<-EOF
#!/bin/bash

sudo echo "deb http://www.inetsim.org/debian/ binary/" > /etc/apt/sources.list.d/inetsim.list
sudo echo "deb-src http://www.inetsim.org/debian/ source/" >> /etc/apt/sources.list.d/inetsim.list
sudo wget -O - https://www.inetsim.org/inetsim-archive-signing-key.asc | apt-key add -
sudo apt update -y
sudo apt install -y inetsim

# Configure INetSim to listen on all interfaces
sudo sed -i 's/^#service_bind_address.*/service_bind_address                 0.0.0.0/' /etc/inetsim/inetsim.conf

# Change DNS configuration for INetSim
sudo sed -i 's/^#dns_default_ip.*/dns_default_ip                 172.16.10.6/' /etc/inetsim/inetsim.conf

# Stop systemd-resolved to allow INetSim to listen for DNS requests
sudo systemctl stop systemd-resolved

# Restart INetSim to apply configuration changes
sudo service inetsim restart
  EOF
}