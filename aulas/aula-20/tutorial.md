# Aula 20 — POP3 e IMAP4 com Dovecot

**Bloco de referência:** 100 minutos

## Objetivos

Ao final desta aula, você deverá conseguir:

- explicar a diferença entre SMTP e protocolos de acesso à caixa postal;
- configurar Dovecot com Maildir;
- disponibilizar IMAP4 em TCP/143;
- disponibilizar POP3 em TCP/110;
- autenticar e recuperar mensagens;
- validar configuração, serviço, portas, usuários e Maildir;
- diagnosticar uma falha de acesso à caixa postal.

Nesta etapa, as credenciais serão observadas sem TLS somente na rede isolada do laboratório.

## 1. Arquitetura

~~~text
SMTP
  ↓
Postfix
  ↓
Maildir de bob
  ↑
  ├── IMAP4 TCP/143
  └── POP3  TCP/110
  ↑
cliente
~~~

SMTP transporta e entrega mensagens.

IMAP e POP3 permitem acesso às mensagens armazenadas.

## 2. Prepare o estado anterior

~~~bash
systemctl is-active postfix
postconf home_mailbox
sudo find /home/bob/Maildir -maxdepth 2 -type f
~~~

Garanta que bob possua ao menos uma mensagem.

## 3. Instale o Dovecot

~~~bash
sudo apt update
sudo apt install -y dovecot-core dovecot-imapd dovecot-pop3d tcpdump
~~~

## 4. Configure os protocolos

Em `/etc/dovecot/dovecot.conf`:

~~~conf
protocols = imap pop3
~~~

Em `/etc/dovecot/conf.d/10-mail.conf`:

~~~conf
mail_location = maildir:~/Maildir
~~~

Em `/etc/dovecot/conf.d/10-auth.conf`:

~~~conf
disable_plaintext_auth = no
auth_mechanisms = plain login
~~~

## 5. Valide antes de reiniciar

~~~bash
sudo doveconf -n
sudo systemctl restart dovecot
systemctl is-active dovecot
sudo ss -lntp | grep -E ':(110|143)\b'
~~~

## 6. Teste IMAP4

~~~bash
nc 192.168.50.10 143
~~~

~~~text
a1 LOGIN bob SENHA_TEMPORARIA
a2 SELECT INBOX
a3 FETCH 1 BODY[]
a4 LOGOUT
~~~

## 7. Teste POP3

~~~bash
nc 192.168.50.10 110
~~~

~~~text
USER bob
PASS SENHA_TEMPORARIA
STAT
LIST
RETR 1
QUIT
~~~

## 8. Observe o tráfego

No servidor:

~~~bash
sudo tcpdump -ni lab0 -nn -A   'tcp port 110 or tcp port 143'
~~~

Repita uma autenticação usando apenas a senha temporária.

Registre o que ficou visível.

## 9. Ferramentas de diagnóstico e validação

~~~bash
sudo doveconf -n
systemctl status dovecot --no-pager
sudo ss -lntp | grep -E ':(110|143)\b'
sudo journalctl -u dovecot -n 60 --no-pager
sudo find /home/bob/Maildir -maxdepth 2 -type f
id bob
sudo ls -ld /home/bob /home/bob/Maildir
nc 192.168.50.10 143
nc 192.168.50.10 110
~~~

Essas ferramentas permitem separar falha de porta, serviço, autenticação e armazenamento.

## 10. Troubleshooting

O professor introduzirá uma falha relacionada ao acesso à caixa postal.

Possíveis sintomas:

~~~text
A porta responde, mas o login falha.
~~~

ou:

~~~text
O SMTP entrega a mensagem, mas o usuário não a encontra no IMAP.
~~~

Você receberá o sintoma e o estado esperado, não o roteiro de correção.

## 11. Portfólio

~~~text
email/aula-20/
├── README.md
└── dovecot-config.txt
~~~

Gere:

~~~bash
sudo doveconf -n > ~/dovecot-config.txt
~~~

Documente IMAP, POP3, Maildir, captura, ferramentas e troubleshooting.
