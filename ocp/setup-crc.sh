crc config set consent-telemetry no && \
    crc config set cpus 4 && \
    crc config set memory 30000 && \
    crc config set enable-cluster-monitoring false && \
    crc config set kubeadmin-password 1qaz2wsx && \
    crc config set pull-secret-file ~/Projects/ocp/p.txt && \
    crc setup && \
    crc start
