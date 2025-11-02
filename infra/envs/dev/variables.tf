variable "primary_region" {
  description = "Primary AWS region for EKS"
  type        = string
}

variable "secondary_region" {
  description = "Secondary AWS region for EKS"
  type        = string
}

variable "project_name" {
  description = "Name prefix for resources"
  type        = string
}
