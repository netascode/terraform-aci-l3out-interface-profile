variable "tenant" {
  description = "Tenant name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{0,64}$", var.tenant))
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "l3out" {
  description = "L3out name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{0,64}$", var.l3out))
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "node_profile" {
  description = "Node profile name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{0,64}$", var.node_profile))
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "name" {
  description = "Interface profile name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{0,64}$", var.name))
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "bfd_policy" {
  description = "BFD policy name."
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{0,64}$", var.bfd_policy))
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "ospf_interface_profile_name" {
  description = "OSPF interface profile name."
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{0,64}$", var.ospf_interface_profile_name))
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "ospf_authentication_key" {
  description = "OSPF authentication key."
  type        = string
  default     = ""
}

variable "ospf_authentication_key_id" {
  description = "OSPF authentication key ID."
  type        = number
  default     = 1

  validation {
    condition     = var.ospf_authentication_key_id >= 1 && var.ospf_authentication_key_id <= 255
    error_message = "Minimum value: 1. Maximum value: 255."
  }
}

variable "ospf_authentication_type" {
  description = "OSPF authentication type. Choices: `none`, `simple`, `md5`."
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "simple", "md5"], var.ospf_authentication_type)
    error_message = "Allowed values are `none`, `simple` or `md5`."
  }
}

variable "ospf_interface_policy" {
  description = "OSPF interface policy name."
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{0,64}$", var.ospf_interface_policy))
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "interfaces" {
  description = "List of interfaces. Default value `svi`: false. Choices `type`. `access`, `pc`, `vpc`. Default value `type`: `access`. Allowed values `vlan`: 1-4096. Format `mac`: `12:34:56:78:9A:BC`. `mtu`: Allowed values are `inherit` or a number between 576 and 9216. Allowed values `node_id`, `node2_id`: 1-4000. Allowed values `pod_id`: 1-255. Default value `pod_id`: 1. Allowed values `module`: 1-9. Default value `module`: 1. Allowed values `port`: 1-127. Default value `bgp_peers.bfd`: false. Allowed values `bgp_peers.ttl`: 1-255. Default value `bgp_peers.ttl`: 1. Allowed values `bgp_peers.weight`: 0-65535. Allowed values `bgp_peers.remote_as`: 0-4294967295."
  type = list(object({
    description = optional(string)
    type        = optional(string)
    svi         = optional(bool)
    vlan        = optional(number)
    mac         = optional(string)
    mtu         = optional(string)
    node_id     = number
    node2_id    = optional(number)
    pod_id      = optional(number)
    module      = optional(number)
    port        = optional(number)
    channel     = optional(string)
    ip          = optional(string)
    ip_a        = optional(string)
    ip_b        = optional(string)
    ip_shared   = optional(string)
    bgp_peers = optional(list(object({
      ip          = string
      description = optional(string)
      bfd         = optional(bool)
      ttl         = optional(number)
      weight      = optional(number)
      password    = optional(string)
      remote_as   = string
    })))
  }))
  default = []

  validation {
    condition = alltrue([
      for i in var.interfaces : i.description == null || try(can(regex("^[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]{0,128}$", i.description)), false)
    ])
    error_message = "`description`: Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `\\`, `!`, `#`, `$`, `%`, `(`, `)`, `*`, `,`, `-`, `.`, `/`, `:`, `;`, `@`, ` `, `_`, `{`, `|`, }`, `~`, `?`, `&`, `+`. Maximum characters: 128."
  }

  validation {
    condition = alltrue([
      for i in var.interfaces : i.type == null || try(contains(["access", "pc", "vpc"], i.type), false)
    ])
    error_message = "`type`: Allowed values are `access`, `pc` or `vpc`."
  }

  validation {
    condition = alltrue([
      for i in var.interfaces : i.vlan == null || try(i.vlan >= 1 && i.vlan <= 4096, false)
    ])
    error_message = "`vlan`: Minimum value: `1`. Maximum value: `4096`."
  }

  validation {
    condition = alltrue([
      for i in var.interfaces : i.mac == null || try(can(regex("^([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})$", i.mac)), false)
    ])
    error_message = "`mac`: Format: `12:34:56:78:9A:BC`."
  }

  validation {
    condition = alltrue([
      for i in var.interfaces : i.mtu == null || try(contains(["inherit"], i.mtu), false) || try(tonumber(i.mtu) >= 576 && tonumber(i.mtu) <= 9216, false)
    ])
    error_message = "`mtu`: Allowed values are `inherit` or a number between 576 and 9216."
  }

  validation {
    condition = alltrue([
      for i in var.interfaces : (i.node_id >= 1 && i.node_id <= 4000)
    ])
    error_message = "`node_id`: Minimum value: `1`. Maximum value: `4000`."
  }

  validation {
    condition = alltrue([
      for i in var.interfaces : i.node2_id == null || try(i.node2_id >= 1 && i.node2_id <= 4000, false)
    ])
    error_message = "`node2_id`: Minimum value: `1`. Maximum value: `4000`."
  }

  validation {
    condition = alltrue([
      for i in var.interfaces : i.pod_id == null || try(i.pod_id >= 1 && i.pod_id <= 255, false)
    ])
    error_message = "`pod_id`: Minimum value: `1`. Maximum value: `255`."
  }

  validation {
    condition = alltrue([
      for i in var.interfaces : i.module == null || try(i.module >= 1 && i.module <= 9, false)
    ])
    error_message = "`module`: Minimum value: `1`. Maximum value: `9`."
  }

  validation {
    condition = alltrue([
      for i in var.interfaces : i.port == null || try(i.port >= 1 && i.port <= 127, false)
    ])
    error_message = "`port`: Minimum value: `1`. Maximum value: `127`."
  }

  validation {
    condition = alltrue([
      for i in var.interfaces : i.channel == null || try(can(regex("^[a-zA-Z0-9_.-]{0,64}$", i.channel)), false)
    ])
    error_message = "`channel`: Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }

  validation {
    condition = alltrue(flatten([
      for i in var.interfaces : [for b in coalesce(i.bgp_peers, []) : b.description == null || try(can(regex("^[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]{0,128}$", b.description)), false)]
    ]))
    error_message = "`bgp_peers.description`: Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `\\`, `!`, `#`, `$`, `%`, `(`, `)`, `*`, `,`, `-`, `.`, `/`, `:`, `;`, `@`, ` `, `_`, `{`, `|`, }`, `~`, `?`, `&`, `+`. Maximum characters: 128."
  }

  validation {
    condition = alltrue(flatten([
      for i in var.interfaces : [for b in coalesce(i.bgp_peers, []) : b.ttl == null || try(b.ttl >= 1 && b.ttl <= 255, false)]
    ]))
    error_message = "`bgp_peers.ttl`: Minimum value: `1`. Maximum value: `255`."
  }

  validation {
    condition = alltrue(flatten([
      for i in var.interfaces : [for b in coalesce(i.bgp_peers, []) : b.weight == null || try(b.weight >= 0 && b.weight <= 65535, false)]
    ]))
    error_message = "`bgp_peers.weight`: Minimum value: `0`. Maximum value: `65535`."
  }

  validation {
    condition = alltrue(flatten([
      for i in var.interfaces : [for b in coalesce(i.bgp_peers, []) : b.remote_as >= 0 && b.remote_as <= 4294967295]
    ]))
    error_message = "`bgp_peers.remote_as`: Minimum value: `0`. Maximum value: `4294967295`."
  }
}
