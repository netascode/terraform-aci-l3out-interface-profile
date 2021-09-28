locals {
  interfaces = flatten([
    for int in var.interfaces : {
      key = "${int.type == "vpc" ? "topology/pod-${int.pod_id != null ? int.pod_id : 1}/protpaths-${int.node_id}-${int.node2_id}/pathep-[${int.channel}]" : (int.type == "pc" ? "topology/pod-${int.pod_id != null ? int.pod_id : 1}/paths-${int.node_id}/pathep-[${int.channel}]" : "topology/pod-${int.pod_id != null ? int.pod_id : 1}/paths-${int.node_id}/pathep-[eth${int.module != null ? int.module : 1}/${int.port}]")}"
      value = {
        ip          = int.type != "vpc" ? int.ip : "0.0.0.0"
        svi         = int.svi == true ? "yes" : "no"
        description = int.description != null ? int.description : ""
        type        = int.type
        vlan        = int.vlan
        mac         = int.mac != null ? int.mac : "00:22:BD:F8:19:FF"
        mtu         = int.mtu != null ? int.mtu : "inherit"
        node_id     = int.node_id
        node2_id    = int.node2_id
        module      = int.module != null ? int.module : 1
        pod_id      = int.pod_id != null ? int.pod_id : 1
        port        = int.port
        channel     = int.channel
        ip_a        = int.ip_a
        ip_b        = int.ip_b
        ip_shared   = int.ip_shared
        tDn         = int.type == "vpc" ? "topology/pod-${int.pod_id != null ? int.pod_id : 1}/protpaths-${int.node_id}-${int.node2_id}/pathep-[${int.channel}]" : (int.type == "pc" ? "topology/pod-${int.pod_id != null ? int.pod_id : 1}/paths-${int.node_id}/pathep-[${int.channel}]" : "topology/pod-${int.pod_id != null ? int.pod_id : 1}/paths-${int.node_id}/pathep-[eth${int.module != null ? int.module : 1}/${int.port}]")
      }
    }
  ])
  bgp_peers = flatten([
    for int in var.interfaces : [
      for peer in coalesce(int.bgp_peers, []) : {
        key = "${int.type == "vpc" ? "topology/pod-${int.pod_id != null ? int.pod_id : 1}/protpaths-${int.node_id}-${int.node2_id}/pathep-[${int.channel}]" : (int.type == "pc" ? "topology/pod-${int.pod_id != null ? int.pod_id : 1}/paths-${int.node_id}/pathep-[${int.channel}]" : "topology/pod-${int.pod_id != null ? int.pod_id : 1}/paths-${int.node_id}/pathep-[eth${int.module != null ? int.module : 1}/${int.port}]")}/${peer.ip}"
        value = {
          interface   = "${int.type == "vpc" ? "topology/pod-${int.pod_id != null ? int.pod_id : 1}/protpaths-${int.node_id}-${int.node2_id}/pathep-[${int.channel}]" : (int.type == "pc" ? "topology/pod-${int.pod_id != null ? int.pod_id : 1}/paths-${int.node_id}/pathep-[${int.channel}]" : "topology/pod-${int.pod_id != null ? int.pod_id : 1}/paths-${int.node_id}/pathep-[eth${int.module != null ? int.module : 1}/${int.port}]")}"
          ip          = peer.ip
          description = peer.description != null ? peer.description : ""
          bfd         = peer.bfd == true ? "bfd" : ""
          ttl         = peer.ttl != null ? peer.ttl : 1
          weight      = peer.weight != null ? peer.weight : ""
          password    = peer.password != null ? peer.password : null
          remote_as   = peer.remote_as
        }
      }
    ]
  ])
}

resource "aci_rest" "l3extLIfP" {
  dn         = "uni/tn-${var.tenant}/out-${var.l3out}/lnodep-${var.node_profile}/lifp-${var.name}"
  class_name = "l3extLIfP"
  content = {
    name = var.name
  }
}

resource "aci_rest" "ospfIfP" {
  count      = var.ospf_authentication_key != "" || var.ospf_interface_policy != "" ? 1 : 0
  dn         = "${aci_rest.l3extLIfP.id}/ospfIfP"
  class_name = "ospfIfP"
  content = {
    name      = var.ospf_interface_profile_name
    authKeyId = var.ospf_authentication_key_id
    authKey   = var.ospf_authentication_key
    authType  = var.ospf_authentication_type
  }

  lifecycle {
    ignore_changes = [content["authKey"]]
  }
}

resource "aci_rest" "ospfRsIfPol" {
  count      = var.ospf_interface_policy != "" ? 1 : 0
  dn         = "${aci_rest.ospfIfP[0].id}/rsIfPol"
  class_name = "ospfRsIfPol"
  content = {
    tnOspfIfPolName = var.ospf_interface_policy
  }
}

resource "aci_rest" "bfdIfP" {
  count      = var.bfd_policy != "" ? 1 : 0
  dn         = "${aci_rest.l3extLIfP.id}/bfdIfP"
  class_name = "bfdIfP"
  content = {
    "type" = "none"
  }
}

resource "aci_rest" "bfdRsIfPol" {
  count      = var.bfd_policy != "" ? 1 : 0
  dn         = "${aci_rest.bfdIfP[0].id}/rsIfPol"
  class_name = "bfdRsIfPol"
  content = {
    tnBfdIfPolName = var.bfd_policy
  }
}

resource "aci_rest" "l3extRsPathL3OutAtt" {
  for_each   = { for item in local.interfaces : item.key => item.value }
  dn         = "${aci_rest.l3extLIfP.id}/rspathL3OutAtt-[${each.value.tDn}]"
  class_name = "l3extRsPathL3OutAtt"
  content = {
    addr       = each.value.ip
    autostate  = "disabled"
    descr      = each.value.description
    encapScope = "local"
    ifInstT    = each.value.vlan != null ? (each.value.svi == "yes" ? "ext-svi" : "sub-interface") : "l3-port"
    encap      = each.value.vlan != null ? "vlan-${each.value.vlan}" : null
    ipv6Dad    = "enabled"
    llAddr     = "::"
    mac        = each.value.mac
    mode       = "regular"
    mtu        = each.value.mtu
    tDn        = each.value.tDn
  }
}

resource "aci_rest" "l3extMember_A" {
  for_each   = { for item in local.interfaces : item.key => item.value if item.value.type == "vpc" }
  dn         = "${aci_rest.l3extRsPathL3OutAtt[each.key].id}/mem-A"
  class_name = "l3extMember"
  content = {
    addr = each.value.ip_a
    side = "A"
  }
}

resource "aci_rest" "l3extIp_A" {
  for_each   = { for item in local.interfaces : item.key => item.value if item.value.type == "vpc" }
  dn         = "${aci_rest.l3extMember_A[each.key].id}/addr-[${each.value.ip_shared}]"
  class_name = "l3extIp"
  content = {
    addr = each.value.ip_shared
  }
}

resource "aci_rest" "l3extMember_B" {
  for_each   = { for item in local.interfaces : item.key => item.value if item.value.type == "vpc" }
  dn         = "${aci_rest.l3extRsPathL3OutAtt[each.key].id}/mem-B"
  class_name = "l3extMember"
  content = {
    addr = each.value.ip_b
    side = "B"
  }
}

resource "aci_rest" "l3extIp_B" {
  for_each   = { for item in local.interfaces : item.key => item.value if item.value.type == "vpc" }
  dn         = "${aci_rest.l3extMember_B[each.key].id}/addr-[${each.value.ip_shared}]"
  class_name = "l3extIp"
  content = {
    addr = each.value.ip_shared
  }
}

resource "aci_rest" "bgpPeerP" {
  for_each   = { for item in local.bgp_peers : item.key => item.value }
  dn         = "${aci_rest.l3extRsPathL3OutAtt[each.value.interface].id}/peerP-[${each.value.ip}]"
  class_name = "bgpPeerP"
  content = {
    addr             = each.value.ip
    addrTCtrl        = "af-ucast"
    allowedSelfAsCnt = "3"
    ctrl             = "send-com,send-ext-com"
    descr            = each.value.description
    peerCtrl         = each.value.bfd
    privateASctrl    = ""
    ttl              = each.value.ttl
    weight           = each.value.weight
    password         = each.value.password
  }

  lifecycle {
    ignore_changes = [content["password"]]
  }
}

resource "aci_rest" "bgpAsP" {
  for_each   = { for item in local.bgp_peers : item.key => item.value }
  dn         = "${aci_rest.bgpPeerP[each.key].id}/as"
  class_name = "bgpAsP"
  content = {
    asn = each.value.remote_as
  }
}
