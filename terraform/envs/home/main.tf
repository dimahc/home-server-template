locals {
  homelab_name = var.homelab_name
}

# Replace this placeholder with actual home infrastructure resources.
resource "local_file" "homelab_info" {
  content  = "Environment: home\nHomelab: ${local.homelab_name}\n"
  filename = pathexpand("${path.module}/.generated-home-info.txt")
}
