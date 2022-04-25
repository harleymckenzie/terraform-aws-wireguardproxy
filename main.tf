locals {
  wg_nat_ports = join(",", flatten(var.wg_nat_ports))
}

# Wireguard Proxy Instance
resource "aws_instance" "wireguard" {
  ami                  = var.instance_ami
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.wireguard.name
  key_name             = var.keypair
  subnet_id            = var.subnet_id
  vpc_security_group_ids = [
    aws_security_group.vpn-access.id,
    aws_security_group.ssh-access.id,
    aws_security_group.nat-ports.id
  ]
  user_data = base64encode(data.template_file.userdata.rendered)

  source_dest_check           = false
  associate_public_ip_address = true

  tags = {
    "Name" = "wireguard"
  }
}

# User Data - Sourced from userdata.tpl
data "template_file" "userdata" {
  template = file("${path.module}/userdata.tpl")
  vars = {
    interface_cidr  = var.wg_interface_cidr
    listen_port     = var.wg_listen_port
    private_key     = var.wg_private_key
    nat_ports       = local.wg_nat_ports
    peer_public_key = var.peer_public_key
    peer_private_ip = var.peer_private_ip

    vpn_domain_name = var.vpn_domain_name
    hosted_zone_id  = var.hosted_zone_id
  }
}