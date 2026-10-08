#!/bin/bash

# ============================================
# Jenkins Installation Script for RHEL/CentOS
# ============================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log functions
log_info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# Check root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root"
   exit 1
fi

# Variables
JENKINS_PORT=8080
#JAVA_VERSION="java-21-openjdk"
JAVA_VERSION="java-21-amazon-corretto-devel"

log_info "Starting Jenkins installation..."

# ============================================
# 1. System Update
# ============================================
log_info "Updating system packages..."
yum update -y

# ============================================
# 2. Install wget
# ============================================
yum install -y wget

# ============================================
# 2. Install Java
# ============================================
log_info "Installing Java $JAVA_VERSION..."
yum install -y $JAVA_VERSION

# Verify Java installation
java -version
log_info "Java installed successfully!"

# ============================================
# 3. Add Jenkins Repository
# ============================================
log_info "Adding Jenkins repository..."
wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo

# Import Jenkins GPG Key
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

log_info "Jenkins repository added!"

# ============================================
# 4. Install Jenkins
# ============================================
log_info "Installing Jenkins..."
yum install -y jenkins

log_info "Jenkins installed successfully!"

# ============================================
# 5. Start and Enable Jenkins
# ============================================
log_info "Starting Jenkins service..."
systemctl start jenkins
systemctl enable jenkins

# Check status
if systemctl is-active --quiet jenkins; then
    log_info "Jenkins is running!"
else
    log_error "Jenkins failed to start!"
    journalctl -u jenkins --no-pager | tail -20
    exit 1
fi

# ============================================
# 6. Configure Firewall
# ============================================
log_info "Configuring firewall..."
if systemctl is-active --quiet firewalld; then
    firewall-cmd --permanent --zone=public --add-port=${JENKINS_PORT}/tcp
    firewall-cmd --reload
    log_info "Firewall rule added for port ${JENKINS_PORT}!"
else
    log_warn "Firewalld is not running, skipping firewall configuration"
fi

# ============================================
# 7. Get Initial Admin Password
# ============================================
log_info "Waiting for Jenkins to initialize..."
sleep 15

ADMIN_PASSWORD_FILE="/var/lib/jenkins/secrets/initialAdminPassword"

if [ -f "$ADMIN_PASSWORD_FILE" ]; then
    ADMIN_PASSWORD=$(cat $ADMIN_PASSWORD_FILE)
    echo ""
    echo "============================================"
    echo "  Jenkins Installation Complete!"
    echo "============================================"
    echo ""
    log_info "Access Jenkins at: http://$(hostname -I | awk '{print $1}'):${JENKINS_PORT}"
    log_info "Initial Admin Password: ${ADMIN_PASSWORD}"
    echo ""
    echo "============================================"
else
    log_warn "Initial password file not found yet."
    log_info "Run: cat /var/lib/jenkins/secrets/initialAdminPassword"
fi

# ============================================
# 8. Summary
# ============================================
echo ""
log_info "=== Installation Summary ==="
log_info "Jenkins Version: $(jenkins --version 2>/dev/null || echo 'Check via web UI')"
log_info "Java Version: $(java -version 2>&1 | head -1)"
log_info "Service Status: $(systemctl is-active jenkins)"
log_info "URL: http://$(hostname -I | awk '{print $1}'):${JENKINS_PORT}"
log_info "Config Dir: /etc/sysconfig/jenkins"
log_info "Home Dir: /var/lib/jenkins"
log_info "Log File: /var/log/jenkins/jenkins.log"
echo ""

