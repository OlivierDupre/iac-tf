variable "aws_ami_id" {
  description = "The AMI ID of the image being deployed."
  type        = string
}

variable "aws_instance_type" {
  description = "The instance type of the VM being deployed."
  type        = string
  default     = "t2.micro"
}

variable "aws_vpc_cidr" {
  description = "The CIDR of the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_public_subnet_cidr" {
  description = "The CIDR of the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "aws_private_subnet_cidr" {
  description = "The CIDR of the private subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "aws_default_region" {
  description = "Default region where resources are deployed."
  type        = string
  default     = "eu-west-3"
}

variable "aws_ec2_tags" {
  description = "Default tags for the resources."
  type        = string
  default     = "demo"
}

variable "aws_resources_name" {
  description = "Default name for the resources."
  type        = string
  default     = "demo"
}