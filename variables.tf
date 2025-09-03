variable "project_name" {
  type        = string
  description = "Short name for tagging and bucket prefix"
}


variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "ap-southeast-2"
}


variable "bucket_force_destroy" {
  type        = bool
  description = "Allow Terraform to delete bucket with objects (lab only)"
  default     = false
}


variable "ec2_enable" {
  type        = bool
  description = "Create EC2 + IAM role (stretch goal)"
  default     = false
}


variable "allowed_ssh_cidr" {
  description = "Public IPv4 /32 CIDR for SSH access"
  type        = string
}