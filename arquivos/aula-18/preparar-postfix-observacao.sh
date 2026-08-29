#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Execute com sudo."
  exit 1
fi

if ! id bob >/dev/null 2>&1; then
  useradd -m -s /bin/bash bob
fi

install -d -o bob -g bob /home/bob/Maildir
install -d -o bob -g bob /home/bob/Maildir/cur
install -d -o bob -g bob /home/bob/Maildir/new
install -d -o bob -g bob /home/bob/Maildir/tmp

postconf -e 'myhostname = mail.empresa.test'
postconf -e 'mydomain = empresa.test'
postconf -e 'myorigin = $mydomain'
postconf -e 'inet_interfaces = all'
postconf -e 'inet_protocols = ipv4'
postconf -e 'mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain'
postconf -e 'mynetworks = 127.0.0.0/8, 192.168.50.0/24'
postconf -e 'home_mailbox = Maildir/'

postfix check
systemctl restart postfix

echo
echo "Postfix preparado para observação."
postconf myhostname mydomain myorigin mydestination mynetworks home_mailbox
