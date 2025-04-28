# Sample commands for reference

1. Create cluster smapel command:
```
curl -sfL https://get.k3s.io | sh -s - server --cluster-init --token Iam234afucking6534idiot \
  --tls-san 10.10.1.110 --node-ip 10.10.1.145 \
  --disable traefik --disable servicelb \
  --flannel-iface=enp0s8 \
  --node-taint node-role.kubernetes.io/master=true:NoSchedule \
  --no-deploy servicelb --no-deploy traefik \
  --kube-controller-manager-arg bind-address=0.0.0.0 \
  --kube-proxy-arg metrics-bind-address=0.0.0.0 \
  --kube-scheduler-arg bind-address=0.0.0.0 \
  --etcd-expose-metrics true \
  --kubelet-arg containerd=/run/k3s/containerd/containerd.sock
```

1. Join a master in to the cluster smapel command:
```
curl -sfL https://get.k3s.io | sh -s - server --token Iam234afucking6534idiot \
  --server https://10.10.1.145:6443 \
  --tls-san 10.10.1.110 --node-ip 10.10.1.155 \
  --disable traefik --disable servicelb \
  --flannel-iface=enp0s8 \
  --node-taint node-role.kubernetes.io/master=true:NoSchedule \
  --no-deploy servicelb --no-deploy traefik \
  --kube-controller-manager-arg bind-address=0.0.0.0 \
  --kube-proxy-arg metrics-bind-address=0.0.0.0 \
  --kube-scheduler-arg bind-address=0.0.0.0 \
  --etcd-expose-metrics true \
  --kubelet-arg containerd=/run/k3s/containerd/containerd.sock
```
1. Join an worker node in to the cluster:
```
curl -sfL https://get.k3s.io | sh -s - agent --token Iam234afucking6534idiot \
  --server https://10.10.1.145:6443 \
  --node-ip 10.10.1.126 \
  --flannel-iface=enp0s8 \
  --node-label longhorn=true \
  --node-label worker=true \
  --kube-proxy-arg metrics-bind-address=0.0.0.0 \
  --kubelet-arg containerd=/run/k3s/containerd/containerd.sock
```

1. Join a etcd in to the cluster:

```
curl -fL https://get.k3s.io | sh -s - server --token Iam234afucking6534idiot \
 --disable-apiserver --disable-controller-manager --disable-scheduler \
 --server https://10.10.1.145:6443 \
 --node-ip 10.10.1.125 --write-kubeconfig-mode 664
```

1. k3sup commands:
```
 k3sup install \
  --ip 10.10.1.145 \
  --user vagrant \
  --tls-san 10.10.1.110 \
  --cluster \
  --k3s-version v1.32.3+k3s1 \
  --k3s-extra-args "--disable traefik --disable servicelb --flannel-iface=enp0s8 --node-ip=10.10.1.145 --node-taint node-role.kubernetes.io/master=true:NoSchedule" \
  --merge \
  --sudo \
  --context k3s-ha
```

1. Join a master:
```
k3sup join \
  --ip 10.10.1.155 \
  --user vagrant \
  --sudo \
  --server \
  --k3s-version v1.32.3+k3s1 \
  --server-ip 10.10.1.145  \
  --k3s-extra-args "--disable traefik --disable servicelb --flannel-iface=enp0s8 --node-ip=10.10.1.155 --node-taint node-role.kubernetes.io/master=true:NoSchedule" \
  --server-user vagrant
```

1. Join a agent:
```
k3sup join \
--ip 10.10.1.126 \
--user vagrant \
--sudo \
--agent \
--k3s-version v1.32.3+k3s1  \
--server-ip 10.10.1.145 \
--k3s-extra-args "--node-ip=10.10.1.126 --node-label \"longhorn=true\" --node-label \"worker=true\""
```
