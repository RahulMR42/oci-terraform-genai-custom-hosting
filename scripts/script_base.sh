#!/bin/bash
## Copyright (c) 2024, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
set -e
#Variables
llm_user="opc"
init_log_folder="logs"
init_log_file="${log_folder}/init_logs.log"
python_version="python3.11"
pip_version="pip3.11"
#execution
echo "[`date`]--- Start of Script ---"
sudo dnf install git -y
sudo dnf install ${python_version} -y
sudo dnf install ${python_version}-pip -y
echo "[`date`]--- Start of Script ---"
sudo /usr/libexec/oci-growfs -y
lsblk
df -h
${pip_version} install virtualenv uv

