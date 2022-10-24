
locals {
  vsphere_server = lookup(var.vsphere_server, terraform.workspace, null)
  domain         = lookup(var.domain, terraform.workspace, null)
  folder         = lookup(var.folder, terraform.workspace, null)
  ip             = lookup(var.ip, terraform.workspace, null)
  netmask        = lookup(var.netmask, terraform.workspace, null)
  dns            = lookup(var.dns, terraform.workspace, null)
  gateway        = lookup(var.gateway, terraform.workspace, null)
  notation       = lookup(var.notation, terraform.workspace, null)
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = local.vsphere_server
  allow_unverified_ssl = true
}

resource "vsphere_virtual_machine" "loadbalancer" {
  name             = "mother-lb"
  guest_id         = "rhel8_64Guest"
  num_cpus         = 2
  memory           = 8192
  folder           = local.folder
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.resources.id
  firmware         = data.vsphere_virtual_machine.template.firmware
  network_interface {
    network_id = data.vsphere_network.servers.id
  }
  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "mother-lb"
        domain    = local.domain
      }
      network_interface {
        ipv4_address    = "${local.notation}55"
        ipv4_netmask    = local.netmask
        dns_server_list = [local.dns]
      }
      ipv4_gateway = local.gateway
    }
  }
}

resource "vsphere_virtual_machine" "nfs" {
  name             = "mother-nfs"
  guest_id         = "rhel8_64Guest"
  num_cpus         = 6
  memory           = 16384
  folder           = local.folder
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.resources.id
  firmware         = data.vsphere_virtual_machine.template.firmware
  network_interface {
    network_id = data.vsphere_network.MGMT.id
  }
  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  disk {
    label            = "disk1"
    size             = 2048
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    unit_number      = 1
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "mother-nfs"
        domain    = local.domain
      }
      network_interface {
        ipv4_address    = "${local.notation}58"
        ipv4_netmask    = local.netmask
        dns_server_list = [local.dns]
      }
      ipv4_gateway = local.gateway
    }
  }

  provisioner "local-exec" {
    command =  join(" ", ["ANSIBLE_CONFIG='../ansible/ansible.cfg'", 
                          "ansible-playbook -i '${self.default_ip_address},'",
                          "-e ip=${self.default_ip_address}",
                          "-e dns_server=${local.dns}",
                          "-e hostname=mother-nfs.${local.domain}",
                          "-e notation=${local.notation}",
                          "-e zone=big-bang.${local.domain}",
                          "--vault-password-file ../vpass.txt",
                          "../ansible/06_nfs.yml"])
  }
}

resource "vsphere_virtual_machine" "server" {
  name             = "mother-server-${count.index}"
  guest_id         = "rhel8_64Guest"
  num_cpus         = 6
  memory           = 32768
  count            = var.count_servers
  folder           = local.folder
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.resources.id
  firmware         = data.vsphere_virtual_machine.template.firmware
  network_interface {
    network_id = data.vsphere_network.MGMT.id
  }
  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  disk {
    label            = "disk1"
    size             = 1024
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    unit_number      = 1
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "mother-server-${count.index}"
        domain    = local.domain
      }
      network_interface {
        ipv4_address    = "${local.notation}5${count.index}"
        ipv4_netmask    = local.netmask
        dns_server_list = [local.dns]
      }
      ipv4_gateway = local.gateway
    }
  }
}

resource "vsphere_virtual_machine" "agent" {
  name             = "mother-agent-${count.index}"
  guest_id         = "rhel8_64Guest"
  num_cpus         = 6
  memory           = 32768
  count            = var.count_agents
  folder           = local.folder
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.resources.id
  firmware         = data.vsphere_virtual_machine.template.firmware
  network_interface {
    network_id = data.vsphere_network.MGMT.id
  }
  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  disk {
    label            = "disk1"
    size             = 1024
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    unit_number      = 1
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "mother-agent-${count.index}"
        domain    = local.domain
      }
      network_interface {
        ipv4_address    = "${local.notation}6${count.index}"
        ipv4_netmask    = local.netmask
        dns_server_list = [local.dns]
      }
      ipv4_gateway = local.gateway
    }
  }
}
resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/hosts.tpl",
    {
      servers = vsphere_virtual_machine.server.*.default_ip_address
      agents = vsphere_virtual_machine.agent.*.default_ip_address
      lb = vsphere_virtual_machine.loadbalancer.*.default_ip_address
      lb_hostname = "mother-lb.${local.domain}"
    }
  )
  filename = "../ansible/hosts.ini"
}