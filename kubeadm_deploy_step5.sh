vi /etc/selinux/config
SELINUX=disabled
reboot

Disable 
sudo swapoff -a 
Enabled 
sudo swapon -a

cat << EOF > /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf
[Service]
ExecStart=
ExecStart=/usr/bin/kubelet --pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true --cgroup-driver=systemd --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice
Restart=always
EOF

vi /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf
--runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice

journalctl -f

rm -rf /var/lib/etcd/*
systemctl daemon-reload
systemctl restart kubelet



kubectl config view
kubectl config set-cluster kubernetes
kubectl config set-context default-context


kubeadm alpha phase certs etcd-server --config=/tmp/192.168.1.9/kubeadmcfg.yaml
kubeadm alpha phase certs etcd-peer --config=/tmp/192.168.1.9/kubeadmcfg.yaml
kubeadm alpha phase certs etcd-healthcheck-client --config=/tmp/192.168.1.9/kubeadmcfg.yaml
kubeadm alpha phase certs apiserver-etcd-client --config=/tmp/192.168.1.9/kubeadmcfg.yaml
#backup, if execute command 'kubeadm reset', copy this tmp file to the /etc/kubernetes/manifests
cp -R /etc/kubernetes/manifests /tmp/192.168.1.9/
cp -R /etc/kubernetes/pki /tmp/192.168.1.9/
# cleanup non-reusable certificates
find /etc/kubernetes/pki -not -name ca.crt -not -name ca.key -type f -delete

kubeadm alpha phase certs etcd-server --config=/tmp/192.168.1.8/kubeadmcfg.yaml
kubeadm alpha phase certs etcd-peer --config=/tmp/192.168.1.8/kubeadmcfg.yaml
kubeadm alpha phase certs etcd-healthcheck-client --config=/tmp/192.168.1.8/kubeadmcfg.yaml
kubeadm alpha phase certs apiserver-etcd-client --config=/tmp/192.168.1.8/kubeadmcfg.yaml
#backup, if execute command 'kubeadm reset', copy this tmp file to the /etc/kubernetes/manifests
cp -R /etc/kubernetes/manifests /tmp/192.168.1.8/
cp -R /etc/kubernetes/pki /tmp/192.168.1.8/
# cleanup non-reusable certificates
find /etc/kubernetes/pki -not -name ca.crt -not -name ca.key -type f -delete

kubeadm alpha phase certs etcd-server --config=/tmp/192.168.1.7/kubeadmcfg.yaml
kubeadm alpha phase certs etcd-peer --config=/tmp/192.168.1.7/kubeadmcfg.yaml
kubeadm alpha phase certs etcd-healthcheck-client --config=/tmp/192.168.1.7/kubeadmcfg.yaml
kubeadm alpha phase certs apiserver-etcd-client --config=/tmp/192.168.1.7/kubeadmcfg.yaml
#backup, if execute command 'kubeadm reset', copy this tmp file to the /etc/kubernetes/manifests
cp -R /etc/kubernetes/manifests /tmp/192.168.1.7/
cp -R /etc/kubernetes/pki /tmp/192.168.1.7/
# cleanup non-reusable certificates
find /etc/kubernetes/pki -not -name ca.crt -not -name ca.key -type f -delete

kubeadm alpha phase certs etcd-server --config=/tmp/192.168.1.6/kubeadmcfg.yaml
kubeadm alpha phase certs etcd-peer --config=/tmp/192.168.1.6/kubeadmcfg.yaml
kubeadm alpha phase certs etcd-healthcheck-client --config=/tmp/192.168.1.6/kubeadmcfg.yaml
kubeadm alpha phase certs apiserver-etcd-client --config=/tmp/192.168.1.6/kubeadmcfg.yaml
#backup, if execute command 'kubeadm reset', copy this tmp file to the /etc/kubernetes/manifests
cp -R /etc/kubernetes/manifests /tmp/192.168.1.6/
cp -R /etc/kubernetes/pki /tmp/192.168.1.6/
#cp -R /tmp/192.168.1.6/pki/* /etc/kubernetes/pki
find /etc/kubernetes/pki -not -name ca.crt -not -name ca.key -type f -delete

kubeadm alpha phase certs etcd-server --config=/tmp/192.168.1.5/kubeadmcfg.yaml
kubeadm alpha phase certs etcd-peer --config=/tmp/192.168.1.5/kubeadmcfg.yaml
kubeadm alpha phase certs etcd-healthcheck-client --config=/tmp/192.168.1.5/kubeadmcfg.yaml
kubeadm alpha phase certs apiserver-etcd-client --config=/tmp/192.168.1.5/kubeadmcfg.yaml
# No need to move the certs because they are for zoo1
#cp -R /tmp/192.168.1.5/pki/* /etc/kubernetes/pki
#backup, if execute command 'kubeadm reset', copy this tmp file to the /etc/kubernetes/manifests
cp -R /etc/kubernetes/manifests /tmp/192.168.1.5/
cp -R /etc/kubernetes/pki /tmp/192.168.1.5/

# clean up certs that should not be copied off this host
#find /tmp/192.168.1.9 -name ca.key -type f -delete
#find /tmp/192.168.1.8 -name ca.key -type f -delete
#find /tmp/192.168.1.7 -name ca.key -type f -delete
#find /tmp/192.168.1.6 -name ca.key -type f -delete

mkdir /home/root

cp -r /tmp/192.168.1.6/* /home/root
cp -r /tmp/192.168.1.7/* /home/root
cp -r /tmp/192.168.1.8/* /home/root
cp -r /tmp/192.168.1.9/* /home/root

root@zoo1 $ kubeadm alpha phase etcd local --config=/tmp/192.168.1.5/kubeadmcfg.yaml
root@zoo2 $ kubeadm alpha phase etcd local --config=/home/root/kubeadmcfg.yaml
root@zoo3 $ kubeadm alpha phase etcd local --config=/home/root/kubeadmcfg.yaml
root@zoo4 $ kubeadm alpha phase etcd local --config=/home/root/kubeadmcfg.yaml
root@zoo5 $ kubeadm alpha phase etcd local --config=/home/root/kubeadmcfg.yaml

chown -R root:root /etc/kubernetes/pki

docker run --rm -it \
--net host \
-v /etc/kubernetes:/etc/kubernetes quay.io/coreos/etcd:v3.2.18 etcdctl \
--cert-file /etc/kubernetes/pki2/etcd.pem \
--key-file /etc/kubernetes/pki2/etcd-key.pem \
--ca-file /etc/kubernetes/pki2/etcd-root-ca.pem \
--endpoints https://192.168.1.5:2379 cluster-health

vi /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
--pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google-containers/pause-amd64:3.1
systemctl enable kubelet && systemctl start kubelet

sysctl net.bridge.bridge-nf-call-iptables=1

systemctl status kubelet


docker tag f9d5de079539 k8s.gcr.io/pause:3.1
docker tag e21fb69683f3 k8s.gcr.io/etcd-amd64:3.2.18
docker tag d85e9095f2b7 k8s.gcr.io/kube-apiserver-amd64:v1.11.1
docker tag bf17b3d2cf82 k8s.gcr.io/kube-controller-manager-amd64:v1.11.1
docker tag fce9ea95c055 k8s.gcr.io/kube-scheduler-amd64:v1.11.1
docker tag 4c3b0086a504 k8s.gcr.io/kube-proxy-amd64:v1.11.1
docker tag fe12b866421e k8s.gcr.io/pause-amd64:3.1
docker tag bd093a842444 k8s.gcr.io/coredns:1.1.3

kubeadm reset

docker run --rm -it \
--net host \
-v /etc/kubernetes:/etc/kubernetes quay.io/coreos/etcd:v3.2.18 etcdctl \
--cert-file /etc/kubernetes/pki2/etcd.pem \
--key-file /etc/kubernetes/pki2/etcd-key.pem \
--ca-file /etc/kubernetes/pki2/etcd-root-ca.pem \
--endpoints https://192.168.1.5:2379 \
mk /coreos.com/network/config '{ "Network": "10.1.0.0/16", "Backend": {"Type": "vxlan"} }'

docker run --rm -it \
--net host \
-v /etc/kubernetes:/etc/kubernetes quay.io/coreos/etcd:v3.2.18 etcdctl \
--cert-file /etc/kubernetes/pki2/etcd.pem \
--key-file /etc/kubernetes/pki2/etcd-key.pem \
--ca-file /etc/kubernetes/pki2/etcd-root-ca.pem \
--endpoints https://192.168.1.5:2379 \
get /coreos.com/network/config


docker run --rm -it \
--net host \
-v /etc/kubernetes:/etc/kubernetes quay.io/coreos/etcd:v3.2.18 etcdctl \
--cert-file /etc/kubernetes/pki2/etcd.pem \
--key-file /etc/kubernetes/pki2/etcd-key.pem \
--ca-file /etc/kubernetes/pki2/etcd-root-ca.pem \
--endpoints https://192.168.1.5:2379 \
ls /coreos.com/network/subnets
