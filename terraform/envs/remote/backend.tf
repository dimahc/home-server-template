# Remote (OVH/cloud) backend – swap to S3/TFC when ready.
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}
