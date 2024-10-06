#!/bin/bash
## 部署

#加载公共模块
. ./lib.sh


# 容灾恢复
fn_disaster_recovery() {
    for file in "$base_dir"/vars/*; do
        . $base_dir/vars/$file
        # 从备份文件恢复Helm release
        if [ -f "${backup_dir}/${release_name}_backup.yaml" ]; then
            helm upgrade ${release_name} --install -n ${namespace} -f ${backup_dir}/${release_name}_backup.yaml
            fn_log_info "${release_name} 容灾恢复成功"
        else
            fn_log_error "备份文件不存在，无法执行容灾恢复"
        fi
    done
}