# Copyright (c) 2024 Oracle and/or its affiliates.

resource oci_core_instance gpu_llm_hosts {
  count = var.create_gpu_based_compute_instances ? var.count_gpu_compute_instances : 0
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  shape = var.instance_shape
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  agent_config {
    is_management_disabled = "false"
    is_monitoring_disabled = "false"
  }
  create_vnic_details {
    assign_public_ip = "true"
    display_name  = "gpu_llm_host_publicip"
    skip_source_dest_check = "false"
    subnet_id              = oci_core_subnet.subnet.id
  }
  display_name      = "${var.app_name}_llmhost"
  metadata = {
    ssh_authorized_keys = local.ssh_public_keys
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  source_details {
    source_id = lookup(data.oci_core_images.InstanceImageOCID.images[0], "id")
    source_type = "image"
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
    boot_volume_vpus_per_gb = var.boot_volume_vpus_per_gb
  }
  lifecycle {
    ignore_changes = [defined_tags]
  }
  #-ENV Setup
  connection {
    agent       = false
    timeout     = "60m"
    host        = oci_core_instance.gpu_llm_hosts.public_ip
    user        = "opc"
    private_key = tls_private_key.tls_private_key.private_key_pem
  }

  provisioner "file" {
    source      = "scripts/script_base.sh"
    destination = "/home/opc/script_base.sh"

    connection {
      private_key = tls_private_key.tls_private_key.private_key_pem
      user = "opc"
      host = self.public_ip
    }
  }
  #-Copy default service
  provisioner "file" {
    source      = "scripts/script_vllm.sh"
    destination = "/home/opc/script_vllm.sh"

    connection {
      private_key = tls_private_key.tls_private_key.private_key_pem
      user = "opc"
      host = self.public_ip
    }
  }

  #Copy openai service
  provisioner "file" {
    source      = "scripts/script_llamacpp.sh"
    destination = "/home/opc/script_llamacpp.sh"

    connection {
      private_key = tls_private_key.tls_private_key.private_key_pem
      user = "opc"
      host = self.public_ip
    }
  }
  #Running Exec
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/script_base.sh",
      "bash /home/opc/script_base.sh"
    ]
    connection {
      private_key = tls_private_key.tls_private_key.private_key_pem
      user = "opc"
      host = self.public_ip
    }
  }
}
