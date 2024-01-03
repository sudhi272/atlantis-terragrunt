#!/bin/bash

# Update the system and install required packages
sudo yum update -y
sudo yum install -y unzip

# Install Terraform
sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

#Install Terragrunt
TERRAGRUNT_VERSION="v0.54.12"
wget https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64
chmod u+x ./terragrunt_linux_amd64
sudo mv ./terragrunt_linux_amd64 /usr/bin/terragrunt

# Install Atlantis
ATLANTIS_VERSION="v0.18.1" 
wget https://github.com/runatlantis/atlantis/releases/download/${ATLANTIS_VERSION}/atlantis_linux_amd64.zip
unzip atlantis_linux_amd64.zip
sudo mv atlantis /usr/local/bin/
rm atlantis_linux_amd64.zip

# Create user for Atlantis
sudo useradd --system --home /etc/atlantis --shell /sbin/nologin atlantis

sudo mkdir -p /etc/atlantis

# Set permissions for Atlantis
sudo chown -R atlantis:atlantis /etc/atlantis

#Atlantis Server Config
sudo tee /etc/atlantis/server.yaml > /dev/null << EOL
# Public URL where Atlantis is accessible
atlantis_url: "ATLANTIS SERVER OR LB URL"

# Path to the repos.yaml file that contains repository-level configurations
repo_config: "/var/atlantis.yaml"

#Git user
gh-user: "YOUR-GITHUB-USERNAME"

#Git token
gh-token: "YOUR-GITHUB-ACCESS-TOKEN"

#16 Char random string for webhook secret
gh-webhook-secret: "YOUR-SECRET-STRING-FOR-WEBHOOK"

#Allowed Repos. Eg: github.com/example/terraform
repo-allowlist: "YOUR-GITHUB-REPO"

#Credentials for Terraform run
extra_env_vars:
  - name: AWS_ACCESS_KEY_ID
    value: "YOUR-AWS-ACCESSKEY"
  - name: AWS_SECRET_ACCESS_KEY
    value: "YOUR-AWS-SECRET-KEY"
EOL

#Atlantis repos.yaml config with Terragrunt commands
sudo tee /var/atlantis.yaml > /dev/null << EOL
# atlantis.yaml
repos:
- id: /.*/
  branch: /.*/
  workflow: default
  apply_requirements: [ mergeable]
  allowed_overrides: [apply_requirements, workflow, delete_source_branch_on_merge]
  allowed_workflows: []
  allow_custom_workflows: true
  repo_config_file: atlantis-repo-level.yaml
workflows:
  default:
    plan:
      steps:
      - run: echo "In Terragrunt Init and Plan"
      - run: terragrunt init
      - run: terragrunt plan
    apply:
      steps:
      - run: terragrunt apply -auto-approve
EOL


#Create a systemd service file for Atlantis
sudo tee /etc/systemd/system/atlantis.service > /dev/null << EOL
[Unit]
Description=Atlantis Service
After=network.target

[Service]
ExecStart=atlantis server --config /etc/atlantis/server.yaml
Restart=always
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=default.target
EOL

# Start and enable the Atlantis service
sudo systemctl daemon-reload
sudo systemctl start atlantis
sudo systemctl enable atlantis