resource "aws_iam_instance_profile" "instance_profile" {
  name = join("-", [var.name, "nodes"])
  role = aws_iam_role.role.id
}

output "instance_profile_id" {
  value = aws_iam_instance_profile.instance_profile.unique_id
}

resource "aws_iam_role" "role" {
  name = join("-", [var.name, "nodes"])

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })

  # es snapshots
  inline_policy {
    name = "s3-access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket}",
          "arn:aws:s3:::${var.bucket}/*"
        ]
      }]
    })
  }
}

variable "bucket" {
  type = string
}
