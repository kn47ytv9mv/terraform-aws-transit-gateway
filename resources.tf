resource "aws_ec2_transit_gateway" "resource" {
  description     = var.description
  amazon_side_asn = var.amazon_side_asn

  auto_accept_shared_attachments     = var.auto_accept_shared_attachments ? "enable" : "disable"
  default_route_table_association    = var.default_route_table_association ? "enable" : "disable"
  default_route_table_propagation    = var.default_route_table_propagation ? "enable" : "disable"
  dns_support                        = var.dns_support ? "enable" : "disable"
  multicast_support                  = var.multicast_support ? "enable" : "disable"
  security_group_referencing_support = var.security_group_referencing_support ? "enable" : "disable"
  vpn_ecmp_support                   = var.vpn_ecmp_support ? "enable" : "disable"

  transit_gateway_cidr_blocks = var.transit_gateway_cidr_blocks

  tags = merge(var.tags, { name = "tgw" })
}

output "id" {
  description = "The ID of the transit gateway."
  value       = aws_ec2_transit_gateway.resource.id
}

output "arn" {
  description = "The ARN of the transit gateway."
  value       = aws_ec2_transit_gateway.resource.arn
}

output "owner_id" {
  description = "AWS account ID that owns the transit gateway."
  value       = aws_ec2_transit_gateway.resource.owner_id
}

output "association_default_route_table_id" {
  description = "The ID of the default association route table, if default_route_table_association is true."
  value       = aws_ec2_transit_gateway.resource.association_default_route_table_id
}

output "propagation_default_route_table_id" {
  description = "The ID of the default propagation route table, if default_route_table_propagation is true."
  value       = aws_ec2_transit_gateway.resource.propagation_default_route_table_id
}
