cd monitoring && jb install && sh build.sh monitoring.jsonnet && cd ..
cat /dev/null > kustomization.yaml
kustomize edit add resource flannel/*.yaml
kustomize edit add resource metallb/*.yaml
kustomize edit add resource ingress-nginx/*.yaml
kustomize edit add resource rook/*.yaml
kustomize edit add resource users/*.yaml
kustomize edit add resource dashboard/*.yaml
kustomize edit add resource monitoring/manifests/*.yaml
kustomize edit add resource prometheus/*.yaml
kubectl apply -k .
