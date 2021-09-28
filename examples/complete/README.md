<!-- BEGIN_TF_DOCS -->
# L3out Interface Profile Example

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example will create resources. Resources can be destroyed with `terraform destroy`.

```hcl
module "aci_l3out_interface_profile" {
  source  = "netascode/l3out-interface-profile/aci"
  version = ">= 0.0.1"

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
<!-- END_TF_DOCS -->