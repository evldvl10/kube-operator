#!/usr/bin/env bash

set -e
set -x
rm -rf manifests
mkdir manifests

jsonnet -J vendor -m manifests "${1-example.jsonnet}" | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml; rm -f {}' -- {}
