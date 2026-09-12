# Daemon, Cron & Background Tasks Specification — {{PROJECT_NAME}}

> Technical specifications for scheduled execution, systemd daemon service units, process supervision, and log rotation.

---

## 1. Execution Models

`{{COMMAND_NAME}}` operates across three recognized deployment modes:

- **Interactive Mode:** Invoked ad-hoc by human operators on terminals.
- **Scheduled Cron Mode:** Triggered periodically via UNIX `crontab` or Kubernetes CronJobs.
- **Continuous Daemon Mode:** Long-running worker managed by a service supervisor.

---

## 2. Systemd Service Unit (`systemd`)

For continuous daemon execution on Linux servers, deploy the following unit definition at `/etc/systemd/system/{{COMMAND_NAME}}.service`:

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

## 3. Scheduled Crontab Configuration

When running in periodic batch mode, schedule via crontab:

```cron
# Run data synchronization every hour at minute 15
15 * * * * /usr/local/bin/{{COMMAND_NAME}} run --quiet >> {{LOG_OUTPUT_TARGET}} 2>&1
```

---

## 4. Logging & Rotation Protocol

- **Log Target:** Defined by `{{LOG_OUTPUT_TARGET}}` (default: `/var/log/{{COMMAND_NAME}}/execution.log` or system journal).
- **Log Format:** Structured JSON lines (`timestamp`, `level`, `pid`, `message`, `context`).
- **Rotation Configuration (`/etc/logrotate.d/{{COMMAND_NAME}}`):**
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
