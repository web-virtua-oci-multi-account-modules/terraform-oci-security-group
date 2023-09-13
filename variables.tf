variable "compartment_id" {
  description = "Compartment ID"
  type        = string
}

variable "name" {
  description = "Security group name"
  type        = string
}

variable "vcn_id" {
  description = "VCN ID"
  type        = string
}

variable "compartment_name" {
  description = "Compartment name"
  type        = string
  default     = "null"
}

variable "type" {
  description = "If the security group is type of ingress, can be INGRESS or EGRESS"
  type        = string
  default     = "INGRESS"
}

variable "is_stateless" {
  description = "If true will be stateless"
  type        = bool
  default     = false
}

variable "allow_cidr_blocks" {
  description = "Allow cidir blocks, if defined this values will be used in all cidr block for each rules"
  type        = list(string)
  default     = []
}

variable "use_tags_default" {
  description = "If true will be use the tags default to resources"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to security group"
  type        = map(any)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags to security group"
  type        = map(any)
  default     = null
}

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
  default = []
}

variable "protocols" {
  description = "Available protocols, can be used the default protocols or customize, the values by default are all, icmp, ipv4, tcp, udp, ipv6 and icmpv6. Doc: others protocols http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml"
  type = map(any)
  default = null
}

variable "default_protocols" {
  description = "Available protocols, can be used the default protocols or customize, the values by default are all, icmp, ipv4, tcp, udp, ipv6 and icmpv6. Doc: others protocols http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml"
  type = object({
    all    = string
    icmp   = number
    ipv4   = number
    tcp    = number
    udp    = number
    ipv6   = number
    icmpv6 = number
    rdp    = number
  })
  default = {
    all    = "all"
    icmp   = 1
    ipv4   = 4
    tcp    = 6
    udp    = 17
    ipv6   = 41
    icmpv6 = 58
    rdp    = 27
  }
}
