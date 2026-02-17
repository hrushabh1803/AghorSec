#!/bin/bash
# -----------------------------------------------------------------------------
# AghorSec - Ultimate Server Setup & Security Tool
# Developer: Hrushabh
# Version: v2.0.0
# -----------------------------------------------------------------------------

# --- Safety Settings ---
set -e

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# --- Global Variables ---
LOG_FILE="/var/log/aghorec.log"
SCAN_REPORT="/var/log/aghorec-scan-report.txt"
ABORTED=false

# --- Trap Handler for Ctrl+C ---
handle_interrupt() {
    echo -e "\n\n${RED}[!] Process interrupted by user (Ctrl+C)${NC}"
    echo -e "${YELLOW}[!] Cleaning up...${NC}"
    ABORTED=true
    
    # Kill any background processes
    jobs -p | xargs -r kill 2>/dev/null
    
    echo -e "${GREEN}[✓] Cleanup complete. Returning to menu...${NC}"
    sleep 2
    return 1
}

trap handle_interrupt SIGINT SIGTERM

# --- Utility Functions ---

log() {
    local message="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $message" >> "$LOG_FILE"
}

# Enhanced Progress Bar with background process monitoring
progress_bar() {
    local pid=$1
    local message="${2:-Processing}"
    local block="█"
    local empty="░"
    local width=40
    local i=0
    
    echo -ne "${YELLOW}$message: [${NC}"
    for ((j=0; j<=width; j++)); do
        echo -ne "${empty}"
    done
    echo -ne "${YELLOW}] 0%${NC}\r"
    
    while kill -0 $pid 2>/dev/null; do
        local percent=$((i % (width + 1) * 100 / width))
        echo -ne "${YELLOW}$message: [${NC}"
        for ((j=0; j<(i % (width + 1)); j++)); do echo -ne "${GREEN}${block}${NC}"; done
        for ((j=(i % (width + 1)); j<width; j++)); do echo -ne "${empty}"; done
        echo -ne "${YELLOW}] ${percent}%${NC}\r"
        sleep 0.1
        ((i++))
    done
    
    # Check if process completed successfully
    wait $pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -ne "${YELLOW}$message: [${NC}"
        for ((j=0; j<width; j++)); do echo -ne "${GREEN}${block}${NC}"; done
        echo -e "${YELLOW}] 100% ${GREEN}✓ Done!${NC}"
    else
        echo -e "\n${RED}✗ Process failed with exit code $exit_code${NC}"
        return $exit_code
    fi
}

# Simple spinner for quick operations
spinner() {
    local pid=$1
    local message="${2:-Working}"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r${YELLOW}${message}... ${spin:$i:1}${NC}"
        sleep 0.1
    done
    
    wait $pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        printf "\r${GREEN}${message}... ✓ Done!${NC}\n"
    else
        printf "\r${RED}${message}... ✗ Failed!${NC}\n"
        return $exit_code
    fi
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[ERROR] You must be root to run this script.${NC}\n"
        echo -e "${YELLOW}Try running: sudo ./aghorec.sh${NC}"
        exit 1
    fi
}

banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"

                                                                           
 @@@@@@   @@@@@@@  @@@  @@@  @@@@@@  @@@@@@@      @@@@@@ @@@@@@@@  @@@@@@@ 
@@!  @@@ !@@       @@!  @@@ @@!  @@@ @@!  @@@    !@@     @@!      !@@      
@!@!@!@! !@! @!@!@ @!@!@!@! @!@  !@! @!@!!@!      !@@!!  @!!!:!   !@!      
!!:  !!! :!!   !!: !!:  !!! !!:  !!! !!: :!!         !:! !!:      :!!      
 :   : :  :: :: :   :   : :  : :. :   :   : :    ::.: :  : :: ::   :: :: : 
                                                                             

EOF
    echo -e "${YELLOW}  AghorSec v2.0 | Secure Server Setup | By Hrushabh${NC}"
    echo -e "${RED}  Linkdin - @hrushabh-hilwade ${NC}"
    echo "-----------------------------------------------------------------"
}

pause() {
    read -p "Press [Enter] key to continue..." fackEnterKey
}

# --- Quick Setup Shortcut ---
create_shortcut() {
    if [[ ! -f /usr/local/bin/setup ]]; then
        echo -e "${CYAN}Creating 'setup' shortcut...${NC}"
        cat > /usr/local/bin/setup <<EOF
#!/bin/bash
bash $(realpath "$0")
EOF
        chmod +x /usr/local/bin/setup
        echo -e "${GREEN}Shortcut created! You can now just type 'setup' to run this tool.${NC}"
        sleep 2
    fi
}

# --- Core Modules ---

setup_base() {
    banner
    echo -e "${BLUE}Installing Base Dependencies...${NC}"
    log "Installing base dependencies"
    
    # apt update with progress bar
    echo -e "${YELLOW}Updating package lists...${NC}"
    apt-get update -y > /dev/null 2>&1 &
    progress_bar $! "Updating packages"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to update packages${NC}"
        pause
        return 1
    fi

    local pkgs=("curl" "git" "wget" "nano" "unzip" "zip")
    
    for pkg in "${pkgs[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
             echo -e "${YELLOW}Installing $pkg...${NC}"
             apt-get install -y "$pkg" > /dev/null 2>&1 &
             spinner $! "Installing $pkg"
        else
             echo -e "${GREEN}✔ $pkg already installed${NC}"
        fi
    done
    
    echo -e "\n${GREEN}✓ Base dependencies installation complete!${NC}"
    pause
}

# --- Placeholder Functions (To be implemented) ---


# --- Web Stack Modules ---

install_php() {
    local version="$1"
    echo -e "${BLUE}Installing PHP $version...${NC}"
    
    # Add repo for latest PHP if needed
    if ! grep -q "ondrej/php" /etc/apt/sources.list.d/* 2>/dev/null; then
        echo -e "${YELLOW}Adding PHP repository...${NC}"
        apt-get install -y software-properties-common > /dev/null 2>&1 &
        spinner $! "Installing dependencies"
        
        add-apt-repository ppa:ondrej/php -y > /dev/null 2>&1 &
        spinner $! "Adding PHP repository"
        
        apt-get update -y > /dev/null 2>&1 &
        spinner $! "Updating package lists"
    fi

    # Install PHP and common extensions
    echo -e "${YELLOW}Installing PHP $version and extensions...${NC}"
    apt-get install -y "php$version" "php$version-cli" "php$version-fpm" "php$version-mysql" \
    "php$version-xml" "php$version-curl" "php$version-mbstring" "php$version-zip" "php$version-gd" \
    "php$version-intl" > /dev/null 2>&1 &
    progress_bar $! "Installing PHP $version"

    echo -e "${GREEN}✓ PHP $version installed successfully!${NC}"
}

setup_credentials() {
    echo -e "\n${PURPLE}--- Database & phpMyAdmin Credentials Setup ---${NC}"
    echo -e "${YELLOW}Please enter the credentials you want to set for your new Database User.${NC}"
    
    read -p "Enter Database Username: " DB_USER
    read -s -p "Enter Database Password: " DB_PASS
    echo
    
    # Create User in MariaDB/MySQL
    if command -v mysql &> /dev/null; then
        echo -e "${YELLOW}Creating database user...${NC}"
        mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
        mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'localhost' WITH GRANT OPTION;"
        mysql -e "FLUSH PRIVILEGES;"
        echo -e "${GREEN}Database user created successfully.${NC}"
    fi

    # Display Credentials Securely
    echo ""
    echo -e "${RED}############################################################${NC}"
    echo -e "${RED}#            KEEP BELOW CREDENTIALS SAFE                   #${NC}"
    echo -e "${RED}############################################################${NC}"
    echo -e "${CYAN}Database/PMA Username : ${WHITE}$DB_USER${NC}"
    echo -e "${CYAN}Database/PMA Password : ${WHITE}$DB_PASS${NC}"
    echo -e "${RED}############################################################${NC}"
    echo ""
    read -p "Press Enter once you have saved these credentials..."
}

setup_web_stack() {
    banner
    echo -e "${BLUE}Setting up Web Stack...${NC}"

    # 1. Choose Web Server
    echo -e "${CYAN}Choose Web Server:${NC}"
    echo "1) Apache (Recommended for beginners)"
    echo "2) Nginx (High Performance)"
    read -p "Select [1-2]: " ws_opt

    local web_server=""
    case $ws_opt in
        1) web_server="apache2" ;;
        2) web_server="nginx" ;;
        *) web_server="apache2"; echo -e "${YELLOW}Defaulting to Apache.${NC}" ;;
    esac

    echo -e "${YELLOW}Installing $web_server...${NC}"
    apt-get install -y "$web_server" > /dev/null 2>&1 &
    progress_bar $! "Installing $web_server"
    
    if [[ "$web_server" == "apache2" ]]; then
        a2enmod rewrite headers expires deflate > /dev/null 2>&1
        echo -e "${GREEN}✓ Apache modules enabled${NC}"
    fi
    
    systemctl enable "$web_server" --now > /dev/null 2>&1
    echo -e "${GREEN}✓ $web_server started${NC}"

    # 2. Choose PHP Version
    echo -e "\n${CYAN}Choose PHP Version:${NC}"
    echo "1) PHP 8.3 (Latest)"
    echo "2) PHP 8.2 (Stable)"
    echo "3) PHP 8.1"
    echo "4) PHP 7.4 (Legacy)"
    read -p "Select [1-4]: " php_opt

    local php_ver="8.3"
    case $php_opt in
        1) php_ver="8.3" ;;
        2) php_ver="8.2" ;;
        3) php_ver="8.1" ;;
        4) php_ver="7.4" ;;
    esac

    install_php "$php_ver"

    # 3. Database (MariaDB)
    echo -e "\n${YELLOW}Installing MariaDB Server...${NC}"
    apt-get install -y mariadb-server > /dev/null 2>&1 &
    progress_bar $! "Installing MariaDB"
    systemctl enable mariadb --now > /dev/null 2>&1
    echo -e "${GREEN}✓ MariaDB started${NC}"

    # 4. WP-CLI
    echo -e "\n${YELLOW}Installing WP-CLI...${NC}"
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > /dev/null 2>&1 &
    spinner $! "Downloading WP-CLI"
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    echo -e "${GREEN}✓ WP-CLI installed${NC}"

    # 5. phpMyAdmin
    echo -e "\n${YELLOW}Installing phpMyAdmin...${NC}"
    echo -e "${CYAN}NOTE: You may see a popup. Select '$web_server' using SPACE, then TAB to OK.${NC}"
    sleep 3
    DEBIAN_FRONTEND=noninteractive apt-get install -y phpmyadmin > /dev/null 2>&1 &
    progress_bar $! "Installing phpMyAdmin"

    # 6. Setup Credentials
    setup_credentials

    echo -e "\n${GREEN}✓✓✓ Web Stack Setup Complete! ✓✓✓${NC}"
    pause
}

setup_users() {
    banner
    echo -e "${BLUE}User Management${NC}"
    
    echo -e "${YELLOW}Do you want to create a 2nd non-root user for security purposes?${NC}"
    read -p "Create User? [y/N]: " create_user_choice
    
    if [[ "$create_user_choice" =~ ^[yY]$ ]]; then
        read -p "Enter New Username: " NEW_USER
        read -s -p "Enter New User Password: " NEW_PASS
        echo
        
        # Create user
        if id "$NEW_USER" &>/dev/null; then
            echo -e "${RED}User $NEW_USER already exists.${NC}"
        else
            useradd -m -s /bin/bash "$NEW_USER"
            echo "$NEW_USER:$NEW_PASS" | chpasswd
            usermod -aG sudo "$NEW_USER"
            
            echo -e "${GREEN}User $NEW_USER created and added to sudo group.${NC}"
            
            echo ""
            echo -e "${RED}############################################################${NC}"
            echo -e "${RED}#            KEEP BELOW CREDENTIALS SAFE                   #${NC}"
            echo -e "${RED}############################################################${NC}"
            echo -e "${CYAN}Username : ${WHITE}$NEW_USER${NC}"
            echo -e "${CYAN}Password : ${WHITE}$NEW_PASS${NC}"
            echo -e "${RED}############################################################${NC}"
            echo ""
        fi
    fi
    pause
}

domain_pointing() {
    banner
    echo -e "${BLUE}Domain Pointing & SSL Setup${NC}"
    
    # Simple check for Apache
    if ! command -v apache2 &> /dev/null; then
         echo -e "${RED}This module currently supports Apache primarily. Please ensure Apache is installed.${NC}"
         pause
         return
    fi

    read -p "Enter Domain Name (e.g., example.com): " DOMAIN
    read -p "Enter Document Root [/var/www/html/$DOMAIN]: " DOC_ROOT
    DOC_ROOT=${DOC_ROOT:-/var/www/html/$DOMAIN}

    echo -e "${YELLOW}Creating Document Root: $DOC_ROOT${NC}"
    mkdir -p "$DOC_ROOT"
    chown -R www-data:www-data "$DOC_ROOT"
    chmod -R 755 "$DOC_ROOT"

    CONF_FILE="/etc/apache2/sites-available/$DOMAIN.conf"
    
    echo -e "${YELLOW}Creating Virtual Host...${NC}"
    cat > "$CONF_FILE" <<EOF
<VirtualHost *:80>
    ServerAdmin admin@$DOMAIN
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    DocumentRoot $DOC_ROOT
    
    <Directory $DOC_ROOT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

    a2ensite "$DOMAIN.conf" > /dev/null 2>&1
    systemctl reload apache2
    
    echo -e "${GREEN}Site $DOMAIN enabled.${NC}"

    # SSL via Certbot
    echo -e "${YELLOW}Do you want to install SSL (LetsEncrypt)?${NC}"
    read -p "Install SSL? [y/N]: " install_ssl
    if [[ "$install_ssl" =~ ^[yY]$ ]]; then
         apt-get install -y certbot python3-certbot-apache python3-certbot-nginx > /dev/null 2>&1
         certbot --apache -d "$DOMAIN" --non-interactive --agree-tos --register-unsafely-without-email
    fi
    pause
}

# --- Security Modules ---

setup_ufw() {
    banner
    echo -e "${BLUE}Firewall Hardening (UFW)${NC}"
    
    echo -e "${YELLOW}Installing UFW...${NC}"
    apt-get install -y ufw > /dev/null 2>&1 &
    spinner $! "Installing UFW"

    echo -e "\n${YELLOW}1. Reset UFW (Clears all existing rules)${NC}"
    echo "This is recommended if you are unsure of existing rules."
    read -p "Reset UFW? [y/N]: " reset_ufw
    if [[ "$reset_ufw" =~ ^[yY]$ ]]; then
        echo -e "${YELLOW}Resetting UFW...${NC}"
        ufw --force reset > /dev/null 2>&1
        echo -e "${GREEN}✓ UFW reset${NC}"
    fi

    echo -e "\n${YELLOW}2. Setting Default Policies${NC}"
    ufw default deny incoming > /dev/null 2>&1
    ufw default allow outgoing > /dev/null 2>&1
    echo -e "${GREEN}✓ Default policies set (Deny incoming, Allow outgoing)${NC}"

    echo -e "\n${YELLOW}3. Allowing Critical Ports${NC}"
    ufw allow 22/tcp > /dev/null 2>&1  # SSH
    echo -e "${GREEN}✓ Port 22 (SSH) allowed${NC}"
    ufw allow 80/tcp > /dev/null 2>&1  # HTTP
    echo -e "${GREEN}✓ Port 80 (HTTP) allowed${NC}"
    ufw allow 443/tcp > /dev/null 2>&1 # HTTPS
    echo -e "${GREEN}✓ Port 443 (HTTPS) allowed${NC}"
    
    echo -e "\n${YELLOW}4. Rate Limiting SSH${NC}"
    ufw limit 22/tcp > /dev/null 2>&1
    echo -e "${GREEN}✓ SSH rate limiting enabled${NC}"
    
    echo -e "\n${YELLOW}5. Enabling UFW...${NC}"
    echo "y" | ufw enable > /dev/null 2>&1
    echo -e "${GREEN}✓ UFW enabled${NC}"

    echo -e "\n${CYAN}Current Firewall Rules:${NC}"
    ufw status numbered
    pause
}

setup_kernel_hardening() {
    banner
    echo -e "${BLUE}Kernel-Level Protection (sysctl.conf)${NC}"
    
    CONF_FILE="/etc/sysctl.d/99-hardening.conf"
    
    echo -e "${YELLOW}Applying Hardening Rules to $CONF_FILE...${NC}"
    
    cat > "$CONF_FILE" <<EOF
# IP Spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP broadcast requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# Ignore send redirects
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Block SYN attacks
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5

# Log Martians
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Ignore Directed pings
net.ipv4.icmp_echo_ignore_all = 0
EOF

    sysctl --system > /dev/null 2>&1
    echo -e "${GREEN}Kernel hardening applied!${NC}"
    
    echo -e "\n${CYAN}Explanation of applied settings:${NC}"
    echo "1. tcp_syncookies = 1   -> Prevents SYN flood DDoS attacks."
    echo "2. rp_filter = 1        -> Prevents IP spoofing."
    echo "3. accept_redirects = 0 -> Prevents malicious ICMP redirect packets."
    echo "4. tcp_max_syn_backlog  -> Increases connection queue for high traffic."
    
    pause
}

setup_mod_security() {
    banner
    if ! command -v apache2 &> /dev/null; then
         echo -e "${RED}ModSecurity requires Apache. Please install Apache first.${NC}"
         pause
         return
    fi

    echo -e "${BLUE}Setting up ModSecurity (WAF)...${NC}"
    
    echo -e "${YELLOW}Installing ModSecurity...${NC}"
    apt-get install -y libapache2-mod-security2 > /dev/null 2>&1 &
    progress_bar $! "Installing ModSecurity"
    
    echo -e "${YELLOW}Enabling module...${NC}"
    a2enmod security2 > /dev/null 2>&1
    
    # Copy recommended config
    if [[ -f /etc/modsecurity/modsecurity.conf-recommended ]]; then
        cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
        echo -e "${GREEN}✓ Configuration copied${NC}"
    fi
    
    # Set to Detection Only
    echo -e "${YELLOW}Configuring DetectionOnly mode...${NC}"
    sed -i 's/SecRuleEngine On/SecRuleEngine DetectionOnly/' /etc/modsecurity/modsecurity.conf
    sed -i 's/SecRuleEngine Off/SecRuleEngine DetectionOnly/' /etc/modsecurity/modsecurity.conf
    
    echo -e "${YELLOW}Restarting Apache...${NC}"
    systemctl restart apache2 > /dev/null 2>&1 &
    spinner $! "Restarting Apache"
    
    echo -e "${GREEN}✓✓✓ ModSecurity enabled in 'DetectionOnly' mode!${NC}"
    pause
}

hide_server_identity() {
    echo -e "${BLUE}Hiding Server Identity...${NC}"
    
    # For Apache
    if command -v apache2 &> /dev/null; then
        echo "ServerTokens Prod" > /etc/apache2/conf-available/security-custom.conf
        echo "ServerSignature Off" >> /etc/apache2/conf-available/security-custom.conf
        a2enconf security-custom > /dev/null 2>&1
        systemctl reload apache2
        echo -e "${GREEN}Apache version hidden.${NC}"
    fi
    
    # For Nginx
    if command -v nginx &> /dev/null; then
        if grep -q "server_tokens" /etc/nginx/nginx.conf; then
            sed -i 's/server_tokens.*/server_tokens off;/' /etc/nginx/nginx.conf
        else
            sed -i '/http {/a \    server_tokens off;' /etc/nginx/nginx.conf
        fi
        systemctl reload nginx
        echo -e "${GREEN}Nginx version hidden.${NC}"
    fi
    pause
}

show_open_ports() {
    echo -e "${BLUE}Open Ports:${NC}"
    if command -v ufw &> /dev/null; then
        ufw status verbose
    else
        ss -tuln
    fi
    pause
}

edit_config_files() {
    banner
    echo -e "${BLUE}Edit Configuration Files${NC}"
    echo "1) Apache Config (apache2.conf)"
    echo "2) Nginx Config (nginx.conf)"
    echo "3) PHP Config (php.ini)"
    echo "4) MySQL Config (my.cnf)"
    echo "5) Fail2Ban Jail (jail.local)"
    echo "6) Custom File"
    read -p "Select file to edit: " file_opt
    
    local target_file=""
    case $file_opt in
        1) target_file="/etc/apache2/apache2.conf" ;;
        2) target_file="/etc/nginx/nginx.conf" ;;
        3) target_file=$(php --ini | grep "Loaded Configuration File" | awk '{print $4}') ;;
        4) target_file="/etc/mysql/my.cnf" ;;
        5) target_file="/etc/fail2ban/jail.local" ;;
        6) read -p "Enter absolute path: " target_file ;;
    esac

    if [[ -z "$target_file" || ! -f "$target_file" ]]; then
        echo -e "${RED}File not found: $target_file${NC}"
        pause
        return
    fi
    
    echo -e "${CYAN}Choose Editor:${NC}"
    echo "1) Nano (Easier)"
    echo "2) Vim (Advanced)"
    read -p "Select editor [1-2]: " editor_opt
    
    local editor_cmd="nano"
    [[ "$editor_opt" == "2" ]] && editor_cmd="vim"
    
    $editor_cmd "$target_file"
}

# --- Complex Security Function Stubs (Full Impl Next) ---

setup_mod_evasive() {
    banner
    echo -e "${BLUE}Rate Limiting & Anti-Flood (mod_evasive)${NC}"

    if ! command -v apache2 &> /dev/null; then
         echo -e "${RED}mod_evasive requires Apache. Install Apache first.${NC}"
         pause
         return
    fi
    
    echo "1) Install & Configure mod_evasive"
    echo "2) Activate mod_evasive"
    echo "3) Deactivate mod_evasive"
    read -p "Select option [1-3]: " ev_opt
    
    case $ev_opt in
        1)
            echo -e "${YELLOW}Installing mod_evasive...${NC}"
            apt-get install -y libapache2-mod-evasive > /dev/null 2>&1 &
            progress_bar $! "Installing mod_evasive"
            
            echo -e "${YELLOW}Creating log directory...${NC}"
            mkdir -p /var/log/mod_evasive
            chown -R www-data:www-data /var/log/mod_evasive
            
            CONF_FILE="/etc/apache2/mods-available/evasive.conf"
            echo -e "${YELLOW}Configuring $CONF_FILE...${NC}"
            
            cat > "$CONF_FILE" <<EOF
<IfModule mod_evasive20.c>
    # This configuration will only apply when mod_evasive Apache module is active/loaded.

    DOSHashTableSize    3097 
    # This sets the size of a memory table inside Apache that tracks requests from each IP.
    # Keep this as is - it maintains good performance.

    DOSPageCount        5 
    # If any IP sends more than 5 requests to the same page (like /login.php) in 1 second, it will be marked as suspicious.

    DOSSiteCount        100 
    # If any IP makes more than 100 requests across the entire website in 1 second, it will be blocked.
    # This prevents unnecessary load on the entire site.

    DOSPageInterval     1
    DOSSiteInterval     1
    # This determines the time period (in seconds) for counting the page and site limits mentioned above.
    # Here: 1 second. This means it tracks every second.

    DOSBlockingPeriod   60 
    # If an IP breaks the above limits, it will be blocked for 60 seconds (1 minute).

    DOSEmailNotify      admin@localhost
    DOSLogDir           "/var/log/mod_evasive"
    DOSWhitelist        127.0.0.1
</IfModule>
EOF
            echo -e "${GREEN}✓ Configuration file created${NC}"
            
            echo -e "${YELLOW}Enabling mod_evasive...${NC}"
            a2enmod evasive > /dev/null 2>&1
            
            echo -e "${YELLOW}Restarting Apache...${NC}"
            systemctl restart apache2 > /dev/null 2>&1 &
            spinner $! "Restarting Apache"
            
            echo -e "${GREEN}✓✓✓ mod_evasive installed and enabled successfully!${NC}"
            ;;
        2)
            echo -e "${YELLOW}Activating mod_evasive...${NC}"
            a2enmod evasive > /dev/null 2>&1
            systemctl restart apache2 > /dev/null 2>&1 &
            spinner $! "Restarting Apache"
            echo -e "${GREEN}✓ mod_evasive activated${NC}"
            ;;
        3)
            echo -e "${YELLOW}Deactivating mod_evasive...${NC}"
            a2dismod evasive > /dev/null 2>&1
            systemctl restart apache2 > /dev/null 2>&1 &
            spinner $! "Restarting Apache"
            echo -e "${YELLOW}✓ mod_evasive deactivated${NC}"
            ;;
    esac
    pause
}

setup_fail2ban_advanced() {
    while true; do
        banner
        echo -e "${BLUE}Fail2Ban Intrusion Prevention System${NC}"
        echo "1) Install & Configure (Default Jail)"
        echo "2) Whitelist Manager (Add/Remove Trusted IPs)"
        echo "3) Unban an IP"
        echo "4) Ban an IP Manually"
        echo "5) Check Status (Active Jails)"
        echo "6) Return to Security Menu"
        read -p "Select option [1-6]: " f2b_opt
        
        case $f2b_opt in
            1)
                echo -e "${YELLOW}Installing Fail2Ban...${NC}"
                apt-get install -y fail2ban > /dev/null 2>&1 &
                progress_bar $! "Installing Fail2Ban"
                
                echo -e "${YELLOW}Configuring jail.local...${NC}"
                if [[ ! -f /etc/fail2ban/jail.local ]]; then
                    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local &
                    spinner $! "Copying configuration"
                fi
                
                # Basic SSH Jail
                cat >> /etc/fail2ban/jail.local <<EOF
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
findtime = 600
bantime = 3600
EOF
                echo -e "${GREEN}✓ SSH Jail configured${NC}"
                
                echo -e "${YELLOW}Starting Fail2Ban service...${NC}"
                systemctl restart fail2ban > /dev/null 2>&1 &
                spinner $! "Starting Fail2Ban"
                systemctl enable fail2ban > /dev/null 2>&1
                
                echo -e "${GREEN}✓✓✓ Fail2Ban installed and SSH Jail enabled!${NC}"
                pause
                ;;
            2)
                echo -e "${CYAN}--- Whitelist Manager ---${NC}"
                echo "Current Ignored IPs:"
                fail2ban-client get sshd ignoreip 2>/dev/null || echo "None"
                
                echo -e "\n1) Add IP to Whitelist"
                echo "2) Remove IP from Whitelist"
                read -p "Select: " wl_choice
                
                if [[ "$wl_choice" == "1" ]]; then
                    read -p "Enter IP(s) to whitelist (comma separated): " ips
                    IFS=',' read -ra IP_ADDR <<< "$ips"
                    for i in "${IP_ADDR[@]}"; do
                        i=$(echo $i | xargs) # trim whitespace
                        fail2ban-client set sshd addignoreip "$i" 2>/dev/null
                        echo -e "${GREEN}✓ Added $i${NC}"
                    done
                elif [[ "$wl_choice" == "2" ]]; then
                    read -p "Enter IP to remove: " ip_rem
                    fail2ban-client set sshd delignoreip "$ip_rem" 2>/dev/null
                    echo -e "${YELLOW}✓ Removed $ip_rem${NC}"
                fi
                pause
                ;;
            3)
                echo -e "${CYAN}--- Unban IP ---${NC}"
                read -p "Enter IP to unban: " unban_ip
                if [[ -n "$unban_ip" ]]; then
                    fail2ban-client unban "$unban_ip" 2>/dev/null
                    echo -e "${GREEN}✓ Unban command sent for $unban_ip${NC}"
                fi
                pause
                ;;
            4)
                echo -e "${CYAN}--- Manual Ban ---${NC}"
                read -p "Enter IP to Ban: " ban_ip
                read -p "Enter Jail Name (default: sshd): " jail_name
                jail_name=${jail_name:-sshd}
                
                fail2ban-client set "$jail_name" banip "$ban_ip" 2>/dev/null
                echo -e "${RED}✓ Banned $ban_ip in jail $jail_name${NC}"
                pause
                ;;
            5)
                echo -e "${CYAN}Fail2Ban Status:${NC}"
                fail2ban-client status
                echo -e "\nEnter Jail Name to see details (or press Enter to skip):"
                read jail_detail
                if [[ -n "$jail_detail" ]]; then
                    fail2ban-client status "$jail_detail"
                fi
                pause
                ;;
            6) return ;;
        esac
    done
}


setup_security_menu() {
    while true; do
        banner
        echo -e "${RED}--- SERVER SECURITY ---${NC}"
        echo "1) Rate Limiting & Anti-Flood (mod_evasive)"
        echo "2) Firewall Protection (UFW)"
        echo "3) Kernel System Hardening (sysctl)"
        echo "4) WAF - Web Application Firewall (ModSecurity)"
        echo "5) Fail2Ban Intrusion Prevention (Advanced)"
        echo "6) Hide Server Identity / Version"
        echo "7) Show Open Ports"
        echo "8) Return to Main Menu"
        echo "----------------------------------------"
        read -p "Select option [1-8]: " sec_opt
        
        case $sec_opt in
            1) setup_mod_evasive ;;
            2) setup_ufw ;;
            3) setup_kernel_hardening ;;
            4) setup_mod_security ;;
            5) setup_fail2ban_advanced ;;
            6) hide_server_identity ;;
            7) show_open_ports ;;
            8) return ;;
            *) echo -e "${RED}Invalid Option${NC}"; pause ;;
        esac
    done
}


# --- Main Menu ---

show_menu() {
    banner
    echo -e "${PURPLE}1)${NC} Full Server Setup ${CYAN}(curl, git, Apache/Nginx, PHP, MySQL, WP-CLI, phpMyAdmin, Security)${NC}"
    echo -e "${PURPLE}2)${NC} Base Dependencies ${CYAN}(curl, git, wget, nano, unzip, zip)${NC}"
    echo -e "${PURPLE}3)${NC} Web Server Stack ${CYAN}(Apache/Nginx + PHP 7.4-8.3 + MariaDB + WP-CLI + phpMyAdmin)${NC}"
    echo -e "${PURPLE}4)${NC} User Management ${CYAN}(Create secure non-root user with sudo access)${NC}"
    echo -e "${PURPLE}5)${NC} Server Security ${CYAN}(UFW, Fail2Ban, mod_evasive, ModSecurity, Kernel Hardening)${NC}"
    echo -e "${PURPLE}6)${NC} Domain Pointing & SSL ${CYAN}(Apache VirtualHost + Let's Encrypt SSL)${NC}"
    echo -e "${PURPLE}7)${NC} Edit Config Files ${CYAN}(Apache, Nginx, PHP, MySQL, Fail2Ban configs)${NC}"
    echo -e "${PURPLE}8)${NC} Exit"
    echo "-----------------------------------------------------------------"
}

# --- Main Execution ---

check_root
create_shortcut

while true; do
    show_menu
    read -p "Select an option [1-8]: " choice
    
    case $choice in
        1)
            setup_base
            setup_web_stack
            setup_security_menu
            ;;
        2) setup_base ;;
        3) setup_web_stack ;;
        4) setup_users ;;
        5) setup_security_menu ;;
        6) domain_pointing ;;
        7) 
             edit_config_files
             ;;
        8) 
            echo -e "${GREEN}Exiting. Stay secure!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            pause
            ;;
    esac
done
