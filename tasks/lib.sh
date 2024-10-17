#!/bin/bash

# 全局变量
base_dir=/etc/k8s-addon

# 日志模块
fn_log_info()  { TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S'); echo -e "$TIMESTAMP \033[32m[INFO]\033[0m $1"; }
fn_log_warn()  { TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S'); echo -e "$TIMESTAMP \033[33m[WARN]\033[0m $1"; }
fn_log_error() { TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S'); echo -e "$TIMESTAMP \033[31m[ERROR]\033[0m $1"; }


# j2模板文件渲染
fn_j2_to_files() {

    for values in ${base_dir}/templates/${filename}/*.j2; do
        set -a
        . vars/${filename}
        envsubst < ${values} > ${values%.*}
        [ $? = '0' ] && fn_log_info "渲染成功,生成文件 ${values%.*}"
    done

}