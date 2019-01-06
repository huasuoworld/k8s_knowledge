

kubectl create clusterrolebinding root-cluster-admin-binding --clusterrole=cluster-admin --user=root<br><br>
<br><br>
kubectl create clusterrolebinding kubelet-node-binding --clusterrole=system:node --user=kubelet<br>
<br>
<br>
kubectl create clusterrolebinding myapp-view-binding --clusterrole=view --serviceaccount=acme:myapp-view-binding<br>
<br>
helm init --client-only --stable-repo-url https://aliacs-app-catalog.oss-cn-hangzhou.aliyuncs.com/charts/<br>
helm repo add incubator https://aliacs-app-catalog.oss-cn-hangzhou.aliyuncs.com/charts-incubator/<br>
helm repo update<br>
<br>
# 创建服务端<br>
helm init --service-account tiller --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.12.1  --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts<br>
 <br>
# 创建TLS认证服务端，参考地址：https://github.com/gjmzj/kubeasz/blob/master/docs/guide/helm.md<br>
helm init --service-account tiller --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.12.1 --tiller-tls-cert /etc/kubernetes/cert/server.pem --tiller-tls-key /etc/kubernetes/cert/server-key.pem --tls-ca-cert /etc/kubernetes/cert/ca.pem --tiller-namespace kube-system --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts<br>
<br>
kubectl create serviceaccount --namespace kube-system tiller<br>
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller<br>
<br>
<br>
# 使用 kubectl patch 更新 API 对象<br>
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'<br>
deployment.extensions "tiller-deploy" patched <br>
