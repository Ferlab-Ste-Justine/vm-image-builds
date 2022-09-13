#cloud-config
users:
  - default
  - name: ${user}
    ssh_authorized_keys:
      - "${ssh_key}"