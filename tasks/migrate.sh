#!/bin/bash
## 部署

# 全局变量
base_dir=/etc/k8s-addon

#加载公共模块
. ${base_dir}/tasks/lib.sh


# 迁移
fn_migrate() {
    for file in "$base_dir"/vars/*; do
        . $base_dir/vars/$file
        # 示例：迁移到新的namespace
        new_namespace="${namespace}-migrated"
        kubectl get ns ${new_namespace} || kubectl create ns ${new_namespace}
        helm upgrade ${release_name} --install -n ${new_namespace} -f ${base_dir}/templates/${file}/values.yaml
        fn_log_info "${release_name} 已迁移到 ${new_namespace}"
    done
}
