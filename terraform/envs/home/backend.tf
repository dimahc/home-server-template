# Home environment state backend (default: local).
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}
