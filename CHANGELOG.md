# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Multi-environment structure (sandbox/home/remote)
- Ansible roles: common, traefik, homeassistant
- Traefik with ACME/TLS support
- Home Assistant deployment with optional Traefik routing
- Bootstrap script for Debian systems
- CI workflows for Ansible lint and Terraform validation
- Security best practices documentation
- Contributing guidelines

### Changed

- Updated Docker Compose files to current spec (removed version field)
- Updated community.docker to >=4.3.0
- Added community.general collection
- Improved .gitignore for secrets and generated files

### Security

- Added owner/group/mode to all file/directory tasks
- Configured acme.json with 0600 permissions
- Added ansible.cfg with secure defaults
