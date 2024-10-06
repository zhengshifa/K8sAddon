#!/bin/bash
## 部署

#加载公共模块
. ./lib.sh


# 日志管理
fn_log_management() {
    for file in "$base_dir"/vars/*; do
        . $base_dir/vars/$file
        # 简单日志收集：使用kubectl收集日志
        kubectl logs -n ${namespace} --tail=100 > ${base_dir}/logs/${release_name}.log
        fn_log_info "日志已保存到 ${base_dir}/logs/${release_name}.log"
    done
}
