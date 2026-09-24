#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "Starting deployment..."

# --------------------------------------------------
# 0. Add 2GB Swap Memory (Prevents t3.micro RAM Crashes)
# --------------------------------------------------
if [ ! -f /swapfile ]; then
  echo "Creating swap file..."
  fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# --------------------------------------------------
# 1. Base Packages & Keyring Setup
# --------------------------------------------------
echo "Updating system..."
apt-get update -y
apt-get install -y \
  fontconfig \
  openjdk-21-jre \
  wget \
  curl \
  ca-certificates \
  gnupg \
  software-properties-common \
  apt-transport-https \
  git \
  unzip \
  docker.io

# Install AWS CLI v2 via official bundle
echo "Installing AWS CLI v2..."
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install --update
rm -rf awscliv2.zip aws

mkdir -p /etc/apt/keyrings
mkdir -p /usr/share/keyrings

# --------------------------------------------------
# 2. Jenkins Repository & Key (.asc format)
# --------------------------------------------------
echo "Adding Jenkins repository..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key -o /etc/apt/keyrings/jenkins-keyring.asc
chmod 644 /etc/apt/keyrings/jenkins-keyring.asc

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# --------------------------------------------------
# 3. HashiCorp Repository (Terraform)
# --------------------------------------------------
echo "Adding HashiCorp repository..."
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
chmod 644 /usr/share/keyrings/hashicorp-archive-keyring.gpg

UBUNTU_CODENAME=$(lsb_release -cs)
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${UBUNTU_CODENAME} main" | tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

# --------------------------------------------------
# 4. Install Jenkins & Terraform
# --------------------------------------------------
echo "Installing Jenkins and Terraform..."
apt-get update -y
apt-get install -y jenkins terraform

# --------------------------------------------------
# 5. Install kubectl
# --------------------------------------------------
echo "Installing kubectl..."
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

# --------------------------------------------------
# 6. Enable Services & Set Group Permissions
# --------------------------------------------------
echo "Configuring services and permissions..."
systemctl enable --now docker

usermod -aG docker jenkins || true
usermod -aG docker ubuntu || true

systemctl enable --now jenkins

echo "Installation complete."
