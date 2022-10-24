variable "vsphere_server" {
  type = map(string)
  default = {
    net  = "something"
    org = "something"
    com = "something"
  }
}

variable "vsphere_user" {
  description = "Username of the terraform service account"
  sensitive   = true
  type        = string
}

variable "vsphere_password" {
  description = "Password of the terraform service account"
  sensitive   = true
  type        = string
}

variable "datacenter" {
  type = map(string)
  default = {
    com  = "something"
    org = "something"
    com = "something"
  }
}

variable "datastore" {
  type = map(string)
  default = {
    com  = "something"
    org = "something"
    com = "something"
  }
}

variable "cluster" {
  type = map(string)
  default = {
    com  = "something"
    org = "something"
    com = "something"
  }
}

variable "resource_pool" {
  type = map(string)
  default = {
    com  = "something"
    org = "something"
    com = "something"
  }
}

variable "network" {
  type = map(string)
  default = {
    com  = "something"
    org = "something"
    com = "something"
  }
}

variable "folder" {
  type = map(string)
  default = {
    com  = "something"
    org = "something"
    com = "something"
  }
}