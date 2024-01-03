provider "aws" {
  region = var.aws_default_region
}

resource "aws_vpc" "main" {
  cidr_block = var.aws_vpc_cidr

  tags = {
    Name     = var.aws_resources_name
    Pipeline = var.aws_ec2_tags
  }
}