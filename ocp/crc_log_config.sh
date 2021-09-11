#!/usr/bin/env bash
eval $(crc oc-env) && oc login -u kubeadmin -p 1qaz2wsx --insecure-skip-tls-verify=true https://api.crc.testing:6443
oc create -f /home/angus/Projects/ocp/eo-namespace.yaml
oc create -f /home/angus/Projects/ocp/olo-namespace.yaml
oc create -f /home/angus/Projects/ocp/eo-og.yaml
oc create -f /home/angus/Projects/ocp/eo-sub.yaml
oc create -f /home/angus/Projects/ocp/olo-og.yaml
oc create -f /home/angus/Projects/ocp/olo-sub.yaml
#oc create -f /home/angus/Projects/ocp/olo-instance.yaml
