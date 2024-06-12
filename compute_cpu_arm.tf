## Copyright (c) 2024, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# oci_core_instance.cpu_arm_hosts:
resource "oci_core_instance" "cpu_arm_hosts" {
  count               = var.create_cpu_arm_instances ? var.count_cpu_arm_instances : 0
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "${var.app_name}_cpu_A1"
  shape               = var.arm_instance_shape
  defined_tags        = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  create_vnic_details {
    assign_public_ip       = "true"
    display_name           = "llm_arm_vnic"
    skip_source_dest_check = false
    subnet_id              = oci_core_subnet.subnet.id
  }
  shape_config {

    memory_in_gbs = var.arm_memory_in_gbs
    ocpus         = var.arm_ocpus

  }
  metadata = {
    ssh_authorized_keys = local.ssh_public_keys
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  source_details {
    boot_volume_size_in_gbs = var.arm_boot_volume_size_in_gbs
    boot_volume_vpus_per_gb = var.arm_boot_volume_vpus_per_gb
    source_id               = data.oci_core_images.A1InstanceImageOCID.images[0].id
    source_type             = "image"
  }
  #-ENV Setup
  connection {
    agent       = false
    timeout     = "60m"
    host        = oci_core_instance.cpu_arm_hosts[*].public_ip
    user        = "opc"
    private_key = tls_private_key.tls_private_key.private_key_pem
  }
  #Running folder creation
  provisioner "remote-exec" {
    inline = [
      "mkdir ${var.base_folder}",
      "mkdir ${var.base_folder}/logs",
      "mkdir ${var.base_folder}/llm_store"
    ]
    connection {
      private_key = tls_private_key.tls_private_key.private_key_pem
      user        = "opc"
      host        = self.public_ip
    }
  }
  #Copy base file
  provisioner "file" {
    source      = "scripts"
    destination = var.base_folder

    connection {
      private_key = tls_private_key.tls_private_key.private_key_pem
      user        = "opc"
      host        = self.public_ip
    }
  }
  #Executing base script
  provisioner "remote-exec" {
    inline = [
      "rm -rf ${var.base_folder}/scripts/vllm",
      "rm -rf ${var.base_folder}/scripts/intel_x86",
      "bash ${var.base_folder}/scripts/script_base.sh >>${var.base_folder}/logs/init_log.log"
    ]
    connection {
      private_key = tls_private_key.tls_private_key.private_key_pem
      user        = "opc"
      host        = self.public_ip
    }
  }
}
