variable "project_name" {
  type        = string
  description = "Name of the existing UbiOps project (created in the UI) to deploy into."
}

variable "instance_type_group_name" {
  type        = string
  description = "Instance type group for the version. Copy the exact name from the UbiOps UI (Project > Instance types)."
}

variable "environment" {
  type        = string
  description = "Base environment, using the full name the API returns (the short alias python3-13 causes a perpetual diff)."
  default     = "ubiops-ubuntu24-04-python3-13"
}

variable "version_name" {
  type    = string
  default = "v1"
}
