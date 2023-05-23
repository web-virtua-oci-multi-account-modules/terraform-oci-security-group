locals {
  list_less_cidr_blocks = flatten([
    for item in var.allow_rules_group != null ? var.allow_rules_group : [] : [{
      protocol                  = var.protocols[item.protocol]
      sg_type                   = item.sg_type != null ? item.sg_type : var.type
      cidr_blocks               = item.cidr_blocks != null ? item.cidr_blocks : var.allow_cidr_blocks
      source_type               = item.source_type
      stateless                 = item.stateless
      description               = item.description
      destination               = item.destination
      destination_type          = item.destination_type
      ports                     = item.ports
      is_source_port_range      = item.is_source_port_range
      is_destination_port_range = item.is_destination_port_range
      icmp_options              = item.icmp_options
      }
    ]
  ])

  list_cidr_blocks = flatten([
    for item in local.list_less_cidr_blocks : [
      for cidr_block in item.cidr_blocks : [{
        protocol                  = item.protocol
        sg_type                   = item.sg_type
        cidr_block                = cidr_block
        source_type               = item.source_type
        stateless                 = item.stateless
        description               = item.description
        destination               = item.destination
        destination_type          = item.destination_type
        ports                     = item.ports
        is_source_port_range      = item.is_source_port_range
        is_destination_port_range = item.is_destination_port_range
        icmp_options              = item.icmp_options
      }]
    ]
  ])

  list_rules = flatten([
    for item in local.list_cidr_blocks : [
      for port in item.ports : [length(split(",", trimspace(tostring(port)))) == 1 ? [
        {
          protocol                  = item.protocol
          sg_type                   = item.sg_type
          cidr_block                = item.cidr_block
          source_type               = item.source_type
          stateless                 = item.stateless
          description               = item.description
          destination               = item.destination
          destination_type          = item.destination_type
          is_source_port_range      = item.is_source_port_range
          is_destination_port_range = item.is_destination_port_range
          icmp_options              = item.icmp_options
          port_mim                  = port
          port_max                  = port
        }] : [
        {
          protocol                  = item.protocol
          sg_type                   = item.sg_type
          cidr_block                = item.cidr_block
          source_type               = item.source_type
          stateless                 = item.stateless
          description               = item.description
          destination               = item.destination
          destination_type          = item.destination_type
          is_source_port_range      = item.is_source_port_range
          is_destination_port_range = item.is_destination_port_range
          icmp_options              = item.icmp_options
          port_mim                  = tonumber(split(",", replace(port, " ", ""))[0])
          port_max                  = tonumber(split(",", replace(port, " ", ""))[1])
        }]
      ]
    ]
  ])

  tags_security_group = {
    "tf-name"        = var.name
    "tf-type"        = "security-group"
    "tf-compartment" = var.compartment_name
  }
}

resource "oci_core_network_security_group" "create_security_group" {
  compartment_id = var.compartment_id
  display_name   = var.name
  vcn_id         = var.vcn_id
  defined_tags   = var.defined_tags
  freeform_tags  = merge(var.tags, var.use_tags_default ? local.tags_security_group : {})
}

resource "oci_core_network_security_group_security_rule" "create_security_group_rules" {
  count = length(local.list_rules)

  network_security_group_id = oci_core_network_security_group.create_security_group.id
  protocol                  = local.list_rules[count.index].protocol
  direction                 = local.list_rules[count.index].sg_type
  source                    = local.list_rules[count.index].cidr_block
  source_type               = (var.type == "INGRESS" && local.list_rules[count.index].source_type == null) ? "CIDR_BLOCK" : local.list_rules[count.index].source_type
  stateless                 = local.list_rules[count.index].stateless
  description               = local.list_rules[count.index].description
  destination               = local.list_rules[count.index].cidr_block
  destination_type          = (var.type == "EGRESS" && local.list_rules[count.index].destination_type == null) ? "CIDR_BLOCK" : local.list_rules[count.index].destination_type

  dynamic "icmp_options" {
    for_each = local.list_rules[count.index].icmp_options != null ? [1] : []

    content {
      type = local.list_rules[count.index].icmp_options.type
      code = local.list_rules[count.index].icmp_options.code
    }
  }

  dynamic "tcp_options" {
    for_each = local.list_rules[count.index].protocol == 6 ? [1] : []

    content {
      dynamic "source_port_range" {
        for_each = local.list_rules[count.index].is_source_port_range ? [1] : []

        content {
          min = local.list_rules[count.index].port_mim
          max = local.list_rules[count.index].port_max
        }
      }

      dynamic "destination_port_range" {
        for_each = local.list_rules[count.index].is_destination_port_range ? [1] : []

        content {
          min = local.list_rules[count.index].port_mim
          max = local.list_rules[count.index].port_max
        }
      }
    }
  }

  dynamic "udp_options" {
    for_each = local.list_rules[count.index].protocol == 17 ? [1] : []

    content {
      dynamic "source_port_range" {
        for_each = local.list_rules[count.index].is_source_port_range ? [1] : []

        content {
          min = local.list_rules[count.index].port_mim
          max = local.list_rules[count.index].port_max
        }
      }

      dynamic "destination_port_range" {
        for_each = local.list_rules[count.index].is_destination_port_range ? [1] : []

        content {
          min = local.list_rules[count.index].port_mim
          max = local.list_rules[count.index].port_max
        }
      }
    }
  }
}
