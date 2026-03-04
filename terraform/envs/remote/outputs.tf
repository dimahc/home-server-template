output "homelab_name" {
  description = "Name propagated through the remote configuration."
  value       = local.homelab_name
}

output "public_records" {
  description = "Public DNS records managed by Terraform."
  value = {
    root = cloudflare_record.root.hostname
    www  = cloudflare_record.www.hostname
  }
}

output "security_note" {
  description = "Reminder about Tailscale-only services."
  value       = "dokploy, n8n, and ha are Tailscale-only. No public DNS records."
}

output "tunnel_records" {
  description = "DNS records routed through Cloudflare Tunnel."
  value = length(cloudflare_record.ma_alexa) > 0 ? {
    ma_alexa     = cloudflare_record.ma_alexa[0].hostname
    ma_streaming = cloudflare_record.ma_streaming[0].hostname
  } : {}
}
