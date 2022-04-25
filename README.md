## Description

This Terraform module is used to create and configure a WireGuard reverse proxy server.

I created this module as a solution / personal project that would allow me access to home-assistant and other resources on my internal network, as I don't have access to the router and port forwarding is not an option.

**The module will:**

1. Create an Ubuntu based EC2 instance
2. Install WireGuard and generate the required configuration for NAT'ing
3. Update the A record used for the proxy on instance startup

**Note**: This has only been tested on Ubuntu 20.04 LTS x64, though should still work on other versions/architectures.

## Prerequisites
- A Hosted Zone in Route 53
- Public/private keys for your sever and peer
- A pre-existing VPC and keypair

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.wireguard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.wireguard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.wireguard-r53-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_instance.wireguard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.nat-ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ssh-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpn-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [template_file.userdata](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | Route 53 Hosted Zone ID containing the domain name to be used for the VPN | `string` | n/a | yes |
| <a name="input_instance_ami"></a> [instance\_ami](#input\_instance\_ami) | AMI to use for the instance | `string` | `"ami-0015a39e4b7c0966f"` | no |
| <a name="input_keypair"></a> [keypair](#input\_keypair) | Key Pair name to be used for SSH access to the WireGuard server | `string` | n/a | yes |
| <a name="input_peer_private_ip"></a> [peer\_private\_ip](#input\_peer\_private\_ip) | Private IP of the peer WireGuard client used for traffic forwarding | `string` | n/a | yes |
| <a name="input_peer_public_ip"></a> [peer\_public\_ip](#input\_peer\_public\_ip) | Public IP address used to permit inbound connections to WireGuard | `string` | n/a | yes |
| <a name="input_peer_public_key"></a> [peer\_public\_key](#input\_peer\_public\_key) | Peers public key for configuring the VPN connection | `string` | n/a | yes |
| <a name="input_permitted_ssh_ips"></a> [permitted\_ssh\_ips](#input\_permitted\_ssh\_ips) | List of CIDR ranges permitted to SSH to the WireGuard instance | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet id used by the WireGuard instance | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id of the VPC the WireGuard instance will be provisioned in | `string` | n/a | yes |
| <a name="input_vpn_domain_name"></a> [vpn\_domain\_name](#input\_vpn\_domain\_name) | A Record to use for the WireGuard proxy | `string` | n/a | yes |
| <a name="input_wg_interface_cidr"></a> [wg\_interface\_cidr](#input\_wg\_interface\_cidr) | The CIDR address used for the WireGuard interface on the server | `string` | `"10.6.0.1/32"` | no |
| <a name="input_wg_listen_port"></a> [wg\_listen\_port](#input\_wg\_listen\_port) | n/a | `number` | `51820` | no |
| <a name="input_wg_nat_ports"></a> [wg\_nat\_ports](#input\_wg\_nat\_ports) | List of ports to be used for port forwarding | `list(number)` | <pre>[<br>  8080,<br>  8123<br>]</pre> | no |
| <a name="input_wg_private_key"></a> [wg\_private\_key](#input\_wg\_private\_key) | Private key used for the WireGuard server | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
```hcl
  hosted_zone_id = "Z0123456789"
  vpn_domain_name = "proxy.example.com"
  
  vpc_id = "vpc-xxxxxxxxxxx"
  subnet_id = "subnet-xxxxxxxxxxx"

  keypair = "my-key-pair"
  wg_private_key = "abcdef0123456789"
  peer_public_key = "fedcba987654321"
  peer_public_ip = "203.147.201.32"
  peer_private_ip = "192.168.0.101"
```