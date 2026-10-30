#!/usr/bin/env bash
# Azatech AI Workspace - Faz 1 SALT-OKUNUR sunucu denetimi.
# Hicbir dosya yazmaz, paket kurmaz, servis baslatmaz/durdurmaz, kural degistirmez.
# Parola/token/anahtar degerleri maskelenir.
export LC_ALL=C
mask() { sed -E 's/((pass(word)?|secret|token|key|api[_-]?key)[A-Za-z_]*[=:"'"'"' ]+)[^ ",]+/\1***MASKELI***/Ig'; }
sec() { printf '\n===== %s =====\n' "$1"; }
run() { printf '$ %s\n' "$*"; "$@" 2>&1 | mask | head -n 80; }
has() { command -v "$1" >/dev/null 2>&1; }

sec "1. OS ve DONANIM"
run uname -a
[ -r /etc/os-release ] && run cat /etc/os-release
run nproc
run free -h
run df -hT -x tmpfs -x devtmpfs
has lscpu && run lscpu
run uptime
run swapon --show

sec "2. KAYNAK KULLANIMI (ilk 15 surec)"
ps aux --sort=-%mem 2>/dev/null | head -n 16 | cut -c1-180

sec "3. aaPanel"
if [ -d /www/server/panel ]; then
  echo "aaPanel dizini: /www/server/panel"
  [ -r /www/server/panel/class/common.py ] && grep -m1 -E "version" /www/server/panel/class/common.py
  [ -r /www/server/panel/data/port.pl ] && echo "Panel portu: $(cat /www/server/panel/data/port.pl)"
  [ -r /www/server/panel/data/admin_path.pl ] && echo "Giris yolu tanimli (deger gizlendi)"
  echo "-- /www/server icerigi:"; ls /www/server 2>&1
  echo "-- Siteler:"; ls /www/wwwroot 2>&1
  has bt && echo "bt CLI mevcut"
else
  echo "aaPanel bulunamadi (/www/server/panel yok)"
fi

sec "4. SERVISLER"
has systemctl && systemctl list-units --type=service --state=running --no-pager 2>&1 | head -n 60
for s in nginx apache2 httpd mysql mysqld mariadb postgresql redis redis-server docker fail2ban ufw firewalld; do
  has systemctl && printf '%s: %s\n' "$s" "$(systemctl is-active $s 2>&1)"
done

sec "5. DOCKER"
if has docker; then
  run docker --version
  run docker compose version
  run docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
  run docker network ls
  run docker volume ls
  run docker info --format 'Surucu={{.Driver}} Cgroup={{.CgroupVersion}} Rootless={{.SecurityOptions}} ConfigDosyasiYok'
  echo "-- docker.sock izinleri:"; ls -l /var/run/docker.sock 2>&1
  echo "-- daemon.json:"; [ -r /etc/docker/daemon.json ] && mask < /etc/docker/daemon.json || echo yok
else
  echo "Docker kurulu degil"
fi

sec "6. DINLENEN PORTLAR"
if has ss; then ss -tulpn 2>&1 | head -n 80; else netstat -tulpn 2>&1 | head -n 80; fi

sec "7. GUVENLIK DUVARI"
has ufw && ufw status verbose 2>&1
has firewall-cmd && firewall-cmd --list-all 2>&1
has iptables && iptables -S 2>&1 | head -n 60
has nft && nft list ruleset 2>&1 | head -n 60
echo "-- fail2ban:"; has fail2ban-client && fail2ban-client status 2>&1

sec "8. SSH YAPILANDIRMASI"
sshd -T 2>/dev/null | grep -E '^(port|permitrootlogin|passwordauthentication|pubkeyauthentication|pubkeyacceptedalgorithms|maxauthtries|x11forwarding|allowusers|allowgroups) ' \
  || grep -v -E '^\s*(#|$)' /etc/ssh/sshd_config 2>&1 | head -n 40
echo "-- Son basarisiz girisler (sayi):"; lastb 2>/dev/null | wc -l
echo "-- Yetkili anahtar sayisi (root):"; [ -r /root/.ssh/authorized_keys ] && grep -c -v '^\s*$' /root/.ssh/authorized_keys

sec "9. KULLANICILAR / SUDO"
awk -F: '$3==0 || $3>=1000 {print $1":"$3":"$7}' /etc/passwd
getent group sudo wheel docker 2>&1

sec "10. GUNCELLEMELER VE YEDEK"
has apt && apt list --upgradable 2>/dev/null | wc -l | sed 's/^/Guncellenebilir paket (apt): /'
has yum && yum -q check-update 2>/dev/null | grep -c . | sed 's/^/Guncellenebilir paket (yum): /'
echo "-- cron:"; crontab -l 2>&1 | mask | head -n 20
echo "-- Hedef klasor:"; ls -ld /dkprojects "/dkprojects/dk apps" /www/wwwroot/dkprojects 2>&1

sec "11. VERITABANLARI (yalnizca surum/varlik)"
has mysql && mysql --version
has psql && psql --version
has redis-server && redis-server --version

sec "BITTI"
date -u
