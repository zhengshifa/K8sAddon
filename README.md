# K8sAddon - Kubernetes Operator 管理平台

## 项目概述
K8sAddon 是一个用于管理 Kubernetes Operator 的平台，提供以下功能：
- 多种常用 Operator 的一键部署
- 统一的配置管理
- 标准化的运维操作流程
- 自动化监控和告警
- 完善的备份恢复机制

## 目录结构
```
K8sAddon/
├── docs/          # 各Operator的详细文档
├── files/         # Helm chart包
├── guide/         # 操作指南
├── manifests/     # Kubernetes manifest文件
├── tasks/         # 运维脚本
├── templates/     # Helm模板
├── tools/         # 实用工具
└── vars/          # 环境变量配置
```

## 快速开始

### 1. 安装准备
- 确保已安装 kubectl 和 helm
- 配置 kubeconfig 文件

### 2. 安装Operator
1. 编辑 vars/global_vars 文件，设置目标集群信息
2. 设置 install="yes"
3. 执行部署脚本：
```bash
./tasks/deploy.sh
```

## 运维操作指南

### 部署/删除
- 部署：`./tasks/deploy.sh`
- 删除：`./tasks/deploy.sh uninstall`

### 升级/回滚  
- 升级：`./tasks/deploy.sh upgrade`
- 回滚：`./tasks/deploy.sh rollback`

### 监控告警
- 查看监控：`kubectl get prometheusrules -n monitoring`
- 配置告警：编辑 templates/kube-prometheus-stack/alerts.yaml

### 备份恢复
- 备份：`./tasks/backup.sh`
- 恢复：`./tasks/restore.sh`

## 参考文档
- [OpenKruise 原地升级](https://openkruise.io/zh/docs/)
- [RBAC Manager](https://rbac-manager.docs.fairwinds.com/)
- [Cert Manager](https://cert-manager.io/)
- [Kured](https://github.com/kubereboot/kured)
- [Kubeview](https://github.com/benc-uk/kubeview)
