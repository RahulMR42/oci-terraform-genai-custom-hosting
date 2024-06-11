## Copyright (c) 2024, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

### Common Variables
variable "tenancy_ocid" {
  description = "OCI Tenancy OCID"
}
variable "compartment_ocid" {
  description = "OCI Compartment OCID"
}
variable "user_ocid" {
  description = "User OCID"
}
variable "fingerprint" {
  description = "User fingerprint"
}
variable "private_key_path" {
  description = "User key path"
}
variable "region" {
  description = "OCI Region"
}
variable "app_name" {
  default     = "GenaiCustomHosting"
  description = "A short prefix for resource"
}
variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "0.0"
}
variable "availability_domain_name" {
  default = ""
}
### VCN Related Variables
variable "VCN-CIDR" {
  default = "10.0.0.0/16"
}

variable "Subnet-CIDR" {
  default = "10.0.1.0/24"
}
### LLM Specific ports for VCN
variable "openai_port" {
  default = 8001
  description = "Port number for inference"
}
variable "cluster_com_port" {
  default = 6739
  description = "Port for Ray cluster"
}
variable "default_port" {
  default = 8000
  description = "Default inference port"
}

### Variables for Compute - GPU
variable "create_gpu_based_compute_instances" {
  default = true
  description = "Set False to disable GPU based compute creation"
}
variable "count_gpu_compute_instances" {
  default = 1
  description = "No of GPU Compute machines to create"
}
variable "boot_volume_size_in_gbs" {
  default = 1700
  description = "boot bolume size"
}
variable "boot_volume_vpus_per_gb" {
  default = 10
  description = "boot volume performance factor (multiple of 10) "
}
variable "instance_shape" {
  description = "Instance Shape"
  default     = "BM.GPU.A10.4"
}

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "8"
}
variable "gpu_os_version"{
  description = "Validated os image"
  default = "Oracle-Linux-8.9-Gen2-GPU-2024.04.19-0"
}
variable "ssh_public_key" {
  type = string
  description = "The public SSH key to use for the compute instance"
  default     = ""
}
variable "ssh_public_key_path" {
  type = string
  description = "The path to the public SSH key to use for the compute instance"
  default     = ""
}