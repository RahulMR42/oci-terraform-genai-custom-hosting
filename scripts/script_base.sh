#!/bin/bash
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
mkdir llm_store
