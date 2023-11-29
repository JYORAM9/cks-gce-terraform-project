terraform {
  cloud {
    organization = "jyo"

    workspaces {
      name = "flask-gce-terraform-project"
    }
  }
}