variable "description" {
  default     = null
  description = "Description of the transit gateway."
}

variable "amazon_side_asn" {
  default     = null
  description = "Private ASN for the Amazon side of BGP sessions. If null, AWS defaults to 64512. Cannot be changed once an attachment has an active BGP session."
}

variable "auto_accept_shared_attachments" {
  default     = false
  description = "Whether attachments shared from other accounts (via Resource Access Manager) are accepted automatically, instead of requiring manual acceptance."
}

variable "default_route_table_association" {
  default     = true
  description = "Whether new attachments are automatically associated with the default association route table."
}

variable "default_route_table_propagation" {
  default     = true
  description = "Whether new attachments automatically propagate routes into the default propagation route table."
}

variable "dns_support" {
  default     = true
  description = "Whether DNS support is enabled for the transit gateway."
}

variable "multicast_support" {
  default     = false
  description = "Whether multicast support is enabled for the transit gateway."
}

variable "security_group_referencing_support" {
  default     = false
  description = "Whether attached VPCs' security groups can reference each other's security group IDs across the transit gateway. Must also be enabled on the individual VPC attachment to take effect."
}

variable "vpn_ecmp_support" {
  default     = true
  description = "Whether equal-cost multi-path routing is used across multiple VPN tunnels attached to the transit gateway."
}

variable "transit_gateway_cidr_blocks" {
  default     = null
  description = "CIDR blocks to associate directly with the transit gateway, for use as source addresses by Transit Gateway Connect peers."
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the transit gateway."
}
