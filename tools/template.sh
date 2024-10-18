#!/bin/bash

## 渲染 templates 的模板并显示生成的 Kubernetes 资源文件，但不应用到集群。


base_dir='..'

for file in "$base_dir"/vars/*; do
    filename=$(basename "$file")  # 获取变量的文件名
    for values in ${base_dir}/templates/${filename}/*.j2; do
        (
            j2filename=$(basename "$values")
            set -a
            . "${base_dir}/vars/${filename}"  # 加上 base_dir

            if [ ! -d "${base_dir}/manifests/${filename}" ];then
                mkdir ${base_dir}/manifests/${filename}
            fi

            envsubst < "${values}" > "${base_dir}/manifests/${filename}/${j2filename%.*}"  # 修改输出路径

            if [ $? -eq 0 ]; then
                echo "渲染成功,生成文件 ${base_dir}/manifests/${filename}/${j2filename%.*}"
            else
                echo "渲染失败"
            fi
            
            if [ -f ${base_dir}/manifests/${filename}/values.yaml ];then
                helm template  ${base_dir}/files/${filename}-${chart_ver}.tgz  --output-dir  ${base_dir}/manifests
            fi     
sleep 3
        )
    done
done