output "security_group" {
  description = "Security Group"
  value       = oci_core_network_security_group.create_security_group
}

output "security_group_id" {
  description = "Security Group ID"
  value       = oci_core_network_security_group.create_security_group.id
}

output "security_group_rules" {
  description = "Security Group Rules"
  value       = try(oci_core_network_security_group_security_rule.create_security_group_rules, null)
}
