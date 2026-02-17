# AghorSec Installation Guide

Complete step-by-step installation instructions for AghorSec - Server Setup & Security Tool

---

## 📋 Table of Contents
1. [System Requirements](#system-requirements)
2. [Pre-Installation Checklist](#pre-installation-checklist)
3. [Installation Methods](#installation-methods)
4. [First Run Setup](#first-run-setup)
5. [Post-Installation](#post-installation)
6. [Troubleshooting](#troubleshooting)

---

## 💻 System Requirements

### Supported Operating Systems
- ✅ Ubuntu 20.04 LTS or higher
- ✅ Ubuntu 22.04 LTS (Recommended)
- ✅ Debian 10 (Buster) or higher
- ✅ Debian 11 (Bullseye)
- ✅ CentOS 7/8
- ✅ RHEL 7/8
- ✅ Fedora 35+

### Hardware Requirements
- **RAM**: Minimum 1GB (2GB recommended)
- **Disk Space**: At least 10GB free
- **CPU**: 1 core minimum (2+ cores recommended)
- **Network**: Active internet connection

### Access Requirements
- **Root Access**: Must have sudo or root privileges
- **SSH Access**: Terminal access to server
- **Ports**: Ability to open ports 22, 80, 443

---

## ✅ Pre-Installation Checklist

Before installing AghorSec, make sure you have:

- [ ] Fresh VPS or server with supported OS
- [ ] Root or sudo access
- [ ] SSH connection to server
- [ ] Internet connection working
- [ ] Backup of existing configurations (if any)
- [ ] Password manager ready for credentials
- [ ] Your server's IP address noted
- [ ] Domain name (if setting up websites)

---

## 📥 Installation Methods

### Method 1: Direct Download (Recommended)

#### Step 1: Connect to Your Server
```bash
ssh root@your-server-ip
# OR
ssh your-username@your-server-ip
```

#### Step 2: Download AghorSec
```bash
# Using wget
wget https://raw.githubusercontent.com/your-repo/AghorSec/main/aghorec.sh

# OR using curl
curl -O https://raw.githubusercontent.com/your-repo/AghorSec/main/aghorec.sh
```

#### Step 3: Make it Executable
```bash
chmod +x aghorec.sh
```

#### Step 4: Run the Script
```bash
sudo bash aghorec.sh
```

---

### Method 2: Git Clone

#### Step 1: Install Git (if not installed)
```bash
sudo apt update
sudo apt install git -y
```

#### Step 2: Clone Repository
```bash
git clone https://github.com/your-repo/AghorSec.git
cd AghorSec
```

#### Step 3: Make Executable and Run
```bash
chmod +x aghorec.sh
sudo bash aghorec.sh
```

---

### Method 3: Manual Upload

#### Step 1: Download to Your Computer
Download `aghorec.sh` from the repository to your local computer.

#### Step 2: Upload to Server
```bash
# Using SCP from your local machine
scp aghorec.sh root@your-server-ip:/root/

# OR using SFTP
sftp root@your-server-ip
put aghorec.sh
exit
```

#### Step 3: Connect and Run
```bash
ssh root@your-server-ip
chmod +x aghorec.sh
sudo bash aghorec.sh
```

---

## 🚀 First Run Setup

### What Happens on First Run

1. **Root Check**: Script verifies you have root privileges
2. **OS Detection**: Automatically detects your operating system
3. **Shortcut Creation**: Creates `setup` command for easy access
4. **Main Menu**: Displays interactive menu with 8 options

### First Run Example

```bash
$ sudo bash aghorec.sh

 @@@@@@   @@@@@@@  @@@  @@@  @@@@@@  @@@@@@@      @@@@@@ @@@@@@@@  @@@@@@@ 
@@!  @@@ !@@       @@!  @@@ @@!  @@@ @@!  @@@    !@@     @@!      !@@      
@!@!@!@! !@! @!@!@ @!@!@!@! @!@  !@! @!@!!@!      !@@!!  @!!!:!   !@!      
!!:  !!! :!!   !!: !!:  !!! !!:  !!! !!: :!!         !:! !!:      :!!      
 :   : :  :: :: :   :   : :  : :. :   :   : :    ::.: :  : :: ::   :: :: : 

  AghorSec v2.0 | Secure Server Setup | By Hrushabh
-----------------------------------------------------------------
Creating 'setup' shortcut...
Shortcut created! You can now just type 'setup' to run this tool.

1) Full Server Setup (curl, git, Apache/Nginx, PHP, MySQL, WP-CLI, phpMyAdmin, Security)
2) Base Dependencies (curl, git, wget, nano, unzip, zip)
3) Web Server Stack (Apache/Nginx + PHP 7.4-8.3 + MariaDB + WP-CLI + phpMyAdmin)
4) User Management (Create secure non-root user with sudo access)
5) Server Security (UFW, Fail2Ban, mod_evasive, ModSecurity, Kernel Hardening)
6) Domain Pointing & SSL (Apache VirtualHost + Let's Encrypt SSL)
7) Edit Config Files (Apache, Nginx, PHP, MySQL, Fail2Ban configs)
8) Exit
-----------------------------------------------------------------
Select an option [1-8]:
```

---

## 🎯 Recommended First-Time Setup

### For Complete New Server

**Step 1**: Run Full Server Setup
```bash
sudo bash aghorec.sh
# Select: 1 (Full Server Setup)
```

**Step 2**: Answer Questions
- Choose Apache or Nginx
- Select PHP version (8.3 recommended)
- Enter database username
- Enter database password
- **IMPORTANT**: Save displayed credentials!

**Step 3**: Create Non-Root User
```bash
setup
# Select: 4 (User Management)
# Enter username and password
# Save credentials shown
```

**Step 4**: Configure Security
```bash
setup
# Select: 5 (Server Security)
# Run all security options
# Whitelist your IP in Fail2Ban
```

**Step 5**: Setup Domain (Optional)
```bash
setup
# Select: 6 (Domain Pointing & SSL)
# Enter your domain name
# Enable SSL
```

---

## 📦 Post-Installation

### Verify Installation

#### Check Installed Services
```bash
# Check Apache/Nginx
sudo systemctl status apache2
# OR
sudo systemctl status nginx

# Check MariaDB
sudo systemctl status mariadb

# Check Fail2Ban
sudo systemctl status fail2ban

# Check Firewall
sudo ufw status
```

#### Check Logs
```bash
# View installation log
cat /var/log/aghorec.log

# View security scan report
cat /var/log/aghorec-scan-report-*.txt
```

### Important Files Created

```
/usr/local/bin/setup              # Shortcut command
/var/log/aghorec.log              # Installation log
/var/log/aghorec-scan-report.txt  # Security scan reports
/etc/apache2/sites-available/     # Apache virtual hosts
/etc/fail2ban/jail.local          # Fail2Ban configuration
/etc/sysctl.d/99-hardening.conf   # Kernel hardening
```

### Test Your Setup

#### Test Web Server
```bash
# Check if Apache/Nginx is running
curl http://localhost

# Should return HTML content
```

#### Test Database
```bash
# Login to MySQL
mysql -u your_username -p

# Enter password when prompted
# If successful, you'll see MySQL prompt
```

#### Test phpMyAdmin
```bash
# Open in browser
http://your-server-ip/phpmyadmin

# Login with database credentials
```

---

## 🔧 Troubleshooting

### Issue 1: Permission Denied

**Error**: `Permission denied` when running script

**Solution**:
```bash
# Make sure you're using sudo
sudo bash aghorec.sh

# OR switch to root
sudo su
bash aghorec.sh
```

---

### Issue 2: Command Not Found

**Error**: `bash: aghorec.sh: command not found`

**Solution**:
```bash
# Make sure you're in the correct directory
ls -la aghorec.sh

# If file exists, make it executable
chmod +x aghorec.sh

# Run with full path
sudo bash ./aghorec.sh
```

---

### Issue 3: Package Installation Fails

**Error**: `Unable to locate package` or `Package not found`

**Solution**:
```bash
# Update package lists
sudo apt update

# Try running script again
sudo bash aghorec.sh
```

---

### Issue 4: Firewall Lockout

**Error**: Can't connect via SSH after enabling firewall

**Solution**:
```bash
# Access via VPS console (from hosting provider panel)
# Then run:
sudo ufw allow 22/tcp
sudo ufw reload

# OR disable firewall temporarily
sudo ufw disable
```

---

### Issue 5: SSL Certificate Fails

**Error**: Certbot fails to install SSL certificate

**Solution**:
```bash
# Check if domain points to server
host yourdomain.com

# Check if ports are open
sudo ufw status

# Ensure Apache is running
sudo systemctl status apache2

# Try manual SSL installation
sudo certbot --apache -d yourdomain.com
```

---

### Issue 6: phpMyAdmin Not Accessible

**Error**: 404 Not Found when accessing phpMyAdmin

**Solution**:
```bash
# Create symbolic link
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Restart Apache
sudo systemctl restart apache2

# Access at: http://your-ip/phpmyadmin
```

---

### Issue 7: Database Connection Failed

**Error**: Can't connect to database

**Solution**:
```bash
# Check if MariaDB is running
sudo systemctl status mariadb

# Start if not running
sudo systemctl start mariadb

# Reset root password if needed
sudo mysql_secure_installation
```

---

## 🔄 Updating AghorSec

### Check for Updates
```bash
# If installed via git
cd AghorSec
git pull origin main

# If downloaded directly
wget https://raw.githubusercontent.com/your-repo/AghorSec/main/aghorec.sh -O aghorec.sh
chmod +x aghorec.sh
```

---

## 🗑️ Uninstallation

### Remove AghorSec Script
```bash
# Remove script
rm -f aghorec.sh
rm -f /usr/local/bin/setup

# Remove logs (optional)
rm -f /var/log/aghorec.log
rm -f /var/log/aghorec-scan-report*.txt
```

### Remove Installed Services (Optional)
```bash
# Remove Apache
sudo apt remove apache2 -y

# Remove Nginx
sudo apt remove nginx -y

# Remove MariaDB
sudo apt remove mariadb-server -y

# Remove PHP
sudo apt remove php* -y

# Remove Fail2Ban
sudo apt remove fail2ban -y

# Remove UFW
sudo apt remove ufw -y
```

**Note**: Only remove services if you're sure you don't need them!

---

## 📞 Getting Help

### If Installation Fails

1. **Check Logs**:
   ```bash
   cat /var/log/aghorec.log
   ```

2. **Check System Logs**:
   ```bash
   sudo journalctl -xe
   ```

3. **Verify OS Compatibility**:
   ```bash
   cat /etc/os-release
   ```

4. **Check Internet Connection**:
   ```bash
   ping -c 4 google.com
   ```

### Support Resources

- **GitHub Issues**: Report bugs and issues
- **Documentation**: Read README.md for detailed usage
- **Community**: Join discussions and get help

---

## ✅ Installation Checklist

After installation, verify:

- [ ] Script runs without errors
- [ ] `setup` command works
- [ ] Web server is running
- [ ] Database is accessible
- [ ] Firewall is configured
- [ ] Fail2Ban is active
- [ ] Credentials are saved securely
- [ ] Non-root user created
- [ ] Domain configured (if applicable)
- [ ] SSL certificate installed (if applicable)

---

## 🎉 Next Steps

After successful installation:

1. **Secure Your Credentials**: Store all passwords in password manager
2. **Test SSH Access**: Open new terminal and test login
3. **Configure Backups**: Set up regular backups
4. **Monitor Logs**: Check logs regularly for issues
5. **Update Regularly**: Keep system and packages updated
6. **Read Documentation**: Review README.md for advanced features

---

## 📝 Quick Command Reference

```bash
# Run AghorSec
sudo bash aghorec.sh

# Use shortcut (after first run)
setup

# Check logs
cat /var/log/aghorec.log

# Check services
sudo systemctl status apache2
sudo systemctl status mariadb
sudo systemctl status fail2ban

# Check firewall
sudo ufw status

# Check Fail2Ban
sudo fail2ban-client status
```

---

**Installation Complete! 🎊**

You're now ready to use AghorSec for server management and security.

For detailed usage instructions, see [README.md](README.md)

---

*Built with ❤️ by Hrushabh | @hrushabh.exe*
