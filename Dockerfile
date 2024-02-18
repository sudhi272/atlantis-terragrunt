# Use a minimal Alpine Linux base image
FROM alpine:latest

# Set ARGs for Terraform, Terragrunt, and Atlantis versions
ARG TERRAFORM_VERSION="1.6.6"
ARG TERRAGRUNT_VERSION="v0.54.12"
ARG ATLANTIS_VERSION="v0.18.1"

# Set the working directory to /app
WORKDIR /app

# Download and install Terraform
RUN wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    mv terraform /usr/bin/terraform

# Download and install Terragrunt
RUN wget "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" && \
    mv terragrunt_linux_amd64 /usr/bin/terragrunt && \
    chmod +x /usr/bin/terragrunt

# Download the Atlantis binary
RUN wget "https://github.com/runatlantis/atlantis/releases/download/${ATLANTIS_VERSION}/atlantis_linux_amd64.zip" && \
    unzip "atlantis_linux_amd64.zip" && \
    rm "atlantis_linux_amd64.zip" && \
    mv atlantis /usr/bin/atlantis

# Expose the default Atlantis port
EXPOSE 4141

#Create Config Dir
RUN mkdir -p /etc/atlantis

# Copy Server config
COPY server.yaml /etc/atlantis/server.yaml

# Copy optional atlantis.yaml
COPY atlantis-repo-config-backup.yaml /var/atlantis.yaml

# Command to run when the container starts
CMD ["atlantis", "server", "--config", "/etc/atlantis/server.yaml"]

