#!/bin/bash
sudo -i
yum install epel-release -y
yum install borgbackup vim -y

sudo cat <<EOT >> /etc/systemd/system/borg-backup.service
[Unit]
Description=Borg Backup

[Service]
Type=oneshot

Environment=BORG_PASSPHRASE=1

Environment=REPO=borg@192.168.11.160:/var/backup/

Environment=BACKUP_TARGET=/etc

# Создание бэкапа / Creating a backup
ExecStart=/bin/borg create \\
--stats \\
\${REPO}::etc-{now:%%Y-%%m-%%d_%%H:%%M:%%S} \${BACKUP_TARGET}

# Проверка бэкапа / Backup verification
ExecStart=/bin/borg check \${REPO}

# Очистка старых бэкапов / Cleaning up old backups
ExecStart=/bin/borg prune \\
--keep-daily 90 \\
--keep-monthly 12 \\
--keep-yearly 1 \\
\${REPO}
EOT

sudo touch /etc/systemd/system/borg-backup.timer

sudo cat <<EOT >> /etc/systemd/system/borg-backup.timer
[Unit]
Description=Borg Backup

[Timer]
OnUnitActiveSec=5min
Unit=borg-backup.service

[Install]
WantedBy=timers.target
EOT

