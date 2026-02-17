# AghorSec - Complete Server Security & Setup Tool

> **Developer**: Hrushabh  
> **Version**: v2.0.0  
> **Instagram**: @hrushabh.exe  
> **Status**: Production Ready

---

## 📋 Table of Contents
1. [What is AghorSec?](#what-is-aghorsec)
2. [Who Should Use This Tool?](#who-should-use-this-tool)
3. [Quick Start](#quick-start)
4. [Main Menu Options](#main-menu-options)
5. [Questions You'll Be Asked](#questions-youll-be-asked)
6. [Installation Process Details](#installation-process-details)
7. [Security Features Explained](#security-features-explained)
8. [Troubleshooting](#troubleshooting)
9. [Best Practices](#best-practices)

---

## 🎯 What is AghorSec?

AghorSec is an **automated server setup and security tool** that helps you:
- Install web servers (Apache/Nginx)
- Setup PHP, MySQL, WordPress tools
- Protect your server from hackers
- Configure firewall and security rules
- Manage domains and SSL certificates

**Think of it as**: A one-click solution to setup and secure your Linux server without typing hundreds of commands manually.

---

## 👥 Who Should Use This Tool?

### ✅ Perfect For:
1. **Web Developers** - Setting up hosting for websites
2. **WordPress Users** - Creating WordPress hosting environment
3. **Small Business Owners** - Hosting their own websites
4. **Students** - Learning server management
5. **Freelancers** - Managing client servers
6. **Startups** - Quick server deployment
7. **System Administrators** - Automating repetitive tasks

### ✅ Use Cases:
- Setting up a new VPS/Cloud server
- Hosting WordPress websites
- Creating development/staging servers
- Securing existing servers
- Managing multiple domains on one server
- Learning Linux server administration

### ⚠️ Requirements:
- **Operating System**: Ubuntu 20.04+ or Debian 10+
- **Server Access**: Root or sudo privileges
- **RAM**: Minimum 1GB (2GB recommended)
- **Disk Space**: At least 10GB free
- **Internet**: Active internet connection

---

## 🚀 Quick Start

### Step 1: Download the Script
```bash
# Download from your repository
wget https://your-repo.com/aghorec.sh
# OR upload the file to your server
```

### Step 2: Make it Executable
```bash
chmod +x aghorec.sh
```

### Step 3: Run as Root
```bash
sudo bash aghorec.sh
```

### Step 4: Use the Shortcut (After First Run)
```bash
# The script creates a shortcut automatically
setup
```

---

## 📖 Main Menu Options

When you run the script, you'll see this menu:

```
1) Full Server Setup (curl, git, Apache/Nginx, PHP, MySQL, WP-CLI, phpMyAdmin, Security)
2) Base Dependencies (curl, git, wget, nano, unzip, zip)
3) Web Server Stack (Apache/Nginx + PHP 7.4-8.3 + MariaDB + WP-CLI + phpMyAdmin)
4) User Management (Create secure non-root user with sudo access)
5) Server Security (UFW, Fail2Ban, mod_evasive, ModSecurity, Kernel Hardening)
6) Domain Pointing & SSL (Apache VirtualHost + Let's Encrypt SSL)
7) Edit Config Files (Apache, Nginx, PHP, MySQL, Fail2Ban configs)
8) Exit
```

### Option 1: Full Server Setup
**What it does**: Installs everything you need for a complete web hosting server.

**When to use**: 
- Fresh new server
- First time setup
- Want everything installed at once

**What gets installed**:
- Basic tools (curl, git, wget, nano)
- Web server (Apache or Nginx - you choose)
- PHP (version 7.4 to 8.3 - you choose)
- MariaDB (MySQL database)
- WP-CLI (WordPress command tool)
- phpMyAdmin (database management tool)
- Security tools (Firewall, Fail2Ban, etc.)

**Time needed**: 10-15 minutes

---

### Option 2: Base Dependencies
**What it does**: Installs basic command-line tools.

**When to use**:
- Minimal server setup
- Before installing other software
- Missing basic tools

**What gets installed**:
- curl (download files from internet)
- git (version control)
- wget (download files)
- nano (text editor)
- unzip/zip (compress/extract files)

**Time needed**: 2-3 minutes

---

### Option 3: Web Server Stack
**What it does**: Installs complete web hosting environment.

**When to use**:
- Want to host websites
- Need PHP and database
- WordPress hosting

**Questions you'll be asked**:

1. **"Choose Web Server: 1) Apache 2) Nginx"**
   - **Apache**: Easier for beginners, more compatible
   - **Nginx**: Faster, better for high traffic
   - **Recommendation**: Choose Apache if unsure

2. **"Choose PHP Version: 1) 8.3 2) 8.2 3) 8.1 4) 7.4"**
   - **PHP 8.3**: Latest, fastest (recommended)
   - **PHP 8.2**: Stable, widely supported
   - **PHP 8.1**: Older but stable
   - **PHP 7.4**: For old applications only
   - **Recommendation**: Choose 8.3 for new projects

3. **"Enter Database Username:"**
   - This is the username for accessing your database
   - Example: `admin_user` or `mysite_db`
   - **Important**: Save this username!

4. **"Enter Database Password:"**
   - Strong password for database security
   - Example: `MyStr0ng#Pass123`
   - **Important**: Save this password securely!

**What you'll see after**:
```
############################################################
#            KEEP BELOW CREDENTIALS SAFE                   #
############################################################
Database/PMA Username : admin_user
Database/PMA Password : MyStr0ng#Pass123
############################################################
```
**Action**: Copy these to a password manager immediately!

**Time needed**: 5-8 minutes

---

### Option 4: User Management
**What it does**: Creates a new non-root user for security.

**Why important**: 
- Running everything as root is dangerous
- If hacker gets root access, they control everything
- Non-root user limits damage

**Questions you'll be asked**:

1. **"Create User? [y/N]:"**
   - Type `y` for yes, `n` for no
   - **Recommendation**: Always create a non-root user

2. **"Enter New Username:"**
   - Choose a username (no spaces)
   - Example: `john`, `webadmin`, `myuser`

3. **"Enter New User Password:"**
   - Strong password for this user
   - This user will have sudo access

**What happens**:
- User is created with home directory
- Added to sudo group (can run admin commands)
- Credentials displayed on screen

**Time needed**: 1-2 minutes

---

### Option 5: Server Security
**What it does**: Protects your server from attacks.

**Sub-Menu Options**:

#### 5.1) Rate Limiting & Anti-Flood (mod_evasive)
**What it protects against**: DDoS attacks, too many requests

**How it works**:
- Tracks how many requests each IP makes
- If someone makes too many requests = BLOCKED
- Prevents server overload

**Questions you'll be asked**:
1. **"Select option [1-3]:"**
   - 1 = Install and setup
   - 2 = Turn on (activate)
   - 3 = Turn off (deactivate)

**Default Settings** (you can change later):
- `DOSPageCount: 5` - Max 5 requests per page per second
- `DOSSiteCount: 100` - Max 100 requests across site per second
- `DOSBlockingPeriod: 60` - Block for 60 seconds

**When to use**: If your site gets lots of traffic or attacks

---

#### 5.2) Firewall Protection (UFW)
**What it does**: Blocks unwanted network connections.

**Think of it as**: A security guard at your server's door.

**Questions you'll be asked**:

1. **"Reset UFW? [y/N]:"**
   - Clears all existing firewall rules
   - **Recommendation**: Type `y` if unsure about current rules

**What it does automatically**:
- Blocks all incoming connections (except allowed ones)
- Allows all outgoing connections
- Opens Port 22 (SSH - so you can login)
- Opens Port 80 (HTTP - for websites)
- Opens Port 443 (HTTPS - for secure websites)
- Adds rate limiting to SSH (prevents brute force)

**Important**: Your current SSH connection is automatically whitelisted (won't lock you out)

---

#### 5.3) Kernel System Hardening
**What it does**: Makes your operating system more secure at the core level.

**Protections applied**:
- **IP Spoofing Protection**: Stops fake IP addresses
- **SYN Flood Protection**: Blocks DDoS attacks
- **ICMP Broadcast Ignore**: Prevents Smurf attacks
- **Disable IP Forwarding**: Stops routing attacks

**No questions asked** - It applies best security settings automatically.

**Technical users**: Settings saved in `/etc/sysctl.d/99-hardening.conf`

---

#### 5.4) WAF - Web Application Firewall (ModSecurity)
**What it does**: Protects your website from hacking attempts.

**Protects against**:
- SQL Injection (database hacking)
- Cross-Site Scripting (XSS)
- Remote File Inclusion
- Command Injection

**Mode**: DetectionOnly (logs attacks but doesn't block - safe for production)

**No questions asked** - Installs and configures automatically.

---

#### 5.5) Fail2Ban Intrusion Prevention
**What it does**: Automatically bans IPs that try to hack your server.

**How it works**:
- Watches login attempts
- If someone fails 3 times = BANNED for 1 hour
- Protects SSH, Apache, and other services

**Sub-Options**:

**A) Install & Configure**
- Sets up Fail2Ban with default rules
- No questions asked

**B) Whitelist Manager**
Questions:
1. **"1) Add IP 2) Remove IP"**
   - Choose what you want to do

2. **"Enter IP(s) to whitelist (comma separated):"**
   - Example: `192.168.1.100` or `192.168.1.100,192.168.1.101`
   - **Use case**: Whitelist your office IP so you never get banned

**C) Unban an IP**
Question:
1. **"Enter IP to unban:"**
   - Example: `192.168.1.100`
   - **Use case**: You accidentally got banned

**D) Ban an IP Manually**
Questions:
1. **"Enter IP to Ban:"**
   - Example: `123.45.67.89`
2. **"Enter Jail Name (default: sshd):"**
   - Press Enter for default
   - **Use case**: Block a known attacker immediately

**E) Check Status**
- Shows all active jails
- Shows banned IPs
- No questions asked

---

#### 5.6) Hide Server Identity
**What it does**: Hides Apache/Nginx version from hackers.

**Why important**: Hackers look for specific versions with known vulnerabilities.

**No questions asked** - Applies automatically.

---

#### 5.7) Show Open Ports
**What it does**: Shows which ports are open on your server.

**Use for**: Security audit, troubleshooting.

**No questions asked** - Just displays information.

---

### Option 6: Domain Pointing & SSL
**What it does**: Connects your domain name to your server and adds HTTPS.

**Questions you'll be asked**:

1. **"Enter Domain Name (e.g., example.com):"**
   - Your website domain
   - Example: `mywebsite.com`
   - **Important**: Domain DNS must point to your server IP first!

2. **"Enter Document Root [/var/www/html/DOMAIN]:"**
   - Where your website files will be stored
   - Press Enter to use default
   - Or type custom path like `/var/www/mysite`

3. **"Install SSL? [y/N]:"**
   - Type `y` to get free HTTPS certificate
   - Type `n` to skip
   - **Recommendation**: Always use SSL (type `y`)

**What happens**:
- Creates folder for your website
- Creates Apache configuration
- Enables the site
- Installs Let's Encrypt SSL certificate (if you chose yes)
- Your site is now accessible at `https://yourdomain.com`

**Requirements for SSL**:
- Domain must point to your server IP
- Ports 80 and 443 must be open
- Internet connection active

**Time needed**: 3-5 minutes

---

### Option 7: Edit Config Files
**What it does**: Opens important configuration files for editing.

**Questions you'll be asked**:

1. **"Select file to edit:"**
   - 1 = Apache Config
   - 2 = Nginx Config
   - 3 = PHP Config
   - 4 = MySQL Config
   - 5 = Fail2Ban Jail
   - 6 = Custom file (you enter path)

2. **"Select editor [1-2]:"**
   - 1 = Nano (easier, recommended for beginners)
   - 2 = Vim (advanced users)

**Use cases**:
- Change PHP memory limit
- Modify Apache settings
- Adjust Fail2Ban rules
- Fine-tune database settings

---

## 🎬 Installation Process Details

### What Happens During Installation?

#### Visual Progress Indicators:
```
Updating packages: [████████████████████████████████████████] 100% ✓ Done!
Installing Apache: [████████████████████████████████████████] 100% ✓ Done!
Installing PHP 8.3: [████████████████████████████████████████] 100% ✓ Done!
Downloading WP-CLI... ✓ Done!
```

#### You Can Cancel Anytime:
- Press `Ctrl+C` to stop
- Script will cleanup and return to menu
- No damage to your server

#### Logs Are Saved:
- All actions logged to `/var/log/aghorec.log`
- Check if something goes wrong
- View with: `cat /var/log/aghorec.log`

---

## 🔒 Security Features Explained (Simple Terms)

### 1. Firewall (UFW)
**What it is**: A wall that blocks bad guys from entering your server.
**How it helps**: Only allows connections you approve.

### 2. Fail2Ban
**What it is**: A security guard that bans people who try wrong passwords.
**How it helps**: Stops brute force attacks automatically.

### 3. mod_evasive
**What it is**: Traffic police for your website.
**How it helps**: Blocks people making too many requests (DDoS protection).

### 4. ModSecurity
**What it is**: A smart filter that detects hacking attempts.
**How it helps**: Blocks SQL injection, XSS, and other attacks.

### 5. Kernel Hardening
**What it is**: Making your operating system core more secure.
**How it helps**: Prevents low-level attacks.

### 6. Hide Server Version
**What it is**: Hiding what software versions you use.
**How it helps**: Hackers can't target specific vulnerabilities.

---

## 🛠️ Troubleshooting

### Problem: "Permission Denied"
**Solution**: Run with sudo
```bash
sudo bash aghorec.sh
```

### Problem: "Can't connect to server after enabling firewall"
**Solution**: Access via VPS console and run:
```bash
sudo ufw allow 22/tcp
sudo ufw reload
```

### Problem: "SSL certificate failed"
**Causes**: 
- Domain not pointing to server
- Ports 80/443 blocked

**Solution**:
```bash
# Check DNS
host yourdomain.com

# Check firewall
sudo ufw status

# Try manual SSL
sudo certbot --apache -d yourdomain.com
```

### Problem: "phpMyAdmin not accessible"
**Solution**:
```bash
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
sudo systemctl restart apache2
```

### Problem: "Fail2Ban not banning"
**Solution**:
```bash
# Check status
sudo fail2ban-client status sshd

# Check logs
sudo tail -f /var/log/fail2ban.log

# Restart
sudo systemctl restart fail2ban
```

---

## ✅ Best Practices

### 1. First Time Setup
```
Step 1: Run Option 1 (Full Server Setup)
Step 2: Save all credentials shown
Step 3: Create non-root user (Option 4)
Step 4: Whitelist your IP in Fail2Ban
Step 5: Test SSH access before disconnecting
```

### 2. Adding a New Website
```
Step 1: Run Option 6 (Domain Pointing)
Step 2: Enter your domain
Step 3: Enable SSL
Step 4: Upload your website files
```

### 3. Security Checklist
- ✅ Enable firewall (UFW)
- ✅ Install Fail2Ban
- ✅ Enable mod_evasive
- ✅ Enable ModSecurity
- ✅ Apply kernel hardening
- ✅ Hide server version
- ✅ Use SSL for all domains
- ✅ Create non-root user
- ✅ Whitelist your IP
- ✅ Regular updates: `apt update && apt upgrade`

### 4. Maintenance
- Check logs weekly: `tail -f /var/log/aghorec.log`
- Review Fail2Ban bans: `sudo fail2ban-client status sshd`
- Update server monthly
- Backup configurations before changes

---

## 📊 Quick Reference

### Important Files
```
Script Log:        /var/log/aghorec.log
Security Report:   /var/log/aghorec-scan-report.txt
Apache Config:     /etc/apache2/apache2.conf
PHP Config:        /etc/php/8.3/apache2/php.ini
MySQL Config:      /etc/mysql/my.cnf
Fail2Ban Config:   /etc/fail2ban/jail.local
```

### Important Commands
```bash
# Run the tool
setup

# Check firewall status
sudo ufw status

# Check Fail2Ban status
sudo fail2ban-client status

# Restart Apache
sudo systemctl restart apache2

# Check Apache status
sudo systemctl status apache2

# View logs
sudo tail -f /var/log/aghorec.log
```

---

## 🎓 Learning Resources

### For Beginners:
1. Start with Option 1 (Full Server Setup)
2. Read each question carefully
3. Use default values if unsure
4. Save all credentials shown
5. Don't skip security options

### For Advanced Users:
1. Use individual options as needed
2. Customize configurations via Option 7
3. Review logs for troubleshooting
4. Fine-tune security settings

---

## 💡 Tips & Tricks

### Tip 1: Always Save Credentials
When you see this:
```
############################################################
#            KEEP BELOW CREDENTIALS SAFE                   #
############################################################
```
**STOP** and copy to password manager immediately!

### Tip 2: Test Before Disconnecting
After enabling firewall:
1. Open new SSH session
2. Test if you can login
3. If yes, close old session
4. If no, use VPS console to fix

### Tip 3: Whitelist Your IP
Before enabling Fail2Ban:
1. Find your IP: `curl ifconfig.me`
2. Add to whitelist in Fail2Ban
3. You'll never get banned

### Tip 4: Use Strong Passwords
- Minimum 12 characters
- Mix of letters, numbers, symbols
- Don't use common words
- Use password manager

---

## 🆘 Getting Help

### If Something Goes Wrong:
1. Check `/var/log/aghorec.log`
2. Read error messages carefully
3. Google the error message
4. Check troubleshooting section above

### Common Questions:
**Q: Can I run this on production server?**
A: Yes, but test in staging first.

**Q: Will it break my existing setup?**
A: No, it checks before installing.

**Q: Can I undo changes?**
A: Some changes yes, some no. Always backup first.

**Q: Is it safe?**
A: Yes, but review code before running.

---

## 📝 Summary

AghorSec is your **all-in-one server setup and security tool**. It:
- ✅ Saves hours of manual work
- ✅ Applies security best practices
- ✅ Works for beginners and experts
- ✅ Provides visual progress feedback
- ✅ Can be interrupted safely (Ctrl+C)
- ✅ Logs everything for troubleshooting

**Perfect for**: Web developers, WordPress users, small businesses, students, and anyone managing Linux servers.

---

## 📜 License

This tool is provided as-is for educational and production use.

---

## 👨‍💻 Developer

**Hrushabh**  
Instagram: @hrushabh.exe  
Version: v2.0.0

---

*Built with ❤️ for making server management easy and secure!*

**Stay Secure! 🔒**
