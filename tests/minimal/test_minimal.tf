terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    aci = {
      source  = "netascode/aci"
      version = ">=0.2.0"
    }
  }
}

resource "aci_rest" "fvTenant" {
  dn         = "uni/tn-TF"
  class_name = "fvTenant"
}

resource "aci_rest" "l3extOut" {
  dn         = "${aci_rest.fvTenant.id}/out-L3OUT1"
  class_name = "l3extOut"
}

resource "aci_rest" "l3extLNodeP" {
  dn         = "${aci_rest.l3extOut.id}/lnodep-NP1"
  class_name = "l3extLNodeP"
}

module "main" {
  source = "../.."

  tenant       = aci_rest.fvTenant.content.name
  l3out        = aci_rest.l3extOut.content.name
  node_profile = aci_rest.l3extLNodeP.content.name
  name         = "IP1"
}

data "aci_rest" "l3extLIfP" {
  dn = module.main.dn

  depends_on = [module.main]
}

resource "test_assertions" "l3extLIfP" {
  component = "l3extLIfP"

  equal "name" {
    description = "name"
    got         = data.aci_rest.l3extLIfP.content.name
    want        = module.main.name
  }
}
