# kube-operator

This repository contains:
  - flannel (https://github.com/coreos/flannel)
  - metallb (https://github.com/google/metallb)
  - ingress-nginx (https://github.com/kubernetes/ingress-nginx)
  - rook (https://github.com/rook/rook)
  - dashboard (https://github.com/kubernetes/dashboard)
  - kube-prometheus (https://github.com/coreos/kube-prometheus)

# Management
### Dashboard
https://192.168.0.107:30000

![screenshot](https://i.ibb.co/8g5Tcw4/Screenshot-from-2019-05-20-04-16-43.png)

### Ceph
http://ceph.cluster.lc

![screenshot](https://i.ibb.co/HxV0DtM/Screenshot-from-2019-05-20-04-17-08.png)

### Grafana
http://grafana.cluster.lc

![screenshot](https://i.ibb.co/z6rhSC9/Screenshot-from-2019-05-20-04-17-23.png)

### Prometheus
http://prometheus.cluster.lc

![screenshot](https://i.ibb.co/TTPwDyb/Screenshot-from-2019-05-20-04-17-36.png)

### AlertManager
http://alertmanager.cluster.lc

![screenshot](https://i.ibb.co/6Pc62Dc/Screenshot-from-2019-05-20-04-17-47.png)
  
# Credentials
Get dashboard token
```sh
$ kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
```
Get Ceph "admin" password
```sh
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
```
Use admin/admin to access "Prometheus", "Grafana", "AlertManager" management systems.

# Install dependencies
[Install Go](https://github.com/user/repo/blob/branch/other_file.md), then run:
```sh
$ go get github.com/google/go-jsonnet/cmd/jsonnet
$ go get github.com/brancz/gojsontoyaml
$ go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
$ go get sigs.k8s.io/kustomize
```

# Build
  - Build .yaml configs
  - Build and apply kustomize
```sh
$ build.sh
```

### To fix the bug with dashboards in the Ceph control panel
Connect to toolbox
```sh
$ kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') bash
```
and run commands
```sh
ceph dashboard ac-role-create admin-no-iscsi

for scope in dashboard-settings log rgw prometheus grafana nfs-ganesha manager hosts rbd-image config-opt rbd-mirroring cephfs user osd pool monitor; do
    ceph dashboard ac-role-add-scope-perms admin-no-iscsi ${scope} create delete read update;
done

ceph dashboard ac-user-set-roles admin admin-no-iscsi
```
More info: https://github.com/rook/rook/issues/3106
