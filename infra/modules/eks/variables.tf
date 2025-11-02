variable "project_name" {
  description = "Prefix for resource names"
  type        = string
}

variable "region" {
  description = "Region where the EKS cluster will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the cluster"
  type        = list(string)
}
variable "vpc_id" {
  description = "VPC ID for EKS cluster"
  type        = string
}
