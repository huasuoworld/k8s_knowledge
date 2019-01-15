# 	kubernetes cluster setup

if you loss some k8s image , you can download from 

https://hub.docker.com/u/huasuoworld

when you pull image , please take care the tag



## 1. download kubernetes server-binaries

https://kubernetes.io/docs/setup/release/notes/#server-binaries

or 

https://github.com/kubernetes/kubernetes/releases

​	copy kube-apiserver kube-controller-manager kube-scheduler kubectl kubelet kube-proxy  to master node /usr/bin, copy kubectl kubelet kube-proxy to slave node /usr/bin.

​	将 kube-apiserver kube-controller-manager kube-scheduler kubectl kubelet kube-proxy 拷贝到主节点/usr/bin, 将kubectl kubelet kube-proxy 拷贝到从节点 /usr/bin.



## 2. download etcd

​	https://github.com/etcd-io/etcd/releases

​	copy etcd etcdctl to nodes /usr/bin.

​	将etcd etcdctl拷贝到 /usr/bin目录下.



## 3. download flannel

​	https://github.com/coreos/flannel/releases

​	copy flanneld to nodes /usr/bin.

​	将 flanneld 拷贝到/usr/bin.

## 4. cfssl create certificate 

​	

1. Download, unpack and prepare the command line tools as shown below. Note that you may need to adapt the sample commands based on the hardware architecture and cfssl version you are using.

   ```
   curl -L https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -o cfssl
   chmod +x cfssl
   curl -L https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -o cfssljson
   chmod +x cfssljson
   curl -L https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 -o cfssl-certinfo
   chmod +x cfssl-certinfo
   ```

2. Create a directory to hold the artifacts and initialize cfssl:

   ```
   mkdir cert
   cd cert
   ../cfssl print-defaults config > config.json
   ../cfssl print-defaults csr > csr.json
   ```

3. Create a JSON config file for generating the CA file, for example, `ca-config.json`:

   ```
   {
     "signing": {
       "default": {
         "expiry": "8760h"
       },
       "profiles": {
         "kubernetes": {
           "usages": [
             "signing",
             "key encipherment",
             "server auth",
             "client auth"
           ],
           "expiry": "8760h"
         }
       }
     }
   }
   ```

4. Create a JSON config file for CA certificate signing request (CSR), for example, `ca-csr.json`. Be sure the replace the values marked with angle brackets with real values you want to use.

   ```
   {
     "CN": "kubernetes",
     "key": {
       "algo": "rsa",
       "size": 2048
     },
     "names":[{
       "C": "<country>",
       "ST": "<state>",
       "L": "<city>",
       "O": "<organization>",
       "OU": "<organization unit>"
     }]
   }
   ```

5. Generate CA key (`ca-key.pem`) and certificate (`ca.pem`):

   ```
   ../cfssl gencert -initca ca-csr.json | ../cfssljson -bare ca
   ```

6. Create a JSON config file for generating keys and certificates for the API server as shown below. Be sure to replace the values in angle brackets with real values you want to use. The `MASTER_CLUSTER_IP` is the service cluster IP for the API server as described in previous subsection. The sample below also assumes that you are using `cluster.local` as the default DNS domain name.

   ```
   {
     "CN": "kubernetes",
     "hosts": [
       "127.0.0.1",
       "<MASTER_IP>",
       "<MASTER_CLUSTER_IP>",
       "kubernetes",
       "kubernetes.default",
       "kubernetes.default.svc",
       "kubernetes.default.svc.cluster",
       "kubernetes.default.svc.cluster.local"
     ],
     "key": {
       "algo": "rsa",
       "size": 2048
     },
     "names": [{
       "C": "<country>",
       "ST": "<state>",
       "L": "<city>",
       "O": "<organization>",
       "OU": "<organization unit>"
     }]
   }
   ```

7. Generate the key and certificate for the API server, which are by default saved into file `server-key.pem` and `server.pem` respectively:

   ```
   ../cfssl gencert -ca=ca.pem -ca-key=ca-key.pem \
   --config=ca-config.json -profile=kubernetes \
   server-csr.json | ../cfssljson -bare server
   ```

   8.Distributing Self-Signed CA Certificate

   scp * root@xxx:/etc/kubernetes/cert

   ## 3. systemctl etcd.service

   go to /usr/lib/systemd/system

   ```
   [Unit]
   Description=Etcd Server
   After=network.target
   [Service]
   Type=simple
   ExecStart=/usr/bin/etcd --config-file=/etc/kubernetes/etcd.yml
   Restart=on-failure
   [Install]
   WantedBy=multi-user.target
   ```

   ```
   # This is the configuration file for the etcd server.
   
   # Human-readable name for this member.
   name: 'zoo0'
   
   # Path to the data directory.
   data-dir: /data/etcd
   
   # List of comma separated URLs to listen on for peer traffic.
   listen-peer-urls: https://192.168.1.0:2380
   
   # List of comma separated URLs to listen on for client traffic.
   listen-client-urls: https://192.168.1.0:2379
   
   # List of this member's peer URLs to advertise to the rest of the cluster.
   # The URLs needed to be a comma-separated list.
   initial-advertise-peer-urls: https://192.168.1.0:2380
   
   # List of this member's client URLs to advertise to the public.
   # The URLs needed to be a comma-separated list.
   advertise-client-urls: https://192.168.1.0:2379
   
   # Initial cluster configuration for bootstrapping.
   initial-cluster: zoo0=https://192.168.1.0:2380,zoo1=https://192.168.1.1:2380,zoo2=https://192.168.1.2:2380,zoo3=https://192.168.1.3:2380
   
   # Initial cluster token for the etcd cluster during bootstrap.
   initial-cluster-token: 'etcd-cluster'
   
   # Initial cluster state ('new' or 'existing').
   initial-cluster-state: 'new'
   
   # Accept etcd V2 client requests
   enable-v2: true
   
   client-transport-security:
     # Path to the client server TLS cert file.
     cert-file: /etc/kubernetes/cert/server.pem
   
     # Path to the client server TLS key file.
     key-file: /etc/kubernetes/cert/server-key.pem
   
     # Enable client cert authentication.
     client-cert-auth: false
   
     # Path to the client server TLS trusted CA cert file.
     trusted-ca-file: /etc/kubernetes/cert/ca.pem
   
     # Client TLS using generated certificates
     auto-tls: false
   
   peer-transport-security:
     # Path to the peer server TLS cert file.
     cert-file: /etc/kubernetes/cert/server.pem
   
     # Path to the peer server TLS key file.
     key-file: /etc/kubernetes/cert/server-key.pem
   
     # Enable peer client cert authentication.
     client-cert-auth: false
   
     # Path to the peer server TLS trusted CA cert file.
     trusted-ca-file: /etc/kubernetes/cert/ca.pem
   
     # Peer TLS using generated certificates.
     auto-tls: false
   
   # Enable debug-level logging for etcd.
   debug: false
   
   logger: zap
   
   # Specify 'stdout' or 'stderr' to skip journald logging even when running under systemd.
   log-outputs: [stderr]
   
   # Force to create a new one member cluster.
   force-new-cluster: false
   
   auto-compaction-mode: periodic
   auto-compaction-retention: "1"
   ```

   subnet enviroment setup
   ```
   etcdctl \
   --cert-file /etc/kubernetes/cert/etcd.pem \
   --key-file /etc/kubernetes/cert/etcd-key.pem \
   --ca-file /etc/kubernetes/cert/etcd-root-ca.pem \
   --endpoints https://192.168.1.0:2379 mk /coreos.com/network/config '{ "Network": "10.1.0.0/16", "Backend": {"Type": "vxlan"} }'
   ```


## 4. systemctl flannel.service

​
   ```
[Unit]
Description=flannel Server
Documentation=https://github.com/coreos/flannel
After=network.target etcd.service
Before=docker.service
[Service]
Type=simple
ExecStart=/usr/bin/flanneld -etcd-cafile=/etc/kubernetes/cert/ca.pem \
-etcd-certfile=/etc/kubernetes/cert/server.pem \
-etcd-endpoints=https://192.168.1.0:2379,https://192.168.1.1:2379,https://192.168.1.2:2379,https://192.168.1.3:2379 \
-etcd-keyfile=/etc/kubernetes/cert/server-key.pem \
-ip-masq=true -iface=192.168.1.0 -kube-api-url=https://192.168.1.0:6443 -kubeconfig-file=/etc/kubernetes/bootstrap.kubeconfig
Restart=on-failure
[Install]
WantedBy=multi-user.target

   ```


## 5. kubernetes cluster config

/root/.kube/config
   ```
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /etc/kubernetes/cert/ca.pem
    server: https://192.168.1.0:6443
  name: local
contexts:
- context:
    cluster: local
    user: kubelet
  name: kubelet-context
current-context: kubelet-context
kind: Config
preferences: {}
users:
- name: kubelet
  user:
    client-certificate: /etc/kubernetes/cert/server.pem 
    client-key: /etc/kubernetes/cert/server-key.pem
   ```
kubectl config use-context kubelet-context

## 6. systemctl docker.service
	add parameter "--bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU}"

   ```
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service flanneld.service
Wants=network-online.target

[Service]
EnvironmentFile=-/run/flannel/subnet.env
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU}
ExecReload=/bin/kill -s HUP $MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target

   
   ```

## 7. systemctl kube-apiserver.service

```
# more /usr/lib/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=etcd.service docker.service
Wants=etcd.service docker.service
Requires=etcd.service
[Service]
ExecStart=/usr/bin/kube-apiserver --storage-backend=etcd3 \
--etcd-servers=https://192.168.1.0:2379,https://192.168.1.1:2379,https://192.168.1.2:2379,https://192.168.1.3:2379 \
--etcd-cafile=/etc/kubernetes/cert/ca.pem \
--etcd-certfile=/etc/kubernetes/cert/server.pem \
--etcd-keyfile=/etc/kubernetes/cert/server-key.pem \
--tls-cert-file=/etc/kubernetes/cert/server.pem \
--tls-private-key-file=/etc/kubernetes/cert/server-key.pem \
--client-ca-file=/etc/kubernetes/cert/ca.pem \
--service-account-key-file=/etc/kubernetes/cert/server-key.pem \
--insecure-bind-address=0.0.0.0  --insecure-port=8080 \
--service-cluster-ip-range=10.2.0.0/24 --service-node-port-range=3-65535 \
--admission-control=NamespaceLifecycle,SecurityContextDeny,ServiceAccount,DefaultStorageClass,ResourceQuota \
#--admission-control= \
--logtostderr=true --log-dir=/var/log/kubernetes --v=2
Restart=on-failure
Type=notify
[Install]
WantedBy=multi-user.target
```

## 8. systemctl kube-scheduler.service

```
# more /usr/lib/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=kube-apiserver.service
Requires=kube-apiserver.service

[Service]
ExecStart=/usr/bin/kube-scheduler --master=http://192.168.1.0:8080 \
--logtostderr=true --log-dir=/var/log/kubernetes --v=2
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target

```


## 9. systemctl kube-controller-manager.service

```
# more /usr/lib/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=kube-apiserver.service
Requires=kube-apiserver.service

[Service]
ExecStart=/usr/bin/kube-controller-manager \
--tls-cert-file=/etc/kubernetes/cert/server.pem \
--tls-private-key-file=/etc/kubernetes/cert/server-key.pem \
--root-ca-file=/etc/kubernetes/cert/ca.pem \
--service-account-private-key-file=/etc/kubernetes/cert/server-key.pem \
--master=http://192.168.1.0:8080 \
--logtostderr=true --log-dir=/var/log/kubernetes --v=2
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target

```
## 10.systemctl kubelet.service

zoo0
```
[Unit]
Description=Kubernetes Kubelet Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/kubelet --address=0.0.0.0 --port=10250 --hostname-override=192.168.1.0 \
--allow-privileged=false --kubeconfig=/etc/kubernetes/bootstrap.kubeconfig \
--cluster-dns=10.2.0.2 --cluster-domain=cluster.local --fail-swap-on=false \
--logtostderr=true --log-dir=/var/log/kubernetes --v=4 --cgroup-driver=cgroupfs
Restart=on-failure
KillMode=process

[Install]
WantedBy=multi-user.target

```

zoo1
```
[Unit]
Description=Kubernetes Kubelet Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/kubelet --address=0.0.0.0 --port=10250 --hostname-override=192.168.1.1 \
--allow-privileged=false --kubeconfig=/etc/kubernetes/bootstrap.kubeconfig \
--cluster-dns=10.2.0.2 --cluster-domain=cluster.local --fail-swap-on=false \
--logtostderr=true --log-dir=/var/log/kubernetes --v=4 --cgroup-driver=cgroupfs
Restart=on-failure
KillMode=process

[Install]
WantedBy=multi-user.target

```

zoo2
```
[Unit]
Description=Kubernetes Kubelet Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/kubelet --address=0.0.0.0 --port=10250 --hostname-override=192.168.1.2 \
--allow-privileged=false --kubeconfig=/etc/kubernetes/bootstrap.kubeconfig \
--cluster-dns=10.2.0.2 --cluster-domain=cluster.local --fail-swap-on=false \
--logtostderr=true --log-dir=/var/log/kubernetes --v=4 --cgroup-driver=cgroupfs
Restart=on-failure
KillMode=process

[Install]
WantedBy=multi-user.target

```

zoo3
```
[Unit]
Description=Kubernetes Kubelet Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/kubelet --address=0.0.0.0 --port=10250 --hostname-override=192.168.1.3 \
--allow-privileged=false --kubeconfig=/etc/kubernetes/bootstrap.kubeconfig \
--cluster-dns=10.2.0.2 --cluster-domain=cluster.local --fail-swap-on=false \
--logtostderr=true --log-dir=/var/log/kubernetes --v=4 --cgroup-driver=cgroupfs
Restart=on-failure
KillMode=process

[Install]
WantedBy=multi-user.target

```

## 11.systemctl Kube-proxy.service

zoo0
```
[Unit]
Description=Kubernetes Kube-proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=kubelet.service
Requires=kubelet.service

[Service]
ExecStart=/usr/bin/kube-proxy \
--bind-address=0.0.0.0 --hostname-override=192.168.1.0 \
--logtostderr=true --log-dir=/var/log/kubernetes --v=4 \
--kubeconfig=/etc/kubernetes/bootstrap.kubeconfig
Restart=on-failure
LimitNOFILE=65536
KillMode=process

[Install]
WantedBy=multi-user.target
```
zoo1
```
[Unit]
Description=Kubernetes Kube-proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=kubelet.service
Requires=kubelet.service

[Service]
ExecStart=/usr/bin/kube-proxy \
--bind-address=0.0.0.0 --hostname-override=192.168.1.1 \
--logtostderr=true --log-dir=/var/log/kubernetes --v=4 \
--kubeconfig=/etc/kubernetes/bootstrap.kubeconfig
Restart=on-failure
LimitNOFILE=65536
KillMode=process

[Install]
WantedBy=multi-user.target
```
zoo2
```
[Unit]
Description=Kubernetes Kube-proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=kubelet.service
Requires=kubelet.service

[Service]
ExecStart=/usr/bin/kube-proxy \
--bind-address=0.0.0.0 --hostname-override=192.168.1.2 \
--logtostderr=true --log-dir=/var/log/kubernetes --v=4 \
--kubeconfig=/etc/kubernetes/bootstrap.kubeconfig
Restart=on-failure
LimitNOFILE=65536
KillMode=process

[Install]
WantedBy=multi-user.target
```
zoo3
```
[Unit]
Description=Kubernetes Kube-proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=kubelet.service
Requires=kubelet.service

[Service]
ExecStart=/usr/bin/kube-proxy \
--bind-address=0.0.0.0 --hostname-override=192.168.1.3 \
--logtostderr=true --log-dir=/var/log/kubernetes --v=4 \
--kubeconfig=/etc/kubernetes/bootstrap.kubeconfig
Restart=on-failure
LimitNOFILE=65536
KillMode=process

[Install]
WantedBy=multi-user.target
```
## 12. start service

1. start etcd.service
2. start flannel.service
3. check etcd cluster health 

```
etcdctl \
--cert-file /etc/kubernetes/cert/etcd.pem \
--key-file /etc/kubernetes/cert/etcd-key.pem \
--ca-file /etc/kubernetes/cert/etcd-root-ca.pem \
--endpoints https://192.168.1.0:2379 cluster-health
```
4. start kube-apiserver.service

5. start kube-controller-manager.service

6. start kube-scheduler.service

7. start kubelet.service

8. start kube-proxy.service

9. check k8s cluster health

   kubectl get nodes

   kubectl get svc

   

## 13. deploy kubernetes-dashboard

```
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml
```

## 14. deploy core-dns

```
#CHINE_GENERATED_WARNING__
apiVersion: v1
kind: ServiceAccount
metadata:
  name: coredns
  namespace: kube-system
  labels:
      kubernetes.io/cluster-service: "true"
      addonmanager.kubernetes.io/mode: Reconcile
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
    addonmanager.kubernetes.io/mode: Reconcile
  name: system:coredns
rules:
- apiGroups:
  - ""
  resources:
  - endpoints
  - services
  - pods
  - namespaces
  verbs:
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - nodes
  verbs:
  - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
    addonmanager.kubernetes.io/mode: EnsureExists
  name: system:coredns
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:coredns
subjects:
- kind: ServiceAccount
  name: coredns
  namespace: kube-system
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
  labels:
      addonmanager.kubernetes.io/mode: EnsureExists
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes default.svc.default.svc.cluster.local cluster.local in-addr.arpa ip6.arpa {
            pods insecure
            upstream
            fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        proxy . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coredns
  namespace: kube-system
  labels:
    k8s-app: coredns
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
    kubernetes.io/name: "CoreDNS"
spec:
  # replicas: not specified here:
  # 1. In order to make Addon Manager do not reconcile this replicas parameter.
  # 2. Default is 1.
  # 3. Will be tuned in real time if DNS horizontal auto-scaling is turned on.
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  selector:
    matchLabels:
      k8s-app: coredns
  template:
    metadata:
      labels:
        k8s-app: coredns
      annotations:
        seccomp.security.alpha.kubernetes.io/pod: 'docker/default'
    spec:
      serviceAccountName: coredns
      tolerations:
        - key: "CriticalAddonsOnly"
          operator: "Exists"
      containers:
      - name: coredns
        image: coredns/coredns:1.2.6
        imagePullPolicy: IfNotPresent
        resources:
          limits:
            memory: 170Mi
          requests:
            cpu: 100m
            memory: 70Mi
        args: [ "-conf", "/etc/coredns/Corefile" ]
        volumeMounts:
        - name: config-volume
          mountPath: /etc/coredns
          readOnly: true
        ports:
        - containerPort: 53
          name: dns
          protocol: UDP
        - containerPort: 53
          name: dns-tcp
          protocol: TCP
        - containerPort: 9153
          name: metrics
          protocol: TCP
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 60
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 5
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            add:
            - NET_BIND_SERVICE
            drop:
            - all
          readOnlyRootFilesystem: true
      dnsPolicy: Default
      volumes:
        - name: config-volume
          configMap:
            name: coredns
            items:
            - key: Corefile
              path: Corefile
---
apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  annotations:
    prometheus.io/port: "9153"
    prometheus.io/scrape: "true"
  labels:
    k8s-app: coredns
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
    kubernetes.io/name: "CoreDNS"
spec:
  selector:
    k8s-app: coredns
  clusterIP: 10.2.0.2
  ports:
  - name: dns
    port: 53
    protocol: UDP
  - name: dns-tcp
    port: 53
    protocol: TCP
```


## 15. check dns


```
[root@localhost kubernetes]# kubectl exec busybox1 nslookup kubernetes
Server:    10.2.0.2
Address 1: 10.2.0.2 kube-dns.kube-system.svc.default.svc.default.svc.cluster.local

Name:      kubernetes
Address 1: 10.1.0.1 kubernetes.default.svc.default.svc.default.svc.cluster.local

```

