# My Project Notes

```yaml
# This workflow installs the latest version of Terraform CLI and configures the Terraform CLI configuration file
# with an API token for Terraform Cloud (app.terraform.io). On pull request events, this workflow will run
# `terraform init`, `terraform fmt`, and `terraform plan` (speculative plan via Terraform Cloud). On push events
# to the "main" branch, `terraform apply` will be executed.
#
# Documentation for `hashicorp/setup-terraform` is located here: https://github.com/hashicorp/setup-terraform
#
# To use this workflow, you will need to complete the following setup steps.
#
# 1. Create a `main.tf` file in the root of this repository with the `remote` backend and one or more resources defined.
#   Example `main.tf`:
#     # The configuration for the `remote` backend.
#     terraform {
#       backend "remote" {
#         # The name of your Terraform Cloud organization.
#         organization = "example-organization"
#
#         # The name of the Terraform Cloud workspace to store Terraform state files in.
#         workspaces {
#           name = "example-workspace"
#         }
#       }
#     }
#
#     # An example resource that does nothing.
#     resource "null_resource" "example" {
#       triggers = {
#         value = "A example resource that does nothing!"
#       }
#     }
#
#
# 2. Generate a Terraform Cloud user API token and store it as a GitHub secret (e.g. TF_API_TOKEN) on this repository.
#   Documentation:
#     - https://www.terraform.io/docs/cloud/users-teams-organizations/api-tokens.html
#     - https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets
#
# 3. Reference the GitHub secret in step using the `hashicorp/setup-terraform` GitHub Action.
#   Example:
#     - name: Setup Terraform
#       uses: hashicorp/setup-terraform@v1
#       with:
#         cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

name: 'Terraform and Docker CI/CD Pipeline'

on:
  push:
    branches: [ "main" ]
  pull_request:

permissions:
  contents: read

jobs:
  setup:
    name: 'Setup and Initialize'
    runs-on: ubuntu-latest

    steps:
      # Checkout the repository to the GitHub Actions runner
      - name: Checkout
        uses: actions/checkout@v4

      # Install the latest version of Terraform CLI and configure the Terraform CLI configuration file with a Terraform Cloud user API token
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
        with:
          cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

      # Initialize a new or existing Terraform working directory by creating initial files, loading any remote state, downloading modules, etc.
      - name: Terraform Init
        run: terraform init

      # Checks that all Terraform configuration files adhere to a canonical format
      - name: Terraform Format
        run: terraform fmt -check

      # Generates an execution plan for Terraform
      - name: Terraform Plan
        run: terraform plan -input=false

      # Apply the changes on push to main
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: terraform apply -auto-approve -input=false

  docker:
    name: 'Build and Push Docker Images'
    runs-on: ubuntu-latest
    needs: setup

    steps:
      # Checkout the repository to the GitHub Actions runner
      - name: Checkout
        uses: actions/checkout@v4

      # Set up Docker Buildx
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      # Log in to Docker Hub
      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      # Build and push Docker images
      - name: Build and Push Docker Images
        uses: docker/build-push-action@v3
        with:
          push: true
          tags: |
            myrepo/myimage1:latest
            myrepo/myimage2:latest
            myrepo/myimage3:latest

  ci_cd:
    name: 'CI/CD Pipeline'
    runs-on: ubuntu-latest
    needs: [setup, docker]

    steps:
      # Checkout the repository to the GitHub Actions runner
      - name: Checkout
        uses: actions/checkout@v4

      # Run tests or any CI/CD specific tasks here
      - name: Run Tests
        run: |
          echo "Running tests..."
          # Add commands to run tests
          echo "Tests completed."

      # Deploy the infrastructure or application
      - name: Deploy
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: |
          echo "Deploying application..."
          # Add deployment commands here
          echo "Deployment completed."
```

## Documentation and Lab Guide

### Overview

This workflow sets up and manages infrastructure using Terraform, customizes VMs using cloud-init, builds Docker images, and automates CI/CD pipelines using GitHub Actions.

### Prerequisites

1. **GitHub Repository:** Ensure you have a GitHub repository to store your code and workflow files.
2. **Terraform Cloud:** Create an account and obtain an API token.
3. **Docker Hub:** Create an account and obtain credentials.

### Steps

#### 1. Terraform Infrastructure

- **File:** `main.tf`
- **Description:** Configures remote backend and defines infrastructure resources.

```hcl
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
```

#### 2. cloud-init Configuration

- **File:** `cloud-init.yaml`
- **Description:** Automates VM setup including Docker installation.

```yaml
#cloud-config
packages:
  - docker.io

runcmd:
  - systemctl start docker
  - systemctl enable docker
  - usermod -aG docker ubuntu
```

#### 3. Docker Configuration

- **Files:** `Dockerfile1`, `Dockerfile2`, `Dockerfile3`
- **Description:** Defines the setup for three different Docker containers.

```dockerfile
# Dockerfile1
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y nginx
CMD ["nginx", "-g", "daemon off;"]
```

#### 4. CI/CD Pipeline

- **File:** `.github/workflows/ci-cd-pipeline.yml`
- **Description:** Automates building, testing, and deploying Docker images.

### Detailed Tutorial

1. **Terraform Setup:** Follow steps to create `main.tf` and configure Terraform Cloud backend.
2. **VM Customization:** Use `cloud-init.yaml` to automate Docker installation and other VM setups.
3. **Docker Image Build:** Create Dockerfiles for various services, build and push using GitHub Actions.
4. **CI/CD Pipeline:** Configure the GitHub Actions workflow to automate the testing and deployment process.

### Submission

- **Repository:** Submit the GitHub repository link containing all configurations and documentation.
- **README.md:** Include project details, setup instructions, and links to the lab guide and tutorial.

## Evaluation Criteria

### Technical Setup

- **Accuracy and Functionality:** Ensure the Terraform setup and cloud-init scripts work correctly.
- **Efficiency and Security:** Docker configurations should be optimized and secure.
- **CI/CD Pipeline:** Pipeline should be robust and reliable.
- **Innovative Solutions:** Implement and document innovative approaches and optimizations.

### Documentation Quality

- **Clarity and Thoroughness:** Documentation should be clear and complete.
- **Organization:** Ensure the tutorial and lab guide are well-organized and easy to follow.
- **Beginner-Friendly:** Provide instructions that are easy for beginners to understand.
- **Instructional Materials:** Include diagrams, flowcharts, and other helpful visuals.

---

This revised workflow and documentation provide a comprehensive setup and guide for implementing DevOps practices in an educational lab environment, ensuring both technical accuracy and educational value.
