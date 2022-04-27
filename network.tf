resource "aws_security_group" "security_group" {
  name        = var.name
  description = var.name
  vpc_id      = var.vpc_id

  lifecycle {
    ignore_changes = [ ingress ]
  }

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description      = "ssh"
    from_port        = 22
    protocol         = "tcp"
    to_port          = 22
    self             = false
  }

  ingress {
    description      = "es nodes"
    from_port        = 9200
    protocol         = "tcp"
    to_port          = 9200
    self             = true
  }

  ingress {
    description      = "es nodes"
    from_port        = 9300
    protocol         = "tcp"
    to_port          = 9300
    self             = true
  }

  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description     = "all"
    from_port       = 0
    protocol        = "-1"
    to_port         = 0
    self            = false
    ipv6_cidr_blocks = [ "::/0" ]
  }
}

# example rule for authorising an additional
# security group to your es nodes:
#
# resource "aws_security_group_rule" "transfer" {
#   type                     = "ingress"
#   security_group_id        = "sg-12345678"
#   source_security_group_id = aws_security_group.security_group.id
#   protocol                 = "tcp"
#   from_port                = 9200
#   to_port                  = 9200
#   description              = "example-sg access to es nodes"
# }

output "security_group" {
  value = aws_security_group.security_group.id
}
