#!/bin/bash

# 全局变量
set -a
base_dir=${HOME}/.K8sAddon

# 日志模块
fn_log_info()  { TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S'); echo -e "$TIMESTAMP \033[32m[INFO]\033[0m $1"; }
fn_log_warn()  { TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S'); echo -e "$TIMESTAMP \033[33m[WARN]\033[0m $1"; }
fn_log_error() { TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S'); echo -e "$TIMESTAMP \033[31m[ERROR]\033[0m $1"; }


# j2模板文件渲染
fn_j2_to_files() {

    for values in ${base_dir}/templates/${filename}/*.j2; do
        set -a
        . ${base_dir}/vars/${env_var}/${filename}
        j2_name=$(basename "$values")
       # envsubst < ${values} > ${values%%.*}-${env_var}.yaml
        manifests_dir=${base_dir}/manifests/${env_var}/${filename}
        if [ ! -d "$manifests_dir" ];then
            mkdir -p $manifests_dir
        fi
        envsubst < ${values} > ${manifests_dir}/${j2_name%.*}

        [ $? = '0' ] && fn_log_info "渲染成功,生成文件 ${manifests_dir}/${j2_name%.*}"
    done

}