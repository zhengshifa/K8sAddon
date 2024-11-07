#!/bin/bash

## 插件 是否成功部署 或 功能测试 或 服务测试 或  

set -a  #加载到环境变量,下面的命令
#加载公共模块
. tasks/lib.sh

main() {
    fn_Funct_test
}

fn_test() {

    fn_deploy_test
    fn_Funct_test
    fn_service_test

}


fn_deploy_test() {

echo "1"

}


fn_Funct_test() {

    for env_var in $(grep -v '^#' "$base_dir"/vars/global_vars | grep -v '^\s*$'); do
        for file in "$base_dir"/vars/$env_var/*; do
            . $file # 加载变量文件
            shopt -s nocasematch  # 开启不区分大小写
            
            if [ "$helm_install" == 'yes' ] || [ "$yaml_install" == "yes" ] ;then
                filename=$(basename "$file") # 获取变量的文件名
                manifests_dir=${base_dir}/manifests/${env_var}/${filename}
                kubectl apply -f  $manifests_dir/test.yaml &> /dev/null
                # 在后台执行 while 循环
                (
                    count=0
                    while [ $count -lt 2 ]; do
                        kubectl get -f  $manifests_dir/test.yaml --no-headers | awk '{print $1,$2,$3}' | grep -E -i 'Running|Completed'  &> /dev/null
                        if [ $? = 0 ];then
                            fn_log_info " $filename 功能测试通过 "
                            break
                        fi
                        count=$((count + 1))
                        sleep 20  # 每 10 秒检查一次
                    done
                    fn_log_error " $filename 功能测试未通过 "

                ) &

            fi
        done
    done

    # 等待所有后台任务结束
    wait

}


fn_service_test() {
echo "1"

    
}

main