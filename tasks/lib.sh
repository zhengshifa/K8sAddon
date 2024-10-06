#!/bin/bash

# 全局变量
base_dir=/etc/k8s-addon

# 日志模块
fn_log_info()  { TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S'); echo -e "$TIMESTAMP \033[32mINFO\033[0m $1"; }
fn_log_warn()  { TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S'); echo -e "$TIMESTAMP \033[33mWARN\033[0m $2"; }
fn_log_error() { TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S'); echo -e "$TIMESTAMP \033[31mERROR\033[0m $2"; }


# j2模板文件渲染
fn_j2_to_files() {

    for values in ${base_dir}/templates/${filename}/*.j2; do
        . vars/${filename}
        configContent=$(cat ${base_dir}/vars/${filename})
        yamlTemplate=$(cat ${values})
        printf "$configContent\ncat << EOF\n${yamlTemplate}\nEOF" |bash > ${values%.*}
        [ $? = '0' ] && fn_log_info "渲染成功,生成文件 ${values%.*}"
    done

}