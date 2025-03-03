#!/bin/bash
## 部署

# 全局变量
base_dir=/etc/k8s-addon

#加载公共模块
. ${base_dir}/tasks/lib.sh


# 优化
fn_optimize() {
    for file in "$base_dir"/vars/*; do
        . $base_dir/vars/$file
        # 示例:设置资源限制和HPA
        kubectl autoscale deployment ${release_name} -n ${namespace} --cpu-percent=80 --min=1 --max=5
        fn_log_info "已为 ${release_name} 部署了自动扩缩容"
    done
}