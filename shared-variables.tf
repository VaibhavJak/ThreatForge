variable "environment" {
  description = "The name of the environment for malware analysis lab"
  default     = "malware-analysis-lab"
}

variable "ami" {
  description = "The Amazon Machine Image (AMI) ID for the FlareVM instance"
}

variable "account" {
  description = "The AWS account ID for resource deployment"
}

variable "region" {
  description = "The AWS region for resource deployment"
  default     = "eu-west-1"
}

variable "enable_guacamole" {
  description = "Enable Apache Guacamole for remote access to FlareVM without internet"
  default     = false
}

variable "enable_inetsim" {
  description = "Enable INetSim for network simulation in isolated environments"
  default     = false
}