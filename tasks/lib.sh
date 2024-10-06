#!/bin/bash

# 全局变量
base_dir=/etc/k8s-addon

# 日志模块
APPNAME=$(basename "$0" | sed "s/\.sh$//")
fn_log_info()  { echo "$APPNAME: $1"; }
fn_log_warn()  { echo "$APPNAME: [WARNING] $1" 1>&2; }
fn_log_error() { echo "$APPNAME: [ERROR] $1" 1>&2; }

# j2模板文件渲染
fn_j2_to_files() {

    for values in ${base_dir}/templates/${filename}/*.j2; do
        . vars/${filename}
        envsubst < $values > ${values%.*}
        [ $? = '0' ] && fn_log_info "渲染成功,生成文件 ${values%.*}"
    done

}