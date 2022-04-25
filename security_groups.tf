# Allow SSH access to the EC2 instance
resource "aws_security_group" "ssh-access" {
  name        = "wireguard-ssh-access"
  description = "Allow SSH from everywhere"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow SSH Access from the world"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.permitted_ssh_ips
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name" = "wireguard-allow-ssh"
  }
}

# Restrict WireGuard access to a single peer IP
resource "aws_security_group" "vpn-access" {
  name        = "wireguard-vpn-access"
  description = "Allow WireGuard connnections from home"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow WireGuard connnections from home"
    from_port   = var.wg_listen_port
    to_port     = var.wg_listen_port
    protocol    = "tcp"
    cidr_blocks = ["${var.peer_public_ip}/32"]
  }

  ingress {
    description = "Allow WireGuard connnections from home"
    from_port   = var.wg_listen_port
    to_port     = var.wg_listen_port
    protocol    = "udp"
    cidr_blocks = ["${var.peer_public_ip}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name" = "wireguard-vpn-access"
  }
}

resource "aws_security_group" "nat-ports" {
  name        = "wireguard-nat-ports"
  description = "Permitted inbound ports used for forwarding"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.wg_nat_ports
    content {
      description = "Ingress rule ${ingress.key}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    "Name" = "wireguard-nat"
  }
}