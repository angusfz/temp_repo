#!/usr/bin/env bash
set -euo pipefail

# ocp logging
LOG_CONFIG="/home/${USER}/Projects/ocp"

cat << EOF > ${LOG_CONFIG}/eo-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-operators-redhat 
  annotations:
    openshift.io/node-selector: ""
  labels:
    openshift.io/cluster-monitoring: "true"
EOF

cat << EOF > ${LOG_CONFIG}/olo-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-logging
  annotations:
    openshift.io/node-selector: ""
  labels:
    openshift.io/cluster-monitoring: "true"
EOF

cat << EOF > ${LOG_CONFIG}/eo-og.yaml
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-operators-redhat
  namespace: openshift-operators-redhat 
spec: {}
EOF

cat << EOF > ${LOG_CONFIG}/eo-sub.yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: "elasticsearch-operator"
  namespace: "openshift-operators-redhat" 
spec:
  channel: "stable-5.1" 
  installPlanApproval: "Automatic"
  source: "redhat-operators" 
  sourceNamespace: "openshift-marketplace"
  name: "elasticsearch-operator"
EOF

cat << EOF > ${LOG_CONFIG}/olo-og.yaml
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: cluster-logging
  namespace: openshift-logging 
spec:
  targetNamespaces:
  - openshift-logging 
EOF

cat << EOF > ${LOG_CONFIG}/olo-sub.yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: cluster-logging
  namespace: openshift-logging 
spec:
  channel: "stable" 
  name: cluster-logging
  source: redhat-operators 
  sourceNamespace: openshift-marketplace
EOF

cat << EOF > ${LOG_CONFIG}/olo-instance.yaml
apiVersion: "logging.openshift.io/v1"
kind: "ClusterLogging"
metadata:
  name: "instance" 
  namespace: "openshift-logging"
spec:
  managementState: "Managed"  
  logStore:
    type: "elasticsearch"  
    retentionPolicy: 
      application:
        maxAge: 1d
      infra:
        maxAge: 7d
      audit:
        maxAge: 7d
    elasticsearch:
      nodeCount: 2
      storage:
        size: 2G
      resources: 
        requests:
          memory: "2Gi"
      proxy: 
        resources:
          limits:
            memory: 256Mi
          requests:
             memory: 256Mi
      redundancyPolicy: "SingleRedundancy"
  visualization:
    type: "kibana"  
    kibana:
      replicas: 1
  collection:
    logs:
      type: "fluentd"  
      fluentd: {}
EOF
chmod a+wx -R ${LOG_CONFIG}

cat << EOF > ${LOG_CONFIG}/crc_log_config.sh
#!/usr/bin/env bash
eval \$(crc oc-env) && oc login -u kubeadmin -p 1qaz2wsx --insecure-skip-tls-verify=true https://api.crc.testing:6443
oc create -f ${LOG_CONFIG}/eo-namespace.yaml
oc create -f ${LOG_CONFIG}/olo-namespace.yaml
oc create -f ${LOG_CONFIG}/eo-og.yaml
oc create -f ${LOG_CONFIG}/eo-sub.yaml
oc create -f ${LOG_CONFIG}/olo-og.yaml
oc create -f ${LOG_CONFIG}/olo-sub.yaml
sleep 30
oc create -f ${LOG_CONFIG}/olo-instance.yaml
EOF
chmod a+wx ${LOG_CONFIG}/crc_log_config.sh
