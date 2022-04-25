variable "instance_ami" {
  type        = string
  default     = "ami-0015a39e4b7c0966f"
  description = "AMI to use for the instance"
}

variable "vpc_id" {
  type        = string
  description = "VPC id of the VPC the WireGuard instance will be provisioned in"
}

variable "subnet_id" {
  type        = string
  description = "Subnet id used by the WireGuard instance"
}

variable "keypair" {
  type        = string
  description = "Key Pair name to be used for SSH access to the WireGuard server"
}

variable "permitted_ssh_ips" {
  type        = list(string)
  description = "List of CIDR ranges permitted to SSH to the WireGuard instance"
  default     = ["0.0.0.0/0"]
}

variable "hosted_zone_id" {
  type        = string
  description = "Route 53 Hosted Zone ID containing the domain name to be used for the VPN"
}

variable "vpn_domain_name" {
  type        = string
  description = "A Record to use for the WireGuard proxy"
}

variable "wg_interface_cidr" {
  type        = string
  default     = "10.6.0.1/32"
  description = "The CIDR address used for the WireGuard interface on the server"
}

variable "wg_listen_port" {
  type    = number
  default = 51820
}

variable "wg_private_key" {
  type        = string
  description = "Private key used for the WireGuard server"
  sensitive   = true
}

variable "wg_nat_ports" {
  type        = list(number)
  default     = [8080, 8123]
  description = "List of ports to be used for port forwarding"
}

variable "peer_public_ip" {
  type        = string
  description = "Public IP address used to permit inbound connections to WireGuard"
}

variable "peer_private_ip" {
  type        = string
  description = "Private IP of the peer WireGuard client used for traffic forwarding"
}

variable "peer_public_key" {
  type        = string
  description = "Peers public key for configuring the VPN connection"
  sensitive   = true
}
