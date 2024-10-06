#!/bin/bash
## 部署

#加载公共模块
. ./lib.sh


# 备份恢复
fn_restore() {
    for file in "$base_dir"/vars/*; do
        . $base_dir/vars/$file
        # 备份Helm release的当前状态
        helm get values ${release_name} -n ${namespace} > ${backup_dir}/${release_name}_backup.yaml
        fn_log_info "已备份 ${release_name} 的Helm配置"
    done
}
