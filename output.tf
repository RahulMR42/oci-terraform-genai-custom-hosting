output "ARM_VM_PublicIPs" {
  value = try(oci_core_instance.cpu_arm_hosts[*].public_ip, "NotApplicable")
}