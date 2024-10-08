#!/bin/bash
## 部署


set -a  #加载到环境变量,下面的命令
#加载公共模块
. ${base_dir}/tasks/lib.sh

main() {
    fn_deploy
}

fn_deploy() {

    for file in "$base_dir"/vars/*; do
        [ -e "$file" ] || fn_log_error "$file 配置文件不存在"  # 检查文件是否存在
        filename=$(basename "$file") # 获取变量的文件名
        . $file # 加载变量文件
        shopt -s nocasematch  # 开启不区分大小写

        if [ -n "$helm_install" ];then
            fn_helm_install
        elif [ -n "$yaml_install" ];then
            fn_yaml_deploy
        else
            fn_log_warn " $file  无需安装/更新  或者 实例请配置正确的 helm_upgrade/helm_install/yaml_install 参数"
        fi

        sleep 1
    done
}


# helm部署/删除
fn_helm_install() {

    if [ "$helm_install" == 'yes' ];then
        fn_j2_to_files  # 模板文件渲染

        # helm部署app
        if [ "$helm_upgrade" == 'yes' ];then
            helm upgrade ${release_name} --install --create-namespace \
            -n ${namespace} -f ${base_dir}/templates/${filename}/values.yaml \
            ${base_dir}/files/${filename}-${chart_ver}.tgz &>/dev/null
            [ $? == 0 ] && fn_log_info "${filename} 使用helm更新成功 release名字为 ${release_name}" || fn_log_error "helm更新 ${release_name} 失败"
        elif ! helm status ${release_name} -n ${namespace} &>/dev/null ;then
            helm install ${release_name} --install --create-namespace \
            -n ${namespace} -f ${base_dir}/templates/${filename}/values.yaml \
            ${base_dir}/files/${filename}-${chart_ver}.tgz &>/dev/null
            helm status ${release_name} -n ${namespace} &>/dev/null
            [ $? == 0 ] && fn_log_info "${filename} 使用helm安装成功 release名字为 ${release_name}" || fn_log_error "helm安装 ${release_name} 失败"
        else
            fn_log_warn "${filename} 已经helm安装过 release名字为 ${release_name}"; 
        fi

    elif [  "$helm_install" == 'no' ];then
        # 删除app
        helm uninstall ${release_name} -n ${namespace} &>/dev/null
        [ $? == 0 ] && fn_log_info "${filename} 使用helm删除成功 release名字为 ${release_name}" || fn_log_error "${filename} 使用helm删除失败 release名字为 ${release_name}" 

    else
        fn_log_error "$file 变量install参数值未设置正确" ; continue
    fi
}


# yaml部署
fn_yaml_deploy() {

    if [ "$yaml_install" == 'yes' ];then
        fn_j2_to_files  # 模板文件渲染
        # yaml部署app
        kubectl apply -f ${base_dir}/templates/${filename}/  &>/dev/null
        [ $? == 0 ] && fn_log_info "yaml 部署 ${filename}资源成功" || fn_log_error "安装 ${release_name} yaml资源 失败" ; continue
    elif [  "$yaml_install" == 'no' ];then
        # 删除app
        kubectl delete -f ${base_dir}/templates/${filename}/  &>/dev/null
        [ $? == 0 ] && fn_log_info "yaml 删除 ${filename}资源成功" || fn_log_error "删除 ${release_name} yaml资源 失败" ; continue
    else
        fn_log_error "$file 变量yaml_install参数值未设置正确" ; continue
    fi
}

main