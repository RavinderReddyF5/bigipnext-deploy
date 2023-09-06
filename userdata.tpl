#cloud-config
password: ${ssh_password}
chpasswd: { expire: False }
users:
  - name: ${ssh_username}
    lock_passwd: false
    groups: [sudo,admin]
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    plain_text_passwd: ${ssh_password}