variable "homelab_name" {
  description = "Identifier for resources in the home environment."
  type        = string
  default     = "home"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.homelab_name))
    error_message = "The homelab_name must contain only lowercase letters, numbers, and hyphens."
  }
}
