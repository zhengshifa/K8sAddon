# minio-op for k8s (6.0.2)

## 官方文档
https://min.io/docs/minio/kubernetes/upstream/index.html
https://github.com/minio/operator.git

## 版本矩阵
待补充...

## 部署 MinIO Operator

### 方式一: 插件集成
- 参考[安装插件到指定集群](../guide/cluster-addon.md)

### 方式二: yaml安装:
curl -O https://raw.githubusercontent.com/minio/operator/master/helm-releases/operator-6.0.2.tgz
tar xf operator-6.0.2.tgz
vi operator/values.yaml
helm install \
--namespace minio-operator \
--create-namespace \
minio-operator ./operator
kubectl get all --namespace minio-operator

## 升级 MinIO Operator


## 部署和管理 MinIO 租户

## minio客户端


## 核心运营概念


## 监控和警报


## 外部身份管理


## 数据加密 （SSE）


## 网络加密 （TLS）


## 部署清单


## 硬件故障后恢复


## 故障 排除

