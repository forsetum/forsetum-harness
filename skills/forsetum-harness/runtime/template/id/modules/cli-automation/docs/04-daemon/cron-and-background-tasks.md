# Spesifikasi Daemon, Cron & Tugas Latar Belakang — {{PROJECT_NAME}}

> Spesifikasi teknis untuk eksekusi terjadwal, unit layanan daemon systemd, pengawasan proses, dan rotasi log.

---

## 1. Model Eksekusi

`{{COMMAND_NAME}}` dapat dioperasikan dalam tiga model penerapan:

- **Mode Interaktif:** Dijalankan secara berkala atau ad-hoc oleh pengguna di terminal.
- **Mode Cron Terjadwal:** Dipicu secara periodik melalui UNIX `crontab` atau CronJob Kubernetes.
- **Mode Daemon Berkelanjutan:** Pekerja latar belakang yang berjalan terus-menerus di bawah pengawasan supervisor layanan.

---

## 2. Konfigurasi Unit Layanan Systemd (`systemd`)

Untuk eksekusi daemon terus-menerus pada server Linux, pasang berkas unit berikut pada `/etc/systemd/system/{{COMMAND_NAME}}.service`:

```ini
[Unit]
Description={{PROJECT_NAME}} Automation Worker
After=network.target
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
Type=simple
User=automation
Group=automation
WorkingDirectory=/opt/{{COMMAND_NAME}}
ExecStart=/usr/local/bin/{{COMMAND_NAME}} daemon --config /etc/{{COMMAND_NAME}}/config.json
Restart=on-failure
RestartSec=5s
Environment=LOG_DESTINATION={{LOG_OUTPUT_TARGET}}
LimitNOFILE=65536
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

---

## 3. Konfigurasi Penjadwalan Crontab

Jika beroperasi dalam mode batch periodik, atur jadwal melalui crontab:

```cron
# Jalankan sinkronisasi data setiap jam pada menit ke-15
15 * * * * /usr/local/bin/{{COMMAND_NAME}} run --quiet >> {{LOG_OUTPUT_TARGET}} 2>&1
```

---

## 4. Protokol Pencatatan & Rotasi Log

- **Target Log:** Ditentukan oleh `{{LOG_OUTPUT_TARGET}}` (standar: `/var/log/{{COMMAND_NAME}}/execution.log` atau journal systemd).
- **Format Log:** Baris JSON terstruktur (`timestamp`, `level`, `pid`, `message`, `context`).
- **Konfigurasi Rotasi Log (`/etc/logrotate.d/{{COMMAND_NAME}}`):**
  ```text
  /var/log/{{COMMAND_NAME}}/*.log {
      daily
      rotate 14
      compress
      delaycompress
      missingok
      notifempty
      create 0640 automation automation
  }
  ```
