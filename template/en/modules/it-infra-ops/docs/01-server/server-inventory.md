# Server & On-Premises Infrastructure Inventory — {{PROJECT_NAME}}

## 1. Environment Overview

This document records physical hardware, virtual machines, and internal network topology for on-premises infrastructure.

- Infrastructure environment: `{{INFRA_ENVIRONMENT}}`
- Primary operating system: `{{PRIMARY_OS}}`
- Official maintenance window: `{{MAINTENANCE_WINDOW}}`
- Backup storage target: `{{BACKUP_DESTINATION}}`

## 2. Server Node Matrix (Physical & Virtual Machines)

Every operating server node must be registered in the following inventory table:

| Hostname / Node ID | Type (Physical / VM / Container) | Internal IP (LAN) | Specs (vCPU / RAM / Disk) | Primary Role / Service | Status |
|---|---|---|---|---|---|
| `srv-app-01` | VM (Hypervisor) | `192.168.1.10` | 4 vCPU / 16 GB / 100 GB SSD | Web App & API Gateway | Active |
| `srv-db-01` | Bare Metal | `192.168.1.20` | 8 Core / 32 GB / 500 GB NVMe | Primary Database (PostgreSQL) | Active |
| `srv-bck-01` | NAS / Storage | `192.168.1.30` | 2 Core / 8 GB / 4 TB HDD RAID | Backup Archive Repository | Active |

## 3. Internal Network Topology & Firewall

- **Production Subnet / VLAN:** Isolated internal subnet for core services and database traffic.
- **Host Firewall Level:** All nodes must enforce host firewalls (`ufw`, `firewalld`, or `iptables`) with default *DROP incoming* policy.
- **Exposed Service Ports:**
  - Port `22` (SSH): Restricted to management jump-hosts or authorized internal VPN.
  - Port `80/443` (HTTP/HTTPS): Open for internal reverse proxies.
  - Port `5432/3306` (Database): Accessible only by registered application node IPs.

## 4. Administrative Accounts & SSH Key Management

- Direct root login via SSH is strictly disabled (`PermitRootLogin no`).
- Administrative access requires authorized SSH key pairs with password-protected `sudo` privileges.
- Storing SSH private keys in code repositories or public configurations is strictly prohibited.
