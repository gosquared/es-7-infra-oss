provider "aws" {
  profile = "default"
  region  = var.region

  default_tags {
    tags = {
      role = var.name
    }
  }
}

resource "aws_key_pair" "key" {
  key_name   = var.name
  public_key = file("./key.pub")
}

variable "region" {
  type = string
}
