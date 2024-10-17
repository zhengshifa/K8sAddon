#!/bin/bash


# 切换到指定目录
cd "$(pwd)/K8sAddon"

# 输出当前目录，验证切换是否成功
pwd


#SCRIPT_DIR=$(dirname "$0")
#echo "Current script directory: $SCRIPT_DIR"


#set -a
#. c:\Users\Administrator\zhengshifa\K8sAddon\/vars/helm-dashboard
#envsubst < ../templates/helm-dashboard/values.yaml.j2  >  ../templates/helm-dashboard/values.yaml