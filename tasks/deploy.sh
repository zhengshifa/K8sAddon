#!/bin/bash
## 部署

#加载公共模块
. ./lib.sh

# 部署/删除/升级/回滚/版本控制
fn_helm_deploy() {

    for file in "$base_dir"/vars/*; do
        [ -e "$file" ] || fn_log_error "$file 配置文件不存在"  # 检查文件是否存在
        (
            filename=$(basename "$file")
            . $file # 加载配置变量文件
            fn_j2_to_files  # 模板文件渲染
            shopt -s nocasematch  # 开启不区分大小写

            if [ "$install" == 'yes' ];then
                # helm部署app
                helm upgrade ${release_name} --install --create-namespace \
                -n ${namespace} -f ${base_dir}/templates/${filename}/values.yaml \
                ${base_dir}/files/${filename}-${chart_ver}.tgz
                fn_log_info "helm安装 ${release_name} 成功"
            elif [  "$install" == 'no' ];then
                # 删除app
                helm uninstall ${release_name} -n ${namespace}
                fn_log_info "helm删除 ${release_name} 成功"
            else
                fn_log_error "$file 变量install参数值未设置正确"
            fi
        )
    done

}