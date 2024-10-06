#####  rabbitmq-op for k8s

### 官方文档
https://github.com/rabbitmq/cluster-operator
https://www.rabbitmq.com/kubernetes/operator/operator-overview

### 版本矩阵
待补充...

### 操作员部署
#原资源清单:https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml
kubectl apply -f manifests/cluster-operator.yaml

### rabbitmq集群部署
#原资源清单:https://raw.githubusercontent.com/rabbitmq/cluster-operator/main/docs/examples/hello-world/rabbitmq.yaml
kubectl apply -f  manifests/rabbitmq-cluster.yaml
watch 'kubectl get all | grep hello-world'
kubectl rabbitmq list(或插件,列出集群列表)
更多示例文件:https://github.com/rabbitmq/cluster-operator/tree/main/docs/examples

#删除测试集群
kubectl delete rabbitmqclusters.rabbitmq.com hello-world

###  查看 RabbitMQ 日志
kubectl logs hello-world-server-0
kubectl rabbitmq tail hello-world

### 访问管理ui
username="$(kubectl get secret hello-world-default-user -o jsonpath='{.data.username}' | base64 --decode)"
echo "username: $username"
password="$(kubectl get secret hello-world-default-user -o jsonpath='{.data.password}' | base64 --decode)"
echo "password: $password"
kubectl port-forward "service/hello-world" 15672
curl -u$username:$password localhost:15672/api/overview

### 将应用链接到集群测试
username="$(kubectl get secret hello-world-default-user -o jsonpath='{.data.username}' | base64 --decode)"
password="$(kubectl get secret hello-world-default-user -o jsonpath='{.data.password}' | base64 --decode)"
service="$(kubectl get service hello-world -o jsonpath='{.spec.clusterIP}')"
kubectl run perf-test --image=pivotalrabbitmq/perf-test -- --uri amqp://$username:$password@$service
或者插件测试链接: kubectl rabbitmq perf-test hello-world

### 配置 Kubernetes 集群访问私有镜像
cat <<'eof' | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: rabbitmq-cluster-operator
  namespace: rabbitmq-system
eof

kubectl -n rabbitmq-system create secret \
docker-registry rabbitmq-cluster-registry-access \
--docker-server=DOCKER-SERVER \
--docker-username=DOCKER-USERNAME \
--docker-password=DOCKER-PASSWORD

kubectl -n rabbitmq-system patch serviceaccount rabbitmq-cluster-operator -p '{"imagePullSecrets": [{"name": "rabbitmq-cluster-registry-access"}]}'

### 监控
#开启插件 (待补充)
kubectl get customresourcedefinitions.apiextensions.k8s.io servicemonitors.monitoring.coreos.com
#监控所有RabbitMQ集群
kubectl apply --filename https://raw.githubusercontent.com/rabbitmq/cluster-operator/main/observability/prometheus/monitors/rabbitmq-servicemonitor.yml
#监控操作员
kubectl apply --filename https://raw.githubusercontent.com/rabbitmq/cluster-operator/main/observability/prometheus/monitors/rabbitmq-cluster-operator-podmonitor.yml

### 升级操作员