#!/usr/bin/env bash

set -eoux pipefail

# Perform AWS Infra creation for Flask APP

terraform init
terraform plan -out deploy.tfplan --var "ecr_repo_url=$2" --var "region=$1"
terraform apply deploy.tfplan
