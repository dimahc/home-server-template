# Contributing Guidelines

## Development Workflow

1. **Branch naming**: `feature/`, `fix/`, `docs/` prefixes
2. **Commits**: Use [Conventional Commits](https://www.conventionalcommits.org/) format
3. **Testing**: Run lint checks before pushing:

   ```bash
   # Ansible
   ansible-lint ansible/

   # Terraform
   terraform fmt -check -recursive terraform/
   terraform validate
   ```

## Pull Requests

- Keep changes focused and atomic
- Update relevant documentation in `docs/` and role READMEs
- Add/update variables in `.tfvars.example` or `group_vars/`
- Test in sandbox environment first

## Code Standards

### Ansible

- Use FQCN for modules (`ansible.builtin.*`, `community.docker.*`)
- Add `meta/main.yml` to all roles
- Include handlers for service restarts
- Set explicit `owner`/`group`/`mode` on files/directories

### Terraform

- Format with `terraform fmt`
- Add variable validation rules
- Document outputs with descriptions
- Use meaningful resource names

### Docker Compose

- No `version:` field (deprecated in Compose Spec)
- Use specific image tags (not `:latest` in production)
- Define healthchecks where applicable
- Document environment variables
