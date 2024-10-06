#!/bin/bash
## 部署

# 全局变量
base_dir=/etc/k8s-addon

#加载公共模块
. ${base_dir}/tasks/lib.sh

main() {
    fn_deploy
}

fn_deploy() {

    for file in "$base_dir"/vars/*; do
        [ -e "$file" ] || fn_log_error "$file 配置文件不存在"  # 检查文件是否存在
        filename=$(basename "$file") # 获取变量的文件名
        . $file # 加载配置变量文件
        shopt -s nocasematch  # 开启不区分大小写

        if [ -n "$helm_install" ];then
            fn_helm_deploy
        else
            fn_yaml_deploy
        fi
        sleep 1
    done
}


# helm部署/删除/升级/回滚/版本控制
fn_helm_deploy() {

    if [ "$helm_install" == 'yes' ];then
        fn_j2_to_files  # 模板文件渲染
        # helm部署app
        helm upgrade ${release_name} --install --create-namespace \
        -n ${namespace} -f ${base_dir}/templates/${filename}/values.yaml \
        ${base_dir}/files/${filename}-${chart_ver}.tgz $>/dev/null
        [ $? == 0 ] || fn_log_error "helm安装 ${release_name} 失败" ; continue
    elif [  "$helm_install" == 'no' ];then
        # 删除app
        helm uninstall ${release_name} -n ${namespace} $>/dev/null
        [ $? == 0 ] || fn_log_error "helm删除 ${release_name} 失败" ; continue
    else
        fn_log_error "$file 变量helm_install参数值未设置正确" ; continue
    fi
}

# yaml部署
fn_yaml_deploy() {

    if [ "$yaml_install" == 'yes' ];then
        fn_j2_to_files  # 模板文件渲染
        # yaml部署app
        kubectl apply -f ${base_dir}/templates/${filename}/
        [ $? == 0 ] || fn_log_error "安装 ${release_name} yaml资源 失败" ; continue
    elif [  "$yaml_install" == 'no' ];then
        # 删除app
        kubectl delete -f ${base_dir}/templates/${filename}/
        [ $? == 0 ] || fn_log_error "删除 ${release_name} yaml资源 失败" ; continue
    else
        fn_log_error "$file 变量yaml_install参数值未设置正确" ; continue
    fi
}

main