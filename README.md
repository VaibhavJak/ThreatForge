# ThreatForge

## Overview
This project automates the creation of a secure, isolated malware analysis environment on AWS using Terraform. The lab is designed to analyze malware samples in a controlled environment, with options for internet access or complete isolation using Apache Guacamole for remote access. The lab includes FlareVM for malware analysis and INetSim for network simulation.

## Features
- **FlareVM**: A Windows-based VM pre-configured with malware analysis tools.
- **Apache Guacamole**: Provides remote access to FlareVM in isolated environments.
- **INetSim**: Simulates network services (DNS, HTTP, FTP) for malware interaction without internet access.
- **Terraform Automation**: Infrastructure as Code (IaC) to create, destroy, and manage the lab environment.

## Tech Stack
- **Cloud Provider**: AWS (EC2, VPC, Security Groups, IAM)
- **Automation**: Terraform
- **Malware Analysis Tools**: FlareVM, INetSim
- **Remote Access**: Apache Guacamole
- **Scripting**: Bash, PowerShell

## Skills Demonstrated
- Cloud infrastructure design and deployment (AWS)
- Infrastructure as Code (Terraform)
- Malware analysis environment setup
- Network security and isolation
- Automation and scripting (Bash, PowerShell)

## Usage
1. Clone the repository:
   ```bash
   git clone https://github.com/adanalvarez/AWS-malware-lab
   cd aws-malware-lab

2.Create a shared.auto.tfvars.json file with your AWS account details and AMI ID, for instance:

{
    "environment": "malware-lab",
    "ami": "ami-xxxxxxxxxxxxxxxxx",
    "account": "222222222222",
    "region": "eu-west-1",
    "enable_guacamole": false,
    "enable_inetsim": false
}

3.Initialize Terraform and deploy the lab:
  terraform init
  terraform apply

4.Access the FlareVM instance via RDP or Apache Guacamole, depending on the configuration.

5.Destroy the lab after use to minimize costs:
  terraform destroy
