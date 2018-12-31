# k8s_knowledge<br>
k8s_knowledge<br>

Disable<br>
sudo swapoff -a<br>
Enabled<br>
sudo swapon -a<br>

Verify which cgroup driver dockerd is using<br>
docker info |grep -i cgroup<br>

https://kubernetes.io/docs/concepts/cluster-administration/certificates/<br>

k8s ui token <br>
sudo kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}') <br>

cert<br>
https://kubernetes.io/docs/concepts/cluster-administration/certificates/

