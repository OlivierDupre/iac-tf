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

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.aws_public_subnet_cidr

  tags = {
    Name = "Public Subnet"
  }
}
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.aws_private_subnet_cidr

  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_instance" "sandbox" {
  ami           = var.aws_ami_id
  instance_type = var.aws_instance_type

  subnet_id = aws_subnet.public_subnet.id

  tags = {
    Name     = var.aws_resources_name
    Pipeline = var.aws_ec2_tags
  }
}

# Create the bucket
resource "aws_s3_bucket" "demobucket" {
  bucket = "terraformdemobucket"
  acl = "private"
}

# Grant bucket access: public
resource "aws_s3_bucket_public_access_block" "publicaccess" {
  bucket = aws_s3_bucket.demobucket.id
  block_public_acls = false
  block_public_policy = false
}
