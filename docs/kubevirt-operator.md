# kubevirt-operator


kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/v1.3.0/kubevirt-operator.yaml
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/v1.3.0/kubevirt-cr.yaml

kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.phase}"
kubectl get all -n kubevirt
kubectl logs pod/kubevirt-install-manager -n kube-system


VERSION=$(kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.observedKubeVirtVersion}")
ARCH=$(uname -s | tr A-Z a-z)-$(uname -m | sed 's/x86_64/amd64/') || windows-amd64.exe
echo ${ARCH}
curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/virtctl-${VERSION}-${ARCH}
chmod +x virtctl
sudo install virtctl /usr/local/bin
或者
kubectl krew install virt



#创建虚拟机
wget https://kubevirt.io/labs/manifests/vm.yaml
less vm.yaml
kubectl apply -f https://kubevirt.io/labs/manifests/vm.yaml

#管理虚拟机
kubectl get vms
kubectl get vms -o yaml testvm
# Start the virtual machine:
kubectl virt start testvm

# Stop the virtual machine:
kubectl virt stop testvm

kubectl get vmis
kubectl get vmis -o yaml testvm

#访问虚拟机控制台
virtctl console testvm

virtctl stop testvm
kubectl delete vm testvm