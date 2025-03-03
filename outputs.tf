output "flarevm_ip" {
  description = "Public or private IP of the FlareVM instance based on configuration"
  value       = var.enable_guacamole == false ? aws_instance.flarevm.public_ip : aws_instance.flarevm.private_ip
}

output "guacamole_public_ip" {
  description = "Public IP of the Apache Guacamole instance"
  value       = var.enable_guacamole == false ? null : aws_instance.guacamole[0].public_ip
}

output "guacamole_credentials" {
  description = "Credentials for accessing Apache Guacamole"
  value       = var.enable_guacamole == false ? null : data.external.guacamole_credentials[0].result
}