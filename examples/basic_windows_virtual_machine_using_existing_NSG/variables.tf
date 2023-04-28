variable "location" {
  description = "Azure region in which instance will be hosted"
  type        = string
  default = "eastus"
}

variable "deploy_environment" {
  description = "Name of the workload's environnement"
  type        = string
  default = "dev"
}

variable "workload_name" {
  description = "Name of the workload_name"
  type        = string
  default = "vm-windows"
}

variable "org_name" {
  description = "Name of the organization"
  type        = string
  default = "anoa"
}