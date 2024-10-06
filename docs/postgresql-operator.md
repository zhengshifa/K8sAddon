##### postgresql-operator for k8s

### 版本(v2.4.1)

### 官方文档
https://github.com/percona/percona-postgresql-operator
https://docs.percona.com/percona-operator-for-postgresql/2.0/index.html

### 版本矩阵
Operator	PostgreSQL	    pgBackRest	    pgBouncer
2.4.1	    12 - 16	        2.51	        1.22.1
2.4.0	    12 - 16	        2.51	        1.22.1
2.3.1	    12 - 16	        2.48	        1.18.0
2.3.0	    12 - 16	        2.48	        1.18.0

### 部署 Operator
kubectl create namespace postgres-operator
#原始文件: https://raw.githubusercontent.com/percona/percona-postgresql-operator/v2.4.1/deploy/bundle.yaml
kubectl apply --server-side -f manifests/postgresql-operator-crd.yaml -n postgres-operator
kubectl get pod -n postgres-operator

### 部署pg集群
#原始文件: https://raw.githubusercontent.com/percona/percona-postgresql-operator/main/deploy/cr.yaml
kubectl apply -f manifests/cr.yaml -n <namespace>
kubectl get pg -n <namespace>

### 连接到 PostgreSQL
kubectl get secrets -n <namespace>
PGBOUNCER_URI=$(kubectl get secret <secret> --namespace <namespace> -o jsonpath='{.data.pgbouncer-uri}' | base64 --decode)
kubectl run -i --rm --tty pg-client --image=perconalab/percona-distribution-postgresql:16 --restart=Never -- psql $PGBOUNCER_URI

### 将样本数据插入数据库

CREATE SCHEMA demo;
CREATE TABLE LIBRARY(
   ID INTEGER NOT NULL,
   NAME TEXT,
   SHORT_DESCRIPTION TEXT,
   AUTHOR TEXT,
   DESCRIPTION TEXT,
   CONTENT TEXT,
   LAST_UPDATED DATE,
   CREATED DATE
);
INSERT INTO LIBRARY(id, name, short_description, author,
                              description,content, last_updated, created)
SELECT id, 'name', md5(random()::text), 'name2'
      ,md5(random()::text),md5(random()::text)
      ,NOW() - '1 day'::INTERVAL * (RANDOM()::int * 100)
      ,NOW() - '1 day'::INTERVAL * (RANDOM()::int * 100 + 100)
FROM generate_series(1,100) id;

### 设置和进行手动备份(repo1为本地存储pv,以下是minio存储教程)

#配置本地minio存储参数
cat <<EOF | base64 --wrap=0
[global]
repo2-s3-key=<YOUR_AWS_S3_KEY>
repo2-s3-key-secret=<YOUR_AWS_S3_KEY_SECRET>
EOF
注: 返回结果回填到manifests/cluster1-pgbackrest-secrets.yaml文件 <base64-encoded-configuration-contents>参数
kubectl apply -f cluster1-pgbackrest-secrets.yaml -n <namespace>

#配置cr.yaml参数,参考https://docs.percona.com/percona-operator-for-postgresql/2.0/backups-storage.html
kubectl apply -f deploy/cr.yaml -n <namespace>

#按需备份
kubectl apply -f manifests/backup.yaml

#定时备份
#参考cr.yaml pgbackrest.schedules
kubectl apply -f manifests/cr.yaml

### 还原集群
#还原到新的 PostgreSQL 集群
参考cr-clone.yaml文件dataSource.postgresCluster 子部分还原到新集群
kubectl apply -f manifests/cr-clone.yaml  -n <new-ns>

#还原到现有 PostgreSQL 集群
kubectl apply -f manifests/restore.yaml

#指定要还原的备份
kubectl get pg-backup 
kubectl describe pg-backup <BACKUP NAME>
配置manifests/restore.yaml文件options子集 时间节点或者其他标识
kubectl apply -f manifests/restore.yaml

### 加快备份速度
cat <<EOF | base64 --wrap=0
[global]
repo2-s3-key=<YOUR_AWS_S3_KEY>
repo2-s3-key-secret=<YOUR_AWS_S3_KEY_SECRET>
repo2-storage-verify-tls=n
repo2-s3-uri-style=path
archive-async=y
spool-path=/pgdata

[global:archive-get]
process-max=2

[global:archive-push]
process-max=4
EOF
注: 返回结果回填到manifests/cluster1-pgbackrest-secrets.yaml文件 <base64-encoded-configuration-contents>参数
kubectl apply -f cluster1-pgbackrest-secrets.yaml -n <namespace>

### 升级操作员和数据库
参考: https://docs.percona.com/percona-operator-for-postgresql/2.0/update.html


### 动态更改 PostgreSQL 参数
参考cr.yaml文件 patroni.dynamicConfiguration.postgresql.parameters 子配置
kubectl apply -f manifests/cr.yaml


### 暂停/恢复 Percona XtraDB 集群
调整manifests/cr.yaml文件以下参数
spec.pause: true(暂停)
spec.standby : true/false(只读状态)
kubectl apply -f manifests/cr.yaml

### 使用 Percona 监控和管理 （PMM） 监控数据库运行状况

#部署pmm服务端
#拉取图像
docker pull percona/pmm-server:2
#创建卷
docker volume create pmm-data
#运行映像
export DATA_DIR=$HOME/srv
docker run -v $DATA_DIR/srv:/srv -d --restart always --publish 80:80 --publish 443:443 --name pmm-server percona/pmm-server:2
#更改默认用户的密码(admin)
docker exec -t pmm-server change-admin-password <new_password>(> 2.27.0)
docker exec -t pmm-server bash -c 'grafana-cli --homepath /usr/share/grafana --configOverrides cfg:default.paths.data=/srv/grafana admin reset-admin-password newpass'(< 2.27.0>)


#部署pmm客户端
#从pmm服务器获取api密钥
API_KEY=$(curl --insecure -X POST -H "Content-Type: application/json" -d '{"name":"operator", "role": "Admin"}' "https://<login>:<password>@<server_host>/graph/api/auth/keys" | jq .key)
#修改cr.yaml文件的参数
kubectl apply -f manifests/pmm-secrets.yaml -n postgres-operator
#更新cr.yaml文件pmm.enabled: true
kubectl apply -f manifests/cr.yaml -n postgres-operator
kubectl get pods -n postgres-operator
kubectl logs <pod_name> -c pmm-client


### 将 PostgreSQL 组件的 Percona 分发绑定到特定的 Kubernetes 节点
#亲和力和反亲力
https://docs.percona.com/percona-operator-for-postgresql/2.0/constraints.html
#标签和注释
https://docs.percona.com/percona-operator-for-postgresql/2.0/annotations.html

### 删除数据库集群和操作员

#删除数据库集群
kubectl get pg -n <namespace>
kubectl delete pg cluster1 -n <namespace>
kubectl get pg -n <namespace>

#删除操作员
kubectl get deploy -n <namespace>
kubectl delete deploy percona-postgresql-operator -n <namespace>
kubectl get pods -n <namespace>

#删除crd资源
kubectl get crd
kubectl delete crd perconapgbackups.pgv2.percona.com perconapgclusters.pgv2.percona.com perconapgrestores.pgv2.percona.com

### 部署备用集群进行灾难恢复(DR)
https://docs.percona.com/percona-operator-for-postgresql/2.0/standby.html

### 

