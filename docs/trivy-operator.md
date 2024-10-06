#
https://github.com/aquasecurity/trivy-operator
https://aquasecurity.github.io/trivy-operator/latest/


 helm upgrade  trivy-operator --namespace trivy-system      --create-namespace      --version 0.24.0  --values ./values.yaml  trivy-operator-0.24.1.tgz
helm show values  trivy-operator-0.24.1.tgz
 helm pull aqua/trivy-operator     

 helm uninstall trivy-operator -n trivy-system
    kubectl delete crd vulnerabilityreports.aquasecurity.github.io
    kubectl delete crd exposedsecretreports.aquasecurity.github.io
    kubectl delete crd configauditreports.aquasecurity.github.io
    kubectl delete crd clusterconfigauditreports.aquasecurity.github.io
    kubectl delete crd rbacassessmentreports.aquasecurity.github.io
    kubectl delete crd infraassessmentreports.aquasecurity.github.io
    kubectl delete crd clusterrbacassessmentreports.aquasecurity.github.io
    kubectl delete crd clustercompliancereports.aquasecurity.github.io
    kubectl delete crd clusterinfraassessmentreports.aquasecurity.github.io
    kubectl delete crd sbomreports.aquasecurity.github.io
    kubectl delete crd clustersbomreports.aquasecurity.github.io
    kubectl delete crd clustervulnerabilityreports.aquasecurity.github.io