#!/bin/bash
## 部署

# 全局变量
base_dir=/etc/k8s-addon

#加载公共模块
. ${base_dir}/tasks/lib.sh


# 配置管理
fn_config_management() {
    for file in "$base_dir"/vars/*; do
        . $base_dir/vars/$file
        # 比较和更新Kubernetes配置
        kubectl diff -f ${base_dir}/templates/${file}/values.yaml
        if [ $? -eq 0 ]; then
            fn_log_info "配置文件无变化"
        else
            fn_log_warn "检测到配置文件变化,应用更新"
            kubectl apply -f ${base_dir}/templates/${file}/values.yaml
        fi
    done
}