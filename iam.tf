# IAM Role
resource "aws_iam_role" "wireguard" {
  name = "wireguard-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "wireguard" {
  name = "wireguard-profile"
  role = aws_iam_role.wireguard.name
}

# IAM Policy allowing EC2 instance to update the Route 53 A Record
resource "aws_iam_role_policy" "wireguard-r53-access" {
  name = "wireguard-r53-access-policy"
  role = aws_iam_role.wireguard.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "route53:ChangeResourceRecordSets",
                "route53:ListResourceRecordSets"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/${var.hosted_zone_id}"
            ],
            "Effect": "Allow"
        }
    ]
}
EOF
}