#cloud-config
users:
  - name: ${ssh_username}
    lock_passwd: false
    groups: [sudo,admin]
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    plain_text_passwd: ${ssh_password}
write_files:
  - path: /etc/rancher/k3s/config.yaml
    content: |
        flannel-iface:
          - "ens160"
        node-label:
          - "project=partition-1"
          - "zone=node1"
        disable:
          - "traefik"
        kube-apiserver-arg:
          - "service-node-port-range=1025-65535"
        install-k3s-skip-download: true
