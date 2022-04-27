resource "aws_instance" "node_2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key.key_name
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.id

  vpc_security_group_ids = [
    aws_security_group.security_group.id
  ]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 10
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = var.kms_key_arn
    iops                  = 3000
    throughput            = 125
    tags = {
      Name = join("-", [ var.name, "node-2" ])
      role = var.name
    }
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_type           = "gp3"
    volume_size           = 300
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = var.kms_key_arn
    # iops                  = 3000
    # throughput            = 125
    tags = {
      Name = join("-", [ var.name, "node-2" ])
      role = var.name
    }
  }

  tags = {
    Name = join("-", [ var.name, "node-2" ])
  }
}

output "node_2_ip" {
  value = aws_instance.node_2.public_ip
}

output "node_2_internal_ip" {
  value = aws_instance.node_2.private_ip
}

output "node_2_instance_id" {
  value = aws_instance.node_2.id
}
