#!/bin/bash -ex

echo "Installing WireGuard.."
sudo apt update && sudo apt install wireguard -y
echo "Installation complete"

echo "Generating WireGuard configuration"
sudo cat > /etc/wireguard/wg0.conf <<- EOF
[Interface]
Address = ${interface_cidr}
ListenPort = ${listen_port}
PrivateKey = ${private_key}
PostUp = sysctl -w -q net.ipv4.ip_forward=1
PostUp = iptables -A FORWARD -i %i -j ACCEPT;
PostUp = iptables -t nat -A PREROUTING -p tcp --match multiport --destination-ports ${nat_ports} -j DNAT --to-destination ${peer_private_ip}
PostUp = iptables -t nat -A POSTROUTING -j MASQUERADE
PostDown = sysctl -w -q net.ipv4.ip_forward=0
PostDown = iptables -D FORWARD -i %i -j ACCEPT
PostDown = iptables -t nat -D PREROUTING -p tcp --match multiport --destination-ports ${nat_ports} -j DNAT --to-destination ${peer_private_ip}
PostDown = iptables -t nat -D POSTROUTING -j MASQUERADE

[Peer]
PublicKey = ${peer_public_key}
AllowedIPs = ${peer_private_ip}/32
EOF

echo "Installing AWS CLI.."
sudo apt install awscli -y

echo "Updating Route 53 A Record.."
pub_ip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
file=/tmp/record.json
cat << EOF > $file
  {
    "Comment": "Update A record for proxy.hmckenzie.net",
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "${vpn_domain_name}",
          "Type": "A",
          "TTL": 300,
          "ResourceRecords": [
            {
              "Value": "$pub_ip"
            }
          ]
        }
      }
    ]
  }
EOF
aws route53 change-resource-record-sets --hosted-zone-id ${hosted_zone_id} --change-batch file:///$file

echo "Starting WireGuard.."
sudo wg-quick up wg0
sudo systemctl enable wg-quick@wg0
echo "WireGuard launched"