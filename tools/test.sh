#!/bin/bash

# 获取当前工作目录并转换为 Git Bash 兼容的 Unix 路径
current_dir=$(pwd)
unix_path=$(echo $current_dir | sed 's/\\/\//g' | sed 's/://')

# 切换到指定目录
cd "/$unix_path/K8sAddon" || { echo "Directory not found"; exit 1; }

# 输出当前目录，验证切换是否成功
pwd


git pull
git add .
git commit -m "1017"
git push