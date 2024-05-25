terraform {
  backend "remote" {
    organization = "example-organization"
    workspaces {
      name = "example-workspace"
    }
  }
}

resource "null_resource" "example" {
  triggers = {
    value = "An example resource that does nothing!"
  }
}
