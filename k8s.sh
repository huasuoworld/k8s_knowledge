# Update HOST0, HOST1, and HOST2 with the IPs or resolvable names of your hosts
export zoo1=192.168.1.5
export zoo2=192.168.1.6
export zoo3=192.168.1.7
export zoo4=192.168.1.8
export zoo5=192.168.1.9

# Create temp directories to store files that will end up on other hosts.
mkdir -p /tmp/${zoo1}/ /tmp/${zoo2}/ /tmp/${zoo3}/ /tmp/${zoo4}/ /tmp/${zoo5}/

ETCDHOSTS=(${zoo1} ${zoo2} ${zoo3} ${zoo4} ${zoo5})
NAMES=("infra1" "infra2" "infra3" "infra4" "infra5")

for i in "${!ETCDHOSTS[@]}"; do
HOST=${ETCDHOSTS[$i]}
NAME=${NAMES[$i]}
cat << EOF > /tmp/${HOST}/kubeadmcfg.yaml
apiVersion: "kubeadm.k8s.io/v1alpha2"
kind: MasterConfiguration
etcd:
    localEtcd:
        serverCertSANs:
        - "${HOST}"
        peerCertSANs:
        - "${HOST}"
        extraArgs:
            initial-cluster: infra1=https://${ETCDHOSTS[0]}:2380,infra2=https://${ETCDHOSTS[1]}:2380,infra3=https://${ETCDHOSTS[2]}:2380,infra4=https://${ETCDHOSTS[3]}:2380,infra5=https://${ETCDHOSTS[4]}:2380
            initial-cluster-state: new
            name: ${NAME}
            listen-peer-urls: https://${HOST}:2380
            listen-client-urls: https://${HOST}:2379
            advertise-client-urls: https://${HOST}:2379
            initial-advertise-peer-urls: https://${HOST}:2380
EOF
done
