locals {
  homelab_name = var.homelab_name
}

# Placeholder resource for sandbox experiments.
resource "local_file" "sandbox_info" {
  content  = "Environment: sandbox\nName: ${local.homelab_name}\n"
  filename = pathexpand("${path.module}/.generated-sandbox-info.txt")
}
