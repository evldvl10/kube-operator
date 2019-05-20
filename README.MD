# kube-operator

This repository contains:
  - flannel (https://github.com/coreos/flannel)
  - metallb (https://github.com/google/metallb)
  - ingress-nginx (https://github.com/kubernetes/ingress-nginx)
  - rook (https://github.com/rook/rook)
  - dashboard (https://github.com/kubernetes/dashboard)
  - kube-prometheus (https://github.com/coreos/kube-prometheus)

# Management
  - Dashboard (https://192.168.0.107:30000)
  - Ceph (http://ceph.cluster.lc)
  - Prometheus (http://prometheus.cluster.lc)
  - Grafana (http://grafana.cluster.lc)
  - AlertManager (http://alertmanager.cluster.lc)

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