#####  redis-op for k8s

### 官方文档
https://github.com/spotahome/redis-operator

### 版本矩阵
待补充...

### 操作员部署

kubectl create -f  manifests/redis-operator-crd.yaml
原始内容如下：
REDIS_OPERATOR_VERSION=v1.3.0
kubectl create -f https://raw.githubusercontent.com/spotahome/redis-operator/${REDIS_OPERATOR_VERSION}/manifests/databases.spotahome.com_redisfailovers.yaml
kubectl apply -f https://raw.githubusercontent.com/spotahome/redis-operator/${REDIS_OPERATOR_VERSION}/example/operator/all-redis-operator-resources.yaml

### redis集群创建

#基础redis集群创建
kubectl create -f manifests/redisfailover.yaml
原始内容参考：
REDIS_OPERATOR_VERSION=v1.2.4
kubectl create -f https://raw.githubusercontent.com/spotahome/redis-operator/${REDIS_OPERATOR_VERSION}/example/redisfailover/basic.yaml
注：自定义参数请参考 https://github.com/spotahome/redis-operator/tree/master/example/redisfailover

### NodeAffinity 和容忍度
待补充...

### 监控
kubectl create -f manifests/enable-exporter.yaml
https://github.com/spotahome/redis-operator/tree/master/example/grafana-dashboard


### 清理

#清理操作员crd
kubectl delete crd redisfailovers.databases.spotahome.com

#清理redis集群
kubectl delete redisfailover <NAME>