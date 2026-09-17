# Inventarisasi Server & Infrastruktur On-Premises — {{PROJECT_NAME}}

## 1. Ringkasan Lingkungan (Environment Overview)

Dokumen ini mencatat inventarisasi fisik, virtual, dan topologi jaringan internal untuk infrastruktur on-premises sistem.

- Lingkungan infrastruktur: `{{INFRA_ENVIRONMENT}}`
- Sistem operasi utama: `{{PRIMARY_OS}}`
- Jendela pemeliharaan resmi: `{{MAINTENANCE_WINDOW}}`
- Lokasi target backup: `{{BACKUP_DESTINATION}}`

## 2. Matriks Node Server (Physical & Virtual Machines)

Setiap node server yang beroperasi wajib terdaftar pada tabel berikut:

| Hostname / Node ID | Tipe (Fisik / VM / Container) | IP Internal (LAN) | Spesifikasi (vCPU / RAM / Disk) | Peran / Layanan Utama | Status |
|---|---|---|---|---|---|
| `srv-app-01` | VM (Hypervisor) | `192.168.1.10` | 4 vCPU / 16 GB / 100 GB SSD | Web App & API Gateway | Aktif |
| `srv-db-01` | Bare Metal | `192.168.1.20` | 8 Core / 32 GB / 500 GB NVMe | Database Utama (PostgreSQL) | Aktif |
| `srv-bck-01` | NAS / Storage | `192.168.1.30` | 2 Core / 8 GB / 4 TB HDD RAID | Repositori Backup & Arsip | Aktif |

## 3. Topologi Jaringan Internal & Firewall

- **Subnet / VLAN Produksi:** Subnet internal terisolasi untuk layanan aplikasi dan database.
- **Firewall Lokal (Host Level):** Seluruh server wajib mengaktifkan firewall lokal (`ufw`, `firewalld`, atau `iptables`) dengan kebijakan default *DROP incoming*.
- **Port Layanan Terbuka:**
  - Port `22` (SSH): Hanya diizinkan dari IP jump-host atau VPN manajemen lokal.
  - Port `80/443` (HTTP/HTTPS): Terbuka untuk reverse proxy internal.
  - Port `5432/3306` (Database): Hanya dapat diakses oleh IP server aplikasi yang terdaftar.

## 4. Akun Administratif & Manajemen Kunci SSH

- Kredensial root langsung via SSH dinonaktifkan (`PermitRootLogin no`).
- Akses administratif hanya melalui otentikasi SSH Key pair terotorisasi dengan hak `sudo`.
- Dilarang keras menyimpan private key SSH di dalam repositori kode atau berkas konfigurasi publik.
