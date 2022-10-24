locals {
  datacenter    = lookup(var.datacenter, terraform.workspace, null)
  datastore     = lookup(var.datastore, terraform.workspace, null)
  cluster       = lookup(var.cluster, terraform.workspace, null)
  resource_pool = lookup(var.resource_pool, terraform.workspace, null)
  network       = lookup(var.network, terraform.workspace, null)
}

data "vsphere_datacenter" "datacenter" {
  name = local.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = local.datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = local.cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "resources" {
  name          = local.resource_pool
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "servers" {
  name          = local.network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = "RHEL8_HARDENED_TEMPLATE"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}