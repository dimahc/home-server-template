# Sandbox backend for experiments. Local state is fine here.
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}
