## Copyright (c) 2024, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  #private_key = try(file(var.private_key_path), var.private_key)
  ssh_public_key = try(file(var.ssh_public_key_path), var.ssh_public_key)

  ssh_public_keys = join("\n", [
    trimspace(local.ssh_public_key),
    trimspace(tls_private_key.tls_private_key.public_key_openssh)
  ])

}