# Home Assistant Dashboards

Dashboard configurations for Home Assistant, deployed via Ansible.

## Files

- `home.yaml` - Mushroom-based dashboard with custom cards

## Requirements

Install via HACS:
- [Mushroom Cards](https://github.com/piitaya/lovelace-mushroom)
- [Card Mod](https://github.com/thomasloven/lovelace-card-mod) (optional, for custom styles)
- [Auto Entities](https://github.com/thomasloven/lovelace-auto-entities) (optional)

## Installation

1. Copy dashboard YAML content
2. Go to **Settings → Dashboards → Add Dashboard**
3. Open the dashboard, click **⋮ → Edit → Raw configuration editor**
4. Paste and save

## Customization

Update entity IDs to match your devices. Find your entities at **Developer Tools → States**.

Common entities to customize:
- `weather.*` - Weather provider
- `media_player.*` - Audio devices
- `sensor.*_temperature` - Temperature sensors

## Deployment via Ansible

The `home-assistant` role copies these files to `{{ ha_config_dir }}/dashboards/` when `ha_dashboard_files` is set in your inventory.
