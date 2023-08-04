**Создаём виртуальные машины**

Использую _[Vagrantfile](Vagrantfile)_, который в репозитории

При создании будут использваны скрипты _[скрипт](install_script_client.sh)_ и _[скрипт](install_script_backup.sh)

Будут созданы виртуальные машины:  
с именем **client**, ip-адресом - **192.168.11.150**  
с именем **backup**, ip-адресом - **192.168.11.160**

**Действия на машине backup**
С помощью команды fdisk /dev/sdb создаем радел _sdb1_ 

Отформатируем в xfs
```
mkfs -t xfs /dev/sdb1
```

Выполняем монтирование:
```
[root@backup ~]# mount /dev/sdb1 /var/backup/
[root@backup ~]# lsblk
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda      8:0    0  40G  0 disk 
`-sda1   8:1    0  40G  0 part /
sdb      8:16   0   2G  0 disk 
`-sdb1   8:17   0   2G  0 part /var/backup
```

Для постоянного монтирования нашего жесткого диска для бэкапов в файле _/etc/fstab_ добавим сторку:  
```
#echo "/dev/sdb1            /var/backup                    xfs     defaults        0 0" >> /etc/fstab
```

На обоих машинах нужно настроить между собой ssh соединение по ключу. Содержимое /root/.ssh/id_rsa.pub добавляем в файл authorized_keys в каталоге /home/borg/.ssh/

**Действия на машине client**

Инициализируем зашифрованый репозиторий borg на backup сервере с client сервера:
```bash
borg init --encryption=repokey borg@192.168.11.160:/var/backup/
```

Запускаем для проверки создания бэкапа
```
borg create --stats --list borg@192.168.11.160:/var/backup/::etc-{now:%Y-%m-%d_%H:%M:%S} /etc
```

Смотрим список созданных файлов

```
[root@client ~]#  borg list borg@192.168.11.160:/var/backup/
etc-2023-08-03_15:30:32              Thu, 2023-08-03 15:30:33 [3738d9c0f9b8b5306161a7bff4bb30e05dcecddddc01dec69726af4a719a5094]
```
Смотрим список файлов
```
borg list borg@192.168.11.160:/var/backup/::etc-2023-08-03_15:30:32
```

Достаем файл из бекапа
```
borg extract borg@192.168.11.160:/var/backup/::etc-2023-08-03_15:30:32 etc/hostname
```

Смотрим, находясь в домашнем каталоге пользователя Vagrant сервера client
```
cat etc/hostname

	client
```

**Автоматизируем создание бэкапов с помощью systemd**
С помощью Vagrant файла, ранее создалось два файла: borg-backup.service (сервис) и borg-backup.timer (таймер).

Включаем и запускаем службы
```
sudo systemctl enable borg-backup.timer
sudo systemctl start borg-backup.timer
sudo systemctl enable borg-backup.service
sudo systemctl start borg-backup.service
```

Проверяем работу таймера
```
[root@client ~]# systemctl list-timers --all
NEXT                         LEFT          LAST                         PASSED       UNIT       
Fri 2023-08-04 06:54:59 UTC  3min 42s left Fri 2023-08-04 06:49:59 UTC  1min 17s ago borg-backup
Fri 2023-08-04 15:11:51 UTC  8h left       Thu 2023-08-03 15:11:51 UTC  15h ago      systemd-tmp
```

Список бэкапов
```
[root@client ~]# borg list borg@192.168.11.160:/var/backup/
Enter passphrase for key ssh://borg@192.168.11.160/var/backup: 
etc-2023-08-03_15:59:53              Thu, 2023-08-03 16:00:00 [02aebb6d162dd0274956198254377ec200b16961b0a2fef2e536e250c8aaa4ae]
etc-2023-08-04_06:50:00              Fri, 2023-08-04 06:50:01 [af7dfc726c4ed14706acee76a200b0e75d09daf59fc3566c7ecfe2df3f1753a3]

```


Логи работы сервиса, можно посмотреть
```
sudo journalctl -xeu borg-backup.service
sudo journalctl -u borg-backup.service
```
