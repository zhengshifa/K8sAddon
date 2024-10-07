#  mysql-op for k8s

## 版本(v1.14.0)

## 官方文档
https://docs.percona.com/percona-operator-for-mysql/pxc/index.html
https://github.com/percona/percona-xtradb-cluster-operator.git

## 版本矩阵
Operator	MySQL	    Percona XtraBackup	        HA	        proxySQL
1.14.0	    8.0, 5.7	8.0.35-30.1，2.4.29-1	    2.8.5-1	    2.5.5-1.1
1.13.0	    8.0, 5.7	8.0.32-26， 2.4.28	        2.6.12	    2.5.1-1.1
1.12.0	    8.0, 5.7	8.0.30-23， 2.4.26	        2.5.6	    2.4.4
1.11.0	    8.0, 5.7	8.0.27-19， 2.4.26	        2.4.15	    2.3.2

## 部署Operator和db集群(更换合适本地镜像)

### 方式一
#部署操作员
`kubectl create -n mysql-op`
`kubectl apply -f ../manifests/mysql-operator/manifests/mysql-operator-crd.yml -n mysql-op`
#部署 Percona XtraDB 集群
`kubectl apply -f ../manifests/mysql-operator/manifests/cr.yaml -n <namespace>`
注:原yaml请查看 https://raw.githubusercontent.com/percona/percona-xtradb-cluster-operator/v1.14.0/deploy/cr.yaml
注:更多集群自定义参数请查看 https://docs.percona.com/percona-operator-for-mysql/pxc/operator.html

#检查 Operator 和 Percona XtraDB 集群 Pod 状态
`kubectl get pxc -n <namespace>`

### 方式二
- 参考[安装插件到指定集群](../k8s-addon.md)


## 连接到 Percona XtraDB 集群中的 MySQL 实例

#列出 Secrets 对象
`kubectl get secrets -n <namespace>`
#检索 root 用户的密码
`kubectl get secret <secret-name> -n <namespace> --template='{{.data.root | base64decode}}{{"\n"}}'`
#连接到您的终端
kubectl run -n <namespace> -i --rm --tty percona-client --image=percona:8.0 --restart=Never -- bash -il
$ mysql -h <cluster_name>-haproxy -uroot -p'<root_password>'   (haproxy)
$ mysql -h <cluster_name>-proxysql -uroot -p'<root_password>'  (proxysql)

## 将样本数据插入数据库

#执行增删改查测试
CREATE DATABASE mydb;
use mydb;
CREATE TABLE extraordinary_gentlemen (
    id int NOT NULL AUTO_INCREMENT,
    name varchar(255) NOT NULL,
    occupation varchar(255),
    PRIMARY KEY (id)
);
INSERT INTO extraordinary_gentlemen (name, occupation)
  VALUES
  ("Allan Quartermain","hunter"),
  ("Nemo","fish"),
  ("Dorian Gray", NULL),
  ("Tom Sawyer", "secret service agent");
SELECT * FROM extraordinary_gentlemen;
UPDATE  extraordinary_gentlemen SET occupation = "submariner" WHERE name = "Nemo";
SELECT * FROM extraordinary_gentlemen;

## 全量逻辑备份

#配置本地minio存储参数
echo -n 'AWS_ACCESS_KEY_ID' | base64 --wrap=0
echo -n 'AWS_SECRET_ACCESS_KEY' | base64 --wrap=0
kubectl apply -f ../manifests/mysql-operator/manifests/backup-secret-s3.yaml -n <namespace>

#配置好cr.yaml的关联参数,重新apply
kubectl apply -f ../manifests/mysql-operator/manifests/cr.yaml -n <namespace>
注:cr.yaml文件配置s3/本地存储信息

#手动逻辑备份
kubectl apply -f backup.yaml -n <namespace>
注:backup.yaml文件中的storageName参数可以选择s3/本地存储备份

#定时备份
kubectl apply -f ../manifests/mysql-operator/manifests/backup.yaml -n <namespace>
注:修改cr.yaml文件的schedule字段,选择相应的存储介质和备份时间

#获取备份进度
kubectl get pxc-backup -n <namespace>

#备份故障排查
kubectl get pxc-backup <backup-name> -n <namespace> -o yaml
kubectl logs pod/<pod-name> -c xtrabackup -n <namespace>

## 增量备份(二进制备份)

#配置cr.yaml文件开启增量备份
backup.pitr.enabled 键应设置为true
backup.pitr.storageName 键应指向已存在的存储名称

## 还原到新的k8s集群

#获取备份
`kubectl get pxc-backup`

#获取mysql集群
`kubectl get pxc`

#执行还原(修改相应参数后执行)
`kubectl apply -f ../manifests/mysql-operator/manifests/restore.yaml`

## 二进制日志还原到指定时间节点

#获取二进制备份可恢复的时间节点
kubectl get pxc-backup
kubectl get pxc-backup <backup_name> -o jsonpath='{.status.latestRestorableTime}'

#启用文件restore.yaml中的pitr部分,并执行
kubectl apply -f ../manifests/mysql-operator/manifests/restore.yaml

## 将备份复制到本地计算机

#复制备份到本地
kubectl get pxc-backup
../manifests/mysql-operator/copy-backup.sh <backup-name> path/to/dir

#备份可以恢复到本地 Percona服务器
service mysqld stop
rm -rf /var/lib/mysql/*
cat xtrabackup.stream | xbstream -x -C /var/lib/mysql
xtrabackup --prepare --target-dir=/var/lib/mysql
chown -R mysql:mysql /var/lib/mysql
service mysqld start

## 删除不需要的备份

#手动删除不需要的备份
kubectl get pxc-backup
kubectl delete pxc-backup/<backup-name>

## 升级数据库和操作员
https://docs.percona.com/percona-operator-for-mysql/pxc/update.html


## 崩溃恢复

#全集群崩溃
全集群崩溃是指所有数据库实例都 以随机顺序关闭。在这种情况下重新启动后，Pod 是 不断重新启动，并在日志中生成以下错误:
It may not be safe to bootstrap the cluster from this node. It was not the last one to leave the cluster and may not contain all the updates.
To force cluster bootstrap with this node, edit the grastate.dat file manually and set safe_to_bootstrap to 1


#自动崩溃恢复
开启参数 : pxc.autoRecovery
如果没有开启上面的自动恢复,可以进行半自动恢复
在这种情况下，您需要从所有 Pod 的 pxc 容器中获取日志 使用以下命令：
for i in $(seq 0 $(($(kubectl get pxc cluster1 -o jsonpath='{.spec.pxc.size}')-1))); do echo "###############cluster1-pxc-$i##############"; kubectl logs cluster1-pxc-$i -c pxc | grep '(seqno):' ; done
找到最大的 Pod 执行
kubectl exec cluster1-pxc-2 -c pxc -- sh -c 'kill -s USR1 1'

#手动崩溃恢复

## 暂停/恢复 Percona XtraDB 集群

将其设置为正常停止集群：cr.yaml  spec.pause true/false
kubectl apply -f ../manifests/mysql-operator/manifests/cr.yaml -n <namespace>
kubectl get pods -n <namespace>

## 使用 Percona 监控和管理 （PMM） 监控数据库运行状况

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
#生成监控数据库账号密码
kubectl apply -f ../manifests/mysql-operator/manifests/secrets.yaml -n <namespace>
#修改cr.yaml文件的参数
pmm.enabled true
pmm.serverHost <host>
kubectl apply -f ../manifests/mysql-operator/manifests/cr.yaml -n <namespace>

## 删除数据库集群和操作员

#删除数据库集群
kubectl get pxc -n <namespace>
kubectl delete pxc <cluster_name> -n <namespace>
kubectl get pxc -n <namespace>

#删除运算符
kubectl get deploy -n <namespace>
kubectl delete deploy percona-xtradb-cluster-operator -n <namespace>
kubectl get pods -n <namespace>

#删除crd资源
kubectl get crd
kubectl delete crd perconaxtradbclusterbackups.pxc.percona.com perconaxtradbclusterrestores.pxc.percona.com perconaxtradbclusters.pxc.percona.com

#TLS 相关的对象和数据卷
kubectl get pvc -n <namespace>
kubectl delete pvc datadir-cluster1-pxc-0 datadir-cluster1-pxc-1 datadir-cluster1-pxc-2 -n <namespace>
kubectl get secrets -n <namespace>
kubectl delete secret <secret_name> -n <namespace>

## 数据库集群绑定到特定节点策略
#节点选择器/亲和力/反亲和力/容忍度/pod中断预算
#https://docs.percona.com/percona-operator-for-mysql/pxc/constraints.html