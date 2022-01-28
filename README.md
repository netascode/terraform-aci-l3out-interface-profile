<!-- BEGIN_TF_DOCS -->
[![Tests](https://github.com/netascode/terraform-aci-l3out-interface-profile/actions/workflows/test.yml/badge.svg)](https://github.com/netascode/terraform-aci-l3out-interface-profile/actions/workflows/test.yml)

# Terraform ACI L3out Interface Profile Module

Manages ACI L3out Interface Profile

Location in GUI:
`Tenants` » `XXX` » `Networking` » `L3outs` » `XXX` » `Logical Node Profiles` » `XXX` » `Logical Interface Profiles`

## Examples

```hcl
module "aci_l3out_interface_profile" {
  source  = "netascode/l3out-interface-profile/aci"
  version = ">= 0.1.0"

  tenant                      = "ABC"
  l3out                       = "L3OUT1"
  node_profile                = "NP1"
  name                        = "IP1"
  bfd_policy                  = "BFD1"
  ospf_interface_profile_name = "OSPFP1"
  ospf_authentication_key     = "12345678"
  ospf_authentication_key_id  = 2
  ospf_authentication_type    = "md5"
  ospf_interface_policy       = "OSPF1"
  interfaces = [{
    description = "Interface 1"
    type        = "vpc"
    svi         = true
    vlan        = 5
    mac         = "12:34:56:78:90:AB"
    mtu         = "1500"
    node_id     = 201
    node2_id    = 202
    pod_id      = 2
    channel     = "VPC1"
    ip_a        = "1.1.1.2/24"
    ip_b        = "1.1.1.3/24"
    ip_shared   = "1.1.1.1/24"
    bgp_peers = [{
      ip          = "1.1.1.10"
      description = "BGP Peer"
      bfd         = true
      ttl         = 10
      weight      = 100
      password    = "PASSWORD"
      remote_as   = "12345"
    }]
  }]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aci"></a> [aci](#requirement\_aci) | >= 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aci"></a> [aci](#provider\_aci) | >= 2.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tenant"></a> [tenant](#input\_tenant) | Tenant name. | `string` | n/a | yes |
| <a name="input_l3out"></a> [l3out](#input\_l3out) | L3out name. | `string` | n/a | yes |
| <a name="input_node_profile"></a> [node\_profile](#input\_node\_profile) | Node profile name. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Interface profile name. | `string` | n/a | yes |
| <a name="input_bfd_policy"></a> [bfd\_policy](#input\_bfd\_policy) | BFD policy name. | `string` | `""` | no |
| <a name="input_ospf_interface_profile_name"></a> [ospf\_interface\_profile\_name](#input\_ospf\_interface\_profile\_name) | OSPF interface profile name. | `string` | `""` | no |
| <a name="input_ospf_authentication_key"></a> [ospf\_authentication\_key](#input\_ospf\_authentication\_key) | OSPF authentication key. | `string` | `""` | no |
| <a name="input_ospf_authentication_key_id"></a> [ospf\_authentication\_key\_id](#input\_ospf\_authentication\_key\_id) | OSPF authentication key ID. | `number` | `1` | no |
| <a name="input_ospf_authentication_type"></a> [ospf\_authentication\_type](#input\_ospf\_authentication\_type) | OSPF authentication type. Choices: `none`, `simple`, `md5`. | `string` | `"none"` | no |
| <a name="input_ospf_interface_policy"></a> [ospf\_interface\_policy](#input\_ospf\_interface\_policy) | OSPF interface policy name. | `string` | `""` | no |
| <a name="input_interfaces"></a> [interfaces](#input\_interfaces) | List of interfaces. Default value `svi`: false. Choices `type`. `access`, `pc`, `vpc`. Default value `type`: `access`. Allowed values `vlan`: 1-4096. Format `mac`: `12:34:56:78:9A:BC`. `mtu`: Allowed values are `inherit` or a number between 576 and 9216. Allowed values `node_id`, `node2_id`: 1-4000. Allowed values `pod_id`: 1-255. Default value `pod_id`: 1. Allowed values `module`: 1-9. Default value `module`: 1. Allowed values `port`: 1-127. Default value `bgp_peers.bfd`: false. Allowed values `bgp_peers.ttl`: 1-255. Default value `bgp_peers.ttl`: 1. Allowed values `bgp_peers.weight`: 0-65535. Default value `bgp_peers.weight`: 0. Allowed values `bgp_peers.remote_as`: 0-4294967295. | <pre>list(object({<br>    description = optional(string)<br>    type        = optional(string)<br>    svi         = optional(bool)<br>    vlan        = optional(number)<br>    mac         = optional(string)<br>    mtu         = optional(string)<br>    node_id     = number<br>    node2_id    = optional(number)<br>    pod_id      = optional(number)<br>    module      = optional(number)<br>    port        = optional(number)<br>    channel     = optional(string)<br>    ip          = optional(string)<br>    ip_a        = optional(string)<br>    ip_b        = optional(string)<br>    ip_shared   = optional(string)<br>    bgp_peers = optional(list(object({<br>      ip          = string<br>      description = optional(string)<br>      bfd         = optional(bool)<br>      ttl         = optional(number)<br>      weight      = optional(number)<br>      password    = optional(string)<br>      remote_as   = string<br>    })))<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dn"></a> [dn](#output\_dn) | Distinguished name of `l3extLIfP` object. |
| <a name="output_name"></a> [name](#output\_name) | Interface profile name. |

## Resources

| Name | Type |
|------|------|
| [aci_rest_managed.bfdIfP](https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/rest_managed) | resource |
| [aci_rest_managed.bfdRsIfPol](https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/rest_managed) | resource |
| [aci_rest_managed.bgpAsP](https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/rest_managed) | resource |
| [aci_rest_managed.bgpPeerP](https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/rest_managed) | resource |
| [aci_rest_managed.l3extIp_A](https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/rest_managed) | resource |
| [aci_rest_managed.l3extIp_B](https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/rest_managed) | resource |
| [aci_rest_managed.l3extLIfP](https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/rest_managed) | resource |
| [aci_rest_managed.l3extMember_A](https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/rest_managed) | resource |
| [aci_rest_managed.l3extMember_B](https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/rest_managed) | resource |
| [aci_rest_managed.l3extRsPathL3OutAtt](https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/rest_managed) | resource |
| [aci_rest_managed.ospfIfP](https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/rest_managed) | resource |
| [aci_rest_managed.ospfRsIfPol](https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/rest_managed) | resource |
<!-- END_TF_DOCS -->