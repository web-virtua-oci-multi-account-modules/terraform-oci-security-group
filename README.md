# OCI Security Group for multiples accounts with Terraform module
* This module simplifies creating and configuring of Security Group across multiple accounts on OCI

* Is possible use this module with one account using the standard profile or multi account using multiple profiles setting in the modules.

## Actions necessary to use this module:

* Criate file provider.tf with the exemple code below:
```hcl
provider "oci" {
  alias   = "alias_profile_a"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.ssh_private_key_path
  region           = var.region
}

provider "oci" {
  alias   = "alias_profile_b"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.ssh_private_key_path
  region           = var.region
}
```


## Features enable of Security Group configurations for this module:

- Security Group
- Security Group Rules 

## Usage exemples


### Create security Group for EGRESS with allow_cidr_blocks variable to used on rules that has no defined 

```hcl
module "all_eggres_test" {
  source = "web-virtua-oci-multi-account-modules/security-list/oci"

  compartment_id = var.compartment_id
  name           = "tf-security-group-all-eggress"
  vcn_id         = var.vcn_id
  type           = "EGRESS"
  allow_cidr_blocks = ["0.0.0.0/0"]

  allow_rules_group = [
    {
      protocol    = "all"
      ports       = ["all"]
      description = "ALL Egress"
    }
  ]

  providers = {
    oci = oci.alias_profile_a
  }
}
```

### Create security Group for INGRESS with allow_cidr_blocks variable to used on rules that has no defined and many rules examples

```hcl
module "security_group" {
  source = "web-virtua-oci-multi-account-modules/security-list/oci"

  compartment_id = var.network_dev_compartment_id
  name           = "tf-security-group"
  vcn_id         = var.vcn_id
  type           = "INGRESS"
  allow_cidr_blocks = ["192.168.10.10/32"]

  allow_rules_group = [
    {
      protocol    = "all"
      ports       = ["all"]
      description = "Allow all"
    },
    {
      protocol    = "tcp"
      cidr_blocks = ["3.218.27.135/32"]
      ports       = [22]
      description = "Allow SSH"
    },
    {
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
      ports       = [80]
      description = "Allow UDP on 80"
    },
    {
      protocol    = "tcp"
      cidr_blocks = ["3.211.27.135/32", "10.1.0.0/16"]
      ports       = [80]
      stateless   = true
      description = "Allow TCP on 80"
    },
    {
      protocol    = "tcp"
      cidr_blocks = ["177.30.66.137/32"]
      ports       = ["3000, 3005"]
      description = "Allow TCP from 300 up to 3005"
    }
  ]

  providers = {
    oci = oci.alias_profile_a
  }
}
```


## Variables

| Name | Type | Default | Required | Description | Options |
|------|-------------|------|---------|:--------:|:--------|
| compartment_id | `string` | `-` | yes | Compartment ID | `-` |
| name | `string` | `-` | yes | Security Group name | `-` |
| vcn_id | `string` | `-` | yes | VCN ID | `-` |
| compartment_name | `string` | `null` | no | Compartment name | `-` |
| type | `string` | `INGRESS` | no | If the security group is type of ingress, can be INGRESS or EGRESS | `-` |
| is_stateless | `bool` | `false` | no | If true will be stateless | `*`false <br> `*`true |
| allow_cidr_blocks | `list(string)` | `[]` | no | Allow cidir blocks, if defined this values will be used in all cidr block for each rules | `-` |
| use_tags_default | `bool` | `true` | no | If true will be use the tags default to resources | `*`false <br> `*`true |
| tags | `map(any)` | `{}` | no | Tags to security Group | `-` |
| defined_tags | `map(any)` | `{}` | no | Defined tags to security Group | `-` |
| allow_rules_group | `list(object)` | `[]` | no | List with rules, ports and protocols allowed | `-` |

* Default protocols variable
```hcl
variable "protocols" {
  description = "Available protocols, can be used the default protocols or customize, the values by default are all, icmp, ipv4, tcp, udp, ipv6 and icmpv6. Doc: others protocols http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml"
  type        = object({
    all    = string
    icmp   = number
    ipv4   = number
    tcp    = number
    udp    = number
    ipv6   = number
    icmpv6 = number
  })
  default = {
    all    = "all"
    icmp   = 1
    ipv4   = 4
    tcp    = 6
    udp    = 17
    ipv6   = 41
    icmpv6 = 58
  }
}
```

* Model of allow_rules_group variable
```hcl
variable "allow_rules_group" {
  description = "Group with rules, ports and protocols allowed"
  type = list(object({
    protocol                  = string
    sg_type                   = optional(string)
    cidr_blocks               = optional(list(string))
    source_type               = optional(string)
    stateless                 = optional(bool, false)
    description               = optional(string)
    destination               = optional(string)
    destination_type          = optional(string)
    ports                     = optional(list(any))
    is_source_port_range      = optional(bool, false)
    is_destination_port_range = optional(bool, true)
    icmp_options = optional(object({
      type = number
      code = number
    }))
  }))
  default = [
    {
      protocol    = "all"
      ports       = ["all"]
      description = "ALL Egress"
    }
  ]
}
```


## Resources

| Name | Type |
|------|------|
| [oci_core_network_security_group.create_security_group](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group) | resource |
| [oci_core_network_security_group_security_rule.create_security_group_rules](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |

## Outputs

| Name | Description |
|------|-------------|
| `security_group` | Security Group |
| `security_group_id` | Security Group ID |
| `security_group_rules` | Security Group Rules |
