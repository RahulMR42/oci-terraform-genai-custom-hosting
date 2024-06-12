#!/bin/bash
## Copyright (c) 2024, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
set -e
print_log() {
  echo "[$(date)] [$1] - $2"
  if [ ${1} == "Error" ] ;then
    exit 0
  fi
}

file_exist(){
    if [ -e $1 ] ;then print_log "Info" "file $1 available"; else print_log "Error" "Missing $1" ; fi
}

python_setup() {
    print_log "Info" "Python setup in progress"
    sudo update-alternatives --config python
    sudo dnf install python3-devel -yq
    sudo dnf install ${llamacpp_python_version}-devel -yq
    sudo yum install gcc-c++ -yq
    uv venv env
    source env/bin/activate
    uv pip install -r $1
    print_log "Info" "End of python setup"
}
hf_action(){
    print_log "Info" "Starting HF model download"
    huggingface-cli login --token ${llamacpp_hf_token}
    if [ "${llamacpp_download_llm}" == "YES" ] ;then
        huggingface-cli download ${llamacpp_model_hf_path} ${llamacpp_absolute_gguf} --local-dir ${llamacpp_llm_path}/${llamacpp_mode_alias}
    fi
    print_log "Info" "End of HF actions"

}
firewall_actions(){
    print_log "Info" "Starting Firewall config"
    sudo firewall-cmd  --zone=public --permanent --add-port ${llamacpp_default_port}/tcp
    sudo firewall-cmd  --zone=public --permanent --add-port ${llamacpp_openapi_port}/tcp
    sudo firewall-cmd --reload
    sudo firewall-cmd --list-all
    print_log "Info" "End of firewall configuration"
}
set_startup_script(){
    rm bash.sh 2>/dev/null
    export llamacpp_api_key=`uuidgen`
    echo "${PWD}/env/bin/python -m llama_cpp.server --model ${llamacpp_llm_path}/${llamacpp_mode_alias}/${llamacpp_absolute_gguf} --model_alias ${llamacpp_mode_alias} --port ${llamacpp_default_port} --host 0.0.0.0 --api_key ${llamacpp_api_key}  >>${llamacpp_service_log_path}" >>bash.sh
    print_log "Info" "Created a startup script"
    export llamacpp_service_name=${llamacpp_service_name}
    cat llamacpp.svc.tmp |envsubst >llamacpp.svc
    print_log "Info" "Created a service file"
    sudo cp llamacpp.svc /etc/systemd/system/${llamacpp_service_name}.service
    sudo systemctl daemon-reload
    sudo systemctl enable ${llamacpp_service_name}
    sudo systemctl stop ${llamacpp_service_name}
    print_log "Info" "Created a service ${llamacpp_service_name}"
    rm llamacpp.svc
}
final_message(){
    echo "----------------------------------------------------------------------"
    echo "Start service - sudo systemctl start ${llamacpp_service_name}"
    echo "Watch LLM loading progress - tail -f ${llamacpp_service_log_path}"
    echo "Url to Access - http:<IP>:${llamacpp_default_port}/docs or /redoc"
    echo "Access key = ${llamacpp_api_key}"
    echo "----------------------------------------------------------------------"
}

print_log "Info" "Starting the script"
file_exist "llamacpp.svc.tmp"
file_exist "config.cfg"
file_exist "requirements.txt"
source config.cfg
python_setup "requirements.txt"
hf_action
firewall_actions
set_startup_script
final_message
