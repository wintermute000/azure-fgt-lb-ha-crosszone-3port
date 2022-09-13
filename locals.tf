locals {
  environment          = "Azure-hub-lb"
  #resource_name_prefix = "${var.business_divsion}-${var.environment}"
  #name = "${local.owners}-${local.environment}"
  common_tags = {
    Name               = "Johann Lo"
    username           = "loj"
    ExpectedUseThrough = "2023-04"
    VMState            = "ShutdownAtNight"
    "CostCenter"       = "790-5300"
  }
} 