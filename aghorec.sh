#!/bin/bash
# -----------------------------------------------------------------------------
# Aghorec - Linux Server Setup & Hardening Framework
# Developer: Hrushabh
# Version: v1.0.0 Secure Build
# -----------------------------------------------------------------------------

# Safety Settings
set -e
trap 'cleanup' EXIT

# Global Variables
LOG_FILE="/var/log/aghorec.log"
SCAN_REPORT="/var/log/aghorec-scan-report.txt"
MONITOR_LOG="/var/log/security-monitor.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Utility Functions
# -----------------------------------------------------------------------------

cleanup() {
    set +e
}

log() {
    local message="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${include_color}${message}${NC}"
    echo "[$timestamp] $message" | sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE"
}

info() {
    include_color="${BLUE}"
    log "[INFO] $1"
}

success() {
    include_color="${GREEN}"
    log "[SUCCESS] $1"
}

warn() {
    include_color="${YELLOW}"
    log "[WARNING] $1"
}

error() {
    include_color="${RED}"
    log "[ERROR] $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[ERROR] This script must be run as root.${NC}"
        exit 1
    fi
}

confirm() {
    local prompt="$1"
    read -p "$prompt [y/N]: " choice
    case "$choice" in 
        y|Y ) return 0 ;;
        * ) return 1 ;;
    esac
}

banner() {
    clear
    echo -e "${CYAN}"
    echo "    _       _                       "
    echo "   / \   __| |__   ___  _ __ ___  ___ "
    echo "  / _ \ / _\` |_ \ / _ \| '__/ _ \/ __|"
    echo " / ___ \ (_| | | | (_) | | |  __/ (__ "
    echo "/_/   \_\__,_|_| |_|\___/|_|  \___|\___|"
    echo -e "${YELLOW}   v1.0.0 Secure Build | Developer: Hrushabh${NC}"
    echo "----------------------------------------"
}

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$NAME
        OS_VERSION=$VERSION_ID
        case $ID in
            ubuntu|debian)
                PKG_MANAGER="apt-get"
                PKG_UPDATE="$PKG_MANAGER update -y"
                PKG_INSTALL="$PKG_MANAGER install -y"
                PKG_APACHE="apache2"
                PKG_NGINX="nginx"
                PKG_CRON="cron"
                PKG_UFW="ufw"
                PKG_CERTBOT="certbot"
                PKG_CERTBOT_NGINX="python3-certbot-nginx"
                PKG_CERTBOT_APACHE="python3-certbot-apache"
                ;;
            centos|rhel|fedora|almalinux|rocky)
                PKG_MANAGER="yum"
                if command -v dnf >/dev/null 2>&1; then
                    PKG_MANAGER="dnf"
                fi
                PKG_UPDATE="$PKG_MANAGER makecache"
                PKG_INSTALL="$PKG_MANAGER install -y"
                PKG_APACHE="httpd"
                PKG_NGINX="nginx"
                PKG_CRON="cronie"
                PKG_UFW="ufw" # EPEL might be needed, but we assume std repos or manual
                PKG_CERTBOT="certbot"
                PKG_CERTBOT_NGINX="python3-certbot-nginx"
                PKG_CERTBOT_APACHE="python3-certbot-apache"
                ;;
            *)
                error "Unsupported OS detected: $ID"
                exit 1
                ;;
        esac
    else
        error "Cannot detect OS. /etc/os-release not found."
        exit 1
    fi
}

check_cmd() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

install_if_missing() {
    local package="$1"
    local check_cmd_name="$2"
    
    if [ -z "$check_cmd_name" ]; then check_cmd_name="$package"; fi

    if check_cmd "$check_cmd_name"; then
        info "Package '$package' is already installed."
    else
        info "Installing '$package'..."
        $PKG_INSTALL "$package" >> "$LOG_FILE" 2>&1
        if [ $? -eq 0 ]; then
            success "Installed '$package'."
        else
            error "Failed to install '$package'. Check logs."
            return 1
        fi
    fi
}

# -----------------------------------------------------------------------------
# Modules
# -----------------------------------------------------------------------------

setup_base() {
    info "Starting Base Server Preparation..."
    install_if_missing "curl"
    install_if_missing "git"
    install_if_missing "wget"
    install_if_missing "unzip"
    
    if ! check_cmd "vim" && ! check_cmd "nano"; then
        install_if_missing "nano"
    fi

    if [[ "$PKG_MANAGER" == "apt-get" ]]; then
        install_if_missing "software-properties-common"
    fi
    install_if_missing "$PKG_CRON" "crontab"
    success "Base preparation complete."
}

setup_web() {
    info "Starting Web Server Setup..."
    if check_cmd "nginx"; then
        info "Nginx is already installed."
        systemctl enable nginx --now >> "$LOG_FILE" 2>&1
    elif check_cmd "apache2" || check_cmd "httpd"; then
        info "Apache is already installed."
        local svc="apache2"
        [ -n "$PKG_APACHE" ] && svc="$PKG_APACHE"
        systemctl enable $svc --now >> "$LOG_FILE" 2>&1
    else
        echo -e "${YELLOW}No web server detected.${NC}"
        echo "1) Install Nginx"
        echo "2) Install Apache"
        echo "3) Skip"
        read -p "Select option: " web_choice
        case $web_choice in
            1)
                if confirm "Install Nginx?"; then
                    install_if_missing "$PKG_NGINX" "nginx"
                    systemctl enable nginx --now >> "$LOG_FILE" 2>&1
                    success "Nginx installed and started."
                fi
                ;;
            2)
                if confirm "Install Apache?"; then
                    install_if_missing "$PKG_APACHE" "apache2"
                    local svc="$PKG_APACHE"
                    systemctl enable $svc --now >> "$LOG_FILE" 2>&1
                    success "Apache installed and started."
                fi
                ;;
            *) info "Skipping web server." ;;
        esac
    fi
}

setup_ssl() {
    info "Starting SSL Setup..."
    install_if_missing "$PKG_CERTBOT" "certbot"
    
    local web_server=""
    if systemctl is-active --quiet nginx; then
        web_server="nginx"
    elif systemctl is-active --quiet apache2 || systemctl is-active --quiet httpd; then
        web_server="apache"
    fi
    
    if [ -z "$web_server" ]; then
        warn "No active web server found. Cannot configure SSL automatically."
        return
    fi
    
    info "Detected active web server: $web_server"
    
    # Install plugin
    if [ "$web_server" == "nginx" ]; then
        install_if_missing "$PKG_CERTBOT_NGINX"
    else
        install_if_missing "$PKG_CERTBOT_APACHE"
    fi
    
    read -p "Enter domain name (e.g., example.com): " domain_name
    [ -z "$domain_name" ] && { error "No domain provided."; return; }
    
    # DNS Check
    info "Verifying DNS for $domain_name..."
    if command -v host >/dev/null 2>&1; then
        if ! host "$domain_name" >/dev/null 2>&1; then
            warn "DNS lookup failed for $domain_name. Let's Encrypt validation may fail."
            if ! confirm "Continue anyway?"; then return; fi
        fi
    fi
    
    if confirm "Run Certbot for $domain_name?"; then
        certbot --"$web_server" -d "$domain_name"
        success "Certbot finished. Check output above."
    fi
}

setup_firewall() {
    info "Starting Firewall Hardening..."
    install_if_missing "$PKG_UFW" "ufw"
    
    # Detect SSH Port
    local ssh_port=22
    if [ -f /etc/ssh/sshd_config ]; then
        local config_port=$(grep "^Port" /etc/ssh/sshd_config | awk '{print $2}' | head -n 1)
        if [ -n "$config_port" ]; then
            ssh_port="$config_port"
        fi
    fi
    info "Detected SSH Port: $ssh_port"
    
    # Whitelist current IP
    local current_ip=$(echo $SSH_CLIENT | awk '{print $1}')
    if [ -n "$current_ip" ]; then
        info "Whitelisting current SSH session IP: $current_ip"
        ufw allow from "$current_ip" to any port "$ssh_port" >> "$LOG_FILE" 2>&1
    fi
    
    ufw allow "$ssh_port"/tcp >> "$LOG_FILE" 2>&1
    ufw limit "$ssh_port"/tcp >> "$LOG_FILE" 2>&1
    
    # Web ports
    ufw allow 80/tcp >> "$LOG_FILE" 2>&1
    ufw allow 443/tcp >> "$LOG_FILE" 2>&1
    
    if confirm "Enable UFW Firewall? (This risks locking you out if SSH is not allowed correctly)"; then
        echo "y" | ufw enable >> "$LOG_FILE" 2>&1
        success "Firewall enabled."
        ufw status verbose
    else
        warn "Firewall NOT enabled."
    fi
}

setup_fail2ban() {
    info "Setting up Fail2ban..."
    install_if_missing "fail2ban"
    
    if [ ! -f /etc/fail2ban/jail.local ]; then
        info "Creating jail.local..."
        # Safe default config
        cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5

[sshd]
enabled = true
EOF
        success "Created jail.local"
    else
        info "jail.local already exists. Skipping creation."
    fi
    
    systemctl restart fail2ban >> "$LOG_FILE" 2>&1
    systemctl enable fail2ban >> "$LOG_FILE" 2>&1
    success "Fail2ban service restarted."
}

setup_logging() {
    info "Setting up Log Monitoring..."
    install_if_missing "rsyslog"
    # logwatch often prompts for config, let's try non-interactive if possible or skip if complex
    # install_if_missing "logwatch" 
    
    info "Creating simple security monitor script..."
    cat > /usr/local/bin/aghorec-monitor.sh <<SCRIPT
#!/bin/bash
tail -n 100 /var/log/auth.log | grep -E "Failed password|Invalid user|sudo" > $MONITOR_LOG
SCRIPT
    chmod +x /usr/local/bin/aghorec-monitor.sh
    
    # Add to cron if not exists
    (crontab -l 2>/dev/null; echo "*/10 * * * * /usr/local/bin/aghorec-monitor.sh") | sort -u | crontab -
    success "Log monitoring setup. Check $MONITOR_LOG"
}

audit_security() {
    info "Starting Vulnerability Audit (Safe Mode)..."
    
    install_if_missing "clamav"
    # install_if_missing "rkhunter" # logic for rkhunter often requires interaction for databases
    # install_if_missing "lynis"
    
    # We will check if they exist, if not install. 
    # Lynis is usually easy.
    if ! check_cmd "lynis"; then
        if [[ "$PKG_MANAGER" == "apt-get" ]]; then
            # Lynis might need repo
             install_if_missing "lynis" || warn "Lynis install failed."
        else
             install_if_missing "lynis" || warn "Lynis install failed."
        fi
    fi
    
    echo "--- Scan Report ---" > "$SCAN_REPORT"
    
    if check_cmd "lynis"; then
        info "Running Lynis system audit..."
        lynis audit system --quick >> "$SCAN_REPORT" 2>&1
        success "Lynis scan complete."
    fi
    
    if check_cmd "clamscan"; then
        info "Running ClamAV quick home scan..."
        # clamscan -r /home --infected --no-summary >> "$SCAN_REPORT" 2>&1 &
        info "ClamAV scan skipped in this demo to save time (long running)."
    fi

    success "Audit complete. Report saved to $SCAN_REPORT"
}

show_menu() {
    banner
    echo "1) Full Server Setup (All Steps)"
    echo "2) Base Dependencies Only"
    echo "3) Web Server Setup"
    echo "4) SSL Setup"
    echo "5) Firewall Hardening"
    echo "6) Fail2ban Setup"
    echo "7) Security Scan"
    echo "8) Setup Logging"
    echo "9) Exit"
    echo "----------------------------------------"
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

check_root
detect_os

while true; do
    show_menu
    read -p "Select an option [1-9]: " choice
    
    case $choice in
        1)
            setup_base
            setup_web
            setup_ssl
            setup_firewall
            setup_fail2ban
            setup_logging
            audit_security
            ;;
        2) setup_base ;;
        3) setup_web ;;
        4) setup_ssl ;;
        5) setup_firewall ;;
        6) setup_fail2ban ;;
        7) audit_security ;;
        8) setup_logging ;;
        9) 
            echo -e "${GREEN}Exiting. Stay secure!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            ;;
    esac
    
    echo
    read -p "Press Enter to return to menu..." dummy
done
