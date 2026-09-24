# terraform-aws-transit-gateway

Terraform module for a Transit Gateway — a regional routing hub for
connecting many VPCs, VPNs, and Direct Connect gateways with transitive
reachability between them.

## Cost

Bills hourly per attachment, plus a per-gigabyte data processing
charge — the same cost shape as a NAT gateway. This module's transit
gateway starts with no attachments, so it carries no charge until
something attaches to it. See AWS's
[Transit Gateway pricing](https://aws.amazon.com/transit-gateway/pricing/)
page for current rates.

## Design

This module creates only the transit gateway — one regional hub, with
sensible defaults (DNS support and default route table
association/propagation enabled, matching AWS's own defaults). It does
not attach a VPC, create an additional route table, or peer with
another region's transit gateway — those are separate modules,
composed against this one by referencing its `id` output:

- Attach a VPC with `terraform-aws-vpc`'s existing `custom_routes`
  `transit_gateway_id` target, once that VPC's route table needs a route
  toward this hub.
- Cross-region reachability and per-attachment routing segmentation are
  separate modules in this family, composed against this one by ID.

`security_group_referencing_support` here is only half of what is needed
for security groups to reference each other across this hub — the
attaching VPC's own
[`terraform-aws-transit-gateway-vpc-attachment`](https://github.com/kn47ytv9mv/terraform-aws-transit-gateway-vpc-attachment)
needs the matching setting enabled too, and
[`terraform-aws-vpc-security-groups`](https://github.com/kn47ytv9mv/terraform-aws-vpc-security-groups)'s
own README has the full picture of where cross-VPC security group
references do and do not work.

## Usage

```hcl
module "transit_gateway" {
  source = "kn47ytv9mv/transit-gateway/aws"
}
```

Or directly from this repository:

```hcl
module "transit_gateway" {
  source = "github.com/kn47ytv9mv/terraform-aws-transit-gateway"

  description = "Global hub, us-east-1"

  security_group_referencing_support = true
}
```

## Examples

<details>
<summary>Centralized egress, shared across spoke VPCs</summary>

A dedicated "egress" VPC hosts the only NAT gateways in the network;
every other ("spoke") VPC sends its internet-bound traffic through the
hub to that egress VPC instead of paying for its own NAT gateway. This
is the same pattern a firewall or inspection appliance would sit behind,
if one is added later.

```hcl
module "transit_gateway" {
  source = "kn47ytv9mv/transit-gateway/aws"
}

module "vpc_egress" {
  source = "kn47ytv9mv/vpc/aws"

  vpc_cidr = "10.0.0.0/16"

  subnets = {
    public = {
      newbits = 4
      public  = true
    }
    tgw_attach = {
      newbits = 4
    }
  }
}

module "attachment_egress" {
  source = "kn47ytv9mv/transit-gateway-vpc-attachment/aws"

  transit_gateway_id = module.transit_gateway.id
  vpc_id             = module.vpc_egress.vpc_id
  subnet_ids         = module.vpc_egress.subnet_ids["tgw_attach"]
}

module "vpc_spoke" {
  source = "kn47ytv9mv/vpc/aws"

  vpc_cidr = "10.1.0.0/16"

  subnets = {
    private = {
      newbits = 4
      custom_routes = [{
        cidr_block         = "0.0.0.0/0"
        transit_gateway_id = module.transit_gateway.id
      }]
    }
  }

  nat_gateway_count = 0
}

module "attachment_spoke" {
  source = "kn47ytv9mv/transit-gateway-vpc-attachment/aws"

  transit_gateway_id = module.transit_gateway.id
  vpc_id             = module.vpc_spoke.vpc_id
  subnet_ids         = module.vpc_spoke.subnet_ids["private"]
}
```

The egress VPC's own private tier then needs a route back toward
`0.0.0.0/0` through its NAT gateway (the module's own default), and a
route for the spoke's CIDR (`10.1.0.0/16`) back through the transit
gateway — add that as a `custom_routes` entry on the egress VPC's public
tier, or its own private tier if the NAT sits there instead, matching
whichever tier actually forwards spoke traffic to the internet.

</details>

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.0 |
| aws | ~> 6.61 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| description | Description of the transit gateway. | `null` | no |
| amazon_side_asn | Private ASN for the Amazon side of BGP sessions. If null, AWS defaults to `64512`. Cannot be changed once an attachment has an active BGP session. | `null` | no |
| auto_accept_shared_attachments | Whether attachments shared from other accounts (via Resource Access Manager) are accepted automatically, instead of requiring manual acceptance. | `false` | no |
| default_route_table_association | Whether new attachments are automatically associated with the default association route table. | `true` | no |
| default_route_table_propagation | Whether new attachments automatically propagate routes into the default propagation route table. | `true` | no |
| dns_support | Whether DNS support is enabled for the transit gateway. | `true` | no |
| multicast_support | Whether multicast support is enabled for the transit gateway. | `false` | no |
| security_group_referencing_support | Whether attached VPCs' security groups can reference each other's security group IDs across the transit gateway. Must also be enabled on the individual VPC attachment to take effect. | `false` | no |
| vpn_ecmp_support | Whether equal-cost multi-path routing is used across multiple VPN tunnels attached to the transit gateway. | `true` | no |
| transit_gateway_cidr_blocks | CIDR blocks to associate directly with the transit gateway, for use as source addresses by Transit Gateway Connect peers. | `null` | no |
| tags | A map of tags to assign to the transit gateway. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The ID of the transit gateway. |
| arn | The ARN of the transit gateway. |
| owner_id | AWS account ID that owns the transit gateway. |
| association_default_route_table_id | The ID of the default association route table, if `default_route_table_association` is true. |
| propagation_default_route_table_id | The ID of the default propagation route table, if `default_route_table_propagation` is true. |

## License

MIT — see [LICENSE.md](LICENSE.md).
