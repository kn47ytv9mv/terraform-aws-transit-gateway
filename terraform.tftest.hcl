mock_provider "aws" {
}

run "defaults_match_aws_own_defaults" {
  command = plan

  assert {
    condition     = aws_ec2_transit_gateway.resource.auto_accept_shared_attachments == "disable"
    error_message = "auto_accept_shared_attachments should default to 'disable', matching AWS's own default."
  }

  assert {
    condition     = aws_ec2_transit_gateway.resource.default_route_table_association == "enable"
    error_message = "default_route_table_association should default to 'enable', matching AWS's own default."
  }

  assert {
    condition     = aws_ec2_transit_gateway.resource.default_route_table_propagation == "enable"
    error_message = "default_route_table_propagation should default to 'enable', matching AWS's own default."
  }

  assert {
    condition     = aws_ec2_transit_gateway.resource.dns_support == "enable"
    error_message = "dns_support should default to 'enable', matching AWS's own default."
  }

  assert {
    condition     = aws_ec2_transit_gateway.resource.multicast_support == "disable"
    error_message = "multicast_support should default to 'disable', matching AWS's own default."
  }

  assert {
    condition     = aws_ec2_transit_gateway.resource.security_group_referencing_support == "disable"
    error_message = "security_group_referencing_support should default to 'disable', matching AWS's own default."
  }

  assert {
    condition     = aws_ec2_transit_gateway.resource.vpn_ecmp_support == "enable"
    error_message = "vpn_ecmp_support should default to 'enable', matching AWS's own default."
  }
}

run "every_bool_flips_the_aws_string_value" {
  command = plan

  variables {
    auto_accept_shared_attachments     = true
    default_route_table_association    = false
    default_route_table_propagation    = false
    dns_support                        = false
    multicast_support                  = true
    security_group_referencing_support = true
    vpn_ecmp_support                   = false
  }

  assert {
    condition = (
      aws_ec2_transit_gateway.resource.auto_accept_shared_attachments == "enable" &&
      aws_ec2_transit_gateway.resource.default_route_table_association == "disable" &&
      aws_ec2_transit_gateway.resource.default_route_table_propagation == "disable" &&
      aws_ec2_transit_gateway.resource.dns_support == "disable" &&
      aws_ec2_transit_gateway.resource.multicast_support == "enable" &&
      aws_ec2_transit_gateway.resource.security_group_referencing_support == "enable" &&
      aws_ec2_transit_gateway.resource.vpn_ecmp_support == "disable"
    )
    error_message = "Every bool variable should flip its corresponding AWS enable/disable string when set to the non-default value."
  }
}

run "description_and_asn_pass_through" {
  command = plan

  variables {
    description     = "Global hub, us-east-1"
    amazon_side_asn = 64513
  }

  assert {
    condition     = aws_ec2_transit_gateway.resource.description == "Global hub, us-east-1"
    error_message = "description should pass through unchanged."
  }

  assert {
    condition     = aws_ec2_transit_gateway.resource.amazon_side_asn == 64513
    error_message = "amazon_side_asn should pass through unchanged."
  }
}

run "readme_default_example" {
  command = plan
}

run "readme_custom_example" {
  command = plan

  variables {
    description                        = "Global hub, us-east-1"
    security_group_referencing_support = true
  }

  assert {
    condition     = aws_ec2_transit_gateway.resource.security_group_referencing_support == "enable"
    error_message = "The README's custom example should enable security group referencing."
  }
}
