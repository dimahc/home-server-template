locals {
  homelab_name = var.homelab_name
}

# ══════════════════════════════════════════════════════════════
#  Cloudflare DNS — dimahc.dev
#
#  Only the portfolio root domain is publicly accessible.
#  All admin services (dokploy, n8n, ha) are accessed via
#  Tailscale mesh VPN — no public DNS records needed.
# ══════════════════════════════════════════════════════════════

data "cloudflare_zone" "main" {
  zone_id = var.cloudflare_zone_id
}

# ── Public records ──

# Root domain → VPS (portfolio / public website)
resource "cloudflare_record" "root" {
  zone_id         = var.cloudflare_zone_id
  name            = "@"
  content         = var.vps_ipv4
  type            = "A"
  proxied         = true
  ttl             = 1 # Auto (Cloudflare proxied)
  comment         = "Public portfolio site"
  allow_overwrite = true
}

# www → redirect to root
resource "cloudflare_record" "www" {
  zone_id         = var.cloudflare_zone_id
  name            = "www"
  content         = var.vps_ipv4
  type            = "A"
  proxied         = true
  ttl             = 1
  comment         = "www redirect to root"
  allow_overwrite = true
}

# ── REMOVED (migrated to Tailscale) ──
#
# The following DNS records have been intentionally removed.
# These services are now accessed exclusively via Tailscale mesh VPN.
#
# PREVIOUSLY:
#   dokploy.dimahc.dev → A → <VPS_IP> (proxied)
#   n8n.dimahc.dev     → A → <VPS_IP> (proxied)
#   ha.dimahc.dev      → CNAME → homelab-tunnel (CF Tunnel)
#
# NOW:
#   dokploy → https://ovh-vps.TAILNET.ts.net/ (Tailscale Serve)
#   n8n     → https://ovh-vps.TAILNET.ts.net:5678/ (Tailscale IP)
#   n8n webhooks → https://ovh-vps.TAILNET.ts.net/webhook (Funnel)
#   ha      → http://homelab:8123 (Tailscale MagicDNS)
#
# To re-add a public record, create a cloudflare_record resource above.

# ── Homelab Cloudflare Tunnel records ──
# These subdomains route through the Cloudflare Tunnel running on the homeserver.
# Tunnel routes must also be configured in CF Zero Trust dashboard.

resource "cloudflare_record" "ma_alexa" {
  count           = var.cloudflare_tunnel_id != "" ? 1 : 0
  zone_id         = var.cloudflare_zone_id
  name            = "ma-alexa"
  content         = "${var.cloudflare_tunnel_id}.cfargotunnel.com"
  type            = "CNAME"
  proxied         = true
  ttl             = 1
  comment         = "Music Assistant Alexa Skill (via CF Tunnel)"
  allow_overwrite = true
}

resource "cloudflare_record" "ma_streaming" {
  count           = var.cloudflare_tunnel_id != "" ? 1 : 0
  zone_id         = var.cloudflare_zone_id
  name            = "ma"
  content         = "${var.cloudflare_tunnel_id}.cfargotunnel.com"
  type            = "CNAME"
  proxied         = true
  ttl             = 1
  comment         = "Music Assistant streaming (via CF Tunnel)"
  allow_overwrite = true
}

# ── Cloudflare Tunnel ingress routes ──
# Manages which hostnames route to which local services through the tunnel.
# This replaces manual configuration in the Zero Trust dashboard.

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "homelab" {
  count      = var.cloudflare_tunnel_id != "" && var.cloudflare_account_id != "" ? 1 : 0
  account_id = var.cloudflare_account_id
  tunnel_id  = var.cloudflare_tunnel_id

  config {
    ingress_rule {
      hostname = "ma-alexa.${var.domain}"
      service  = "http://localhost:5000"
    }
    ingress_rule {
      hostname = "ma.${var.domain}"
      service  = "http://localhost:8097"
    }
    # Catch-all rule (required) — returns 404 for unmatched hostnames
    ingress_rule {
      service = "http_status:404"
    }
  }
}
