# Installation Instructions

Aghorec is a standalone Bash script. No complex dependencies are required to start installation.

## Prerequisites

- **OS**: Ubuntu, Debian, CentOS, RHEL, or Fedora.
- **Privileges**: Root access (`sudo`).
- **Network**: Internet connection to download packages.

## Quick Start

1.  **Download the script**:
    Copy `aghorec.sh` to your server.

    ```bash
    # Example using scp from your local machine
    scp aghorec.sh user@your-server:/home/user/
    ```

    Or create it directly on the server:
    ```bash
    nano aghorec.sh
    # Paste content
    ```

2.  **Make it executable**:
    ```bash
    chmod +x aghorec.sh
    ```

3.  **Run as Root**:
    ```bash
    sudo ./aghorec.sh
    ```

## Post-Installation

Aghorec creates logs and reports at:
- `/var/log/aghorec.log`
- `/var/log/aghorec-scan-report.txt`

For automated monitoring, the script sets up a crontab entry for log checking. Verify it with:
```bash
sudo crontab -l
```

## Troubleshooting

- **Permission Denied**: Ensure you run with `sudo`.
- **Package Not Found**: Keep system repositories up to date.
- **Firewall Lockout**: If you locked yourself out, access via console/VNC and disable UFW: `ufw disable`.
