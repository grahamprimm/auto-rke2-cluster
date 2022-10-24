variable "count_servers" {
  default = 3
  type        = number
}

variable "count_agents" {
  default = 5
  type        = number
}

variable "vm_password" {
  description = "Password of the terraform service account"
  sensitive   = true
  type        = string
}

variable "domain" {
  description = "Domain of network"
  type        = map(string)
  default = {
    net  = "net"
    org = "org"
    com = "com"
  }
}

variable "ip" {
  description = "IP address of big-bang"
  type        = map(string)
  default = {
    net  = "something"
    org = "X.X.X.X"
    com = "X.X.X.X"
  }
}

variable "notation" {
  description = "IP subnet of monotone-therapist cluster (to the third octet)"
  type        = map(string)
  default = {
    net  = "something"
    org = "X.X.X."
    com = "X.X.X."
  }
}

variable "netmask" {
  description = "Netmask of network 24 or 16"
  type        = map(number)
  default = {
    net  = 24
    org = 16
    com = 16
  }
}
variable "dns" {
  description = "DNS server of network"
  type        = map(string)
  default = {
    net  = "something"
    org = "X.X.X.X"
    com = "X.X.X.X"
  }
}
variable "gateway" {
  description = "Gateway of network (Usually X.X.X.254)"
  type        = map(string)
  default = {
    net  = "something"
    org = "X.X.X.254"
    com = "X.X.X.254"
  }
}