# Aghorec - Linux Server Hardening Framework

> **Developer**: Hrushabh  
> **Version**: v1.0.0 Secure Build  
> **Status**: Production Ready

## Overview

Aghorec is a high-level, modular DevSecOps framework designed to automate the setup and hardening of Linux servers (Ubuntu, Debian, CentOS, RHEL). It follows a strict defensive security mindset, ensuring that your infrastructure is secure by default without breaking existing applications.

## Key Features

- **OS Auto-Detection**: Automatically adapts to Debian/Ubuntu (apt) or RHEL/CentOS (yum/dnf).
- **Dependency Management**: Smart check-and-install logic. Never reinstalls existing tools.
- **Web Server Stack**: Safely installs and configures Nginx or Apache.
- **SSL Automation**: Interactive Certbot setup for HTTPS.
- **Firewall Hardening**: Configures UFW with safe defaults (Anti-Lockout protection for SSH).
- **Intrusion Prevention**: Sets up Fail2ban with a custom `jail.local`.
- **Log Monitoring**: Deploys a custom security monitor script and cron job.
- **Vulnerability Audit**: Integrates Lynis and ClamAV for system scanning.

## Safety Mechanisms

- **Root Privilege Check**: Ensures administrative access.
- **Error Trapping**: Stops execution on critical failures (`set -e` logic).
- **User Confirmation**: Critical actions (Firewall enables, SSL setup) require explicit "Y" confirmation.
- **Non-Destructive**: Does not overwrite existing configuration files blindly.

## Usage

Run the script interactively:

```bash
sudo ./aghorec.sh
```

### Interactive Menu
1. **Full Server Setup**: Runs all modules sequentially.
2. **Base Dependencies**: Installs core tools (curl, git, vim, etc.).
3. **Web Server Setup**: Configures Nginx/Apache.
4. **SSL Setup**: Secures your domain with Let's Encrypt.
5. **Firewall Hardening**: Enables UFW with SSH safety.
6. **Fail2ban Setup**: Protects against brute-force attacks.
7. **Security Scan**: Runs Lynis and ClamAV audits.
8. **Setup Logging**: Configures local log monitoring.

## Logs

- **Action Log**: `/var/log/aghorec.log`
- **Security Monitor**: `/var/log/security-monitor.log`
- **Scan Reports**: `/var/log/aghorec-scan-report.txt`

---
*Built with ❤️ for Blue Teams.*
