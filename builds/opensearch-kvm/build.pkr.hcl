variable "iso" {
  type = object({
    url = string
    checksum = string
  })
}

variable "ssh" {
  type = object({
    public_key = string
    private_key = string
  })
}

variable "admin_user" {
  type = string
  default = "ubuntu"
}

variable "vm_name" {
  type = string
  default = "opensearch-build"
}

variable "troubleshooting" {
  type = bool  
  default = false
}

source "qemu" "opensearch" {
  vm_name              = var.vm_name
  iso_url              = var.iso.url
  iso_checksum         = var.iso.checksum
  output_directory     = "output"
  shutdown_command     = "sudo shutdown -P now"
  use_backing_file     = true
  disk_image           = true
  disk_size            = "10G"
  disk_interface       = "virtio-scsi"
  disk_discard         = "unmap"
  net_device           = "virtio-net"
  memory               = 4096
  cpus                 = 1
  format               = "qcow2"
  accelerator          = "kvm"
  ssh_username         = var.admin_user
  ssh_private_key_file = var.ssh.private_key
  ssh_timeout          = "2m"
  headless             = true
  boot_wait            = "10s"
  http_content = {
    "/meta-data" = ""
    "/user-data" = templatefile(
      "${path.root}/cloud-data/user-data.tpl",
      {
        user    = var.admin_user
        ssh_key = file(pathexpand(var.ssh.public_key))
      }
    )
  }

  qemuargs = [
    ["-smbios", "type=1,serial=ds=nocloud-net;instance-id=opensearch;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/"]
  ]
}

build {
  sources = ["source.qemu.opensearch"]

  provisioner "ansible" {
    playbook_file = "${path.root}/ansible/playbook.yml"
  }

  provisioner "shell" {
    inline = ["sudo cloud-init clean -ls"]
  }

  provisioner "breakpoint" {
    disable = !var.troubleshooting
    note    = "Troubleshoot breakpoint"
  }
}