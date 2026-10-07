#!/bin/bash

# ============================================
# Docker & Docker Compose Installation Script
# For: RHEL / CentOS / Fedora / Rocky Linux
# ============================================

set -e  # Exit on any error

# ─── Colors ───────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ─── Check Root ───────────────────────────────
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ Please run as root or use sudo${NC}"
  exit 1
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Docker & Docker Compose Installer     ${NC}"
echo -e "${GREEN}========================================${NC}"

# ─── Step 1: Update System ────────────────────
echo -e "\n${YELLOW}[1/7] Updating system packages...${NC}"
dnf update -y

# ─── Step 2: Install Required Dependencies ────
echo -e "\n${YELLOW}[2/7] Installing dependencies...${NC}"
dnf install -y \
  dnf-plugins-core \
  curl \
  wget \
  git \
  ca-certificates \
  gnupg \
 # lsb-release

# ─── Step 3: Add Docker Repository ───────────
echo -e "\n${YELLOW}[3/7] Adding Docker repository...${NC}"
#dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# For CentOS, use:
# dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# ─── Step 4: Install Docker Engine ───────────
echo -e "\n${YELLOW}[4/7] Installing Docker Engine...${NC}"
dnf install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# ─── Step 5: Start & Enable Docker ───────────
echo -e "\n${YELLOW}[5/7] Starting Docker service...${NC}"
systemctl start docker
systemctl enable docker

# ─── Step 6: Add User to Docker Group ────────
echo -e "\n${YELLOW}[6/7] Adding user to docker group...${NC}"
if [ -n "$SUDO_USER" ]; then
  usermod -aG docker "$SUDO_USER"
  echo -e "${GREEN}✅ User '$SUDO_USER' added to docker group${NC}"
else
  echo -e "${YELLOW}⚠️  Run manually: usermod -aG docker YOUR_USERNAME${NC}"
fi

# ─── Step 7: Verify Installation ─────────────
echo -e "\n${YELLOW}[7/7] Verifying installation...${NC}"
docker --version
docker compose version

# ─── Test Docker ──────────────────────────────
echo -e "\n${YELLOW}Testing Docker with hello-world...${NC}"
docker run hello-world

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ Installation Complete!              ${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${YELLOW}⚠️  Log out and back in for group changes to take effect${NC}"

