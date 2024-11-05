#!/bin/bash
## 部署/升级/版本控制/回滚/卸载


set -a  #加载到环境变量,下面的命令
#加载公共模块
. tasks/lib.sh

main() {
    fn_deploy
}

fn_deploy() {

    for env_var in $(grep -v '^#' "$base_dir"/vars/global_vars | grep -v '^\s*$'); do

        # 环境切换
        if ! which kubectx;then
            fn_log_error "未安装kubectx" 
            exit 0;
        else
            kubectx "$env_var"
        fi

        for file in "$base_dir"/vars/$env_var/*; do
            [ -e "$file" ] || fn_log_error "$file 配置文件不存在"  # 检查文件是否存在
            filename=$(basename "$file") # 获取变量的文件名
            manifests_dir=${base_dir}/manifests/${env_var}/${filename}
            (  # (xx) 隔离变量
            echo -e "\033[35m 正在执行 环境:$env_var 中 $filename 相关操作...\033[0m"
            . $file # 加载变量文件
            shopt -s nocasematch  # 开启不区分大小写


            if [ -n "$helm_install" ];then
                fn_helm_install
            elif [ -n "$yaml_install" ];then
                fn_yaml_deploy
            else
                fn_log_warn " $file  无需安装/更新  或者 实例请配置正确的 helm_upgrade/helm_install/yaml_install 参数"
            fi
            echo -e "\033[35m 环境:$env_var  $filename 处理完成\033[0m"

            )
            sleep 1
        done

    done
    
}


# helm部署/删除
fn_helm_install() {

    if [ "$helm_install" == 'yes' ];then
        fn_j2_to_files  # 模板文件渲染

        # helm部署app
        if [ "$helm_upgrade" == 'yes' ];then
            helm upgrade ${release_name} --install --create-namespace \
            -n ${namespace} -f ${manifests_dir}/values.yaml \
            ${base_dir}/files/${filename}-${chart_ver}.tgz &>/dev/null
            [ $? == 0 ] && fn_log_info "${filename} 使用helm更新成功 release名字为 ${release_name}" || fn_log_error "helm更新 ${release_name} 失败"
        elif ! helm status ${release_name} -n ${namespace} &>/dev/null ;then
            helm install ${release_name} --create-namespace \
            -n ${namespace} -f ${manifests_dir}/values.yaml \
            ${base_dir}/files/${filename}-${chart_ver}.tgz &>/dev/null
            helm status ${release_name} -n ${namespace} &>/dev/null
            [ $? == 0 ] && fn_log_info "${filename} 使用helm安装成功 release名字为 ${release_name}" || fn_log_error "helm安装 ${release_name} 失败"
        else
            fn_log_warn "${filename} 已经helm安装过 release名字为 ${release_name}"; 
        fi

    elif [  "$helm_install" == 'no' ];then
        # 删除app
        helm uninstall ${release_name} -n ${namespace} &>/dev/null
        helm template ${release_name} -n ${namespace} -f  ${manifests_dir}/values.yaml  ${base_dir}/files/${filename}-${chart_ver}.tgz  --output-dir  ${manifests_dir}
        kubectl delete -f ${manifests_dir}/${filename}/templates/  &>/dev/null
        fn_log_info "${filename} 使用helm删除成功 release名字为 ${release_name}"

    else
        fn_log_error "$file 变量install参数值未设置正确"
    fi
}


# yaml部署
fn_yaml_deploy() {

    if [ "$yaml_install" == 'yes' ];then
        fn_j2_to_files  # 模板文件渲染
        # yaml部署app
        kubectl apply -f ${manifests_dir}  &>/dev/null
        [ $? == 0 ] && fn_log_info "yaml 部署 ${filename}资源成功" || fn_log_error "安装 ${filename} yaml资源 失败"
    elif [ "$yaml_install" == 'no' ];then
        # 删除app
        kubectl delete -f ${manifests_dir}/  &>/dev/null
        fn_log_info "yaml 删除 ${filename}资源成功" 
    else
        fn_log_error "$file 变量yaml_install参数值未设置正确" 
    fi
}

main