# Aula 21 — TLS no e-mail

## Objetivo

Proteger:

```text
SMTP
IMAP
POP3
```

com TLS.

---

# Bloco 0

Reconstrua Postfix + Dovecot.

Servidor:

```bash
sudo apt update
sudo apt install -y postfix dovecot-core dovecot-imapd dovecot-pop3d openssl tcpdump
```

Cliente:

```bash
sudo apt update
sudo apt install -y openssl git gh
```

---

# Parte 1 — Gere certificado

Servidor:

```bash
sudo openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout /etc/ssl/private/mail.empresa.test.key \
  -out /etc/ssl/certs/mail.empresa.test.crt \
  -days 30 \
  -subj "/CN=mail.empresa.test" \
  -addext "subjectAltName=DNS:mail.empresa.test"
```

Proteja:

```bash
sudo chmod 600 /etc/ssl/private/mail.empresa.test.key
```

---

# Parte 2 — Postfix

```bash
sudo postconf -e \
  'smtpd_tls_cert_file = /etc/ssl/certs/mail.empresa.test.crt'
```

```bash
sudo postconf -e \
  'smtpd_tls_key_file = /etc/ssl/private/mail.empresa.test.key'
```

```bash
sudo postconf -e 'smtpd_tls_security_level = may'
```

Valide:

```bash
sudo postfix check
sudo systemctl restart postfix
```

---

# Parte 3 — Dovecot

Edite:

```bash
sudo nano /etc/dovecot/conf.d/10-ssl.conf
```

Use:

```conf
ssl = required
ssl_cert = </etc/ssl/certs/mail.empresa.test.crt
ssl_key = </etc/ssl/private/mail.empresa.test.key
```

Em `10-auth.conf`:

```conf
disable_plaintext_auth = yes
```

Valide:

```bash
sudo doveconf -n
sudo systemctl restart dovecot
```

---

# Parte 4 — Verifique portas

```bash
ss -lntp | grep -E ':(25|993|995)\b'
```

---

# Parte 5 — SMTP com STARTTLS

Cliente:

```bash
openssl s_client \
  -connect 192.168.50.10:25 \
  -starttls smtp \
  -servername mail.empresa.test
```

Após o handshake:

```text
EHLO cli.empresa.test
QUIT
```

---

# Parte 6 — IMAPS

```bash
openssl s_client \
  -connect 192.168.50.10:993 \
  -servername mail.empresa.test
```

Depois:

```text
a1 LOGIN bob <SENHA-DE-LABORATORIO>
a2 SELECT INBOX
a3 LOGOUT
```

---

# Parte 7 — POP3S

```bash
openssl s_client \
  -connect 192.168.50.10:995 \
  -servername mail.empresa.test
```

Depois:

```text
USER bob
PASS <SENHA-DE-LABORATORIO>
STAT
QUIT
```

---

# Parte 8 — Capture

Servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn -A \
  'tcp port 25 or tcp port 993 or tcp port 995'
```

Pergunta:

### A senha apareceu em texto claro como na Aula 20?

```text
☐ Sim
☐ Não
```

### O endereço IP e a porta ainda são observáveis?

```text
☐ Sim
☐ Não
```

---

# Parte 9 — Portfólio

```text
email/aula-21/
├── README.md
├── mail.empresa.test.crt
└── tls-parametros.txt
```

**Nunca copie a chave `.key`.**

README:

```markdown
# Aula 21 — TLS no e-mail

## Certificado
- CN:
- SAN:
- validade:
- autoassinado:

## SMTP
- STARTTLS:

## IMAP
- porta segura:

## POP3
- porta segura:

## Captura
O que ficou protegido?
O que continuou observável?

## Segurança
Explique por que a chave privada não deve ser versionada.
```

Antes do commit:

```bash
git status
```

Confirme que nenhum `.key` aparece.

Versione e encerre a autenticação.

---

# Próxima aula

Firewall com nftables.
