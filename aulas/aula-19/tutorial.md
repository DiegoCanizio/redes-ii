# Aula 19 — Configurando Postfix

## Objetivo

Construir um servidor SMTP local:

```text
mail.empresa.test
```

para:

```text
empresa.test
```

Sem envio externo.

---

# Bloco 0

Servidor:

```bash
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y postfix
```

Cliente:

```bash
sudo apt update
sudo apt install -y netcat-openbsd git gh
```

Crie, no servidor:

```bash
sudo adduser alice
sudo adduser bob
```

Use senhas temporárias de laboratório.

Prepare seu portfólio.

---

# Parte 1 — Configure o Postfix

Servidor:

```bash
sudo postconf -e 'myhostname = mail.empresa.test'
sudo postconf -e 'mydomain = empresa.test'
sudo postconf -e 'myorigin = $mydomain'
sudo postconf -e 'inet_interfaces = all'
sudo postconf -e 'inet_protocols = ipv4'
sudo postconf -e 'mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain'
sudo postconf -e 'mynetworks = 127.0.0.0/8, 192.168.50.0/24'
sudo postconf -e 'home_mailbox = Maildir/'
```

---

# Parte 2 — Explique

Complete:

| Parâmetro | Função |
|---|---|
| `myhostname` | |
| `mydomain` | |
| `myorigin` | |
| `mydestination` | |
| `mynetworks` | |
| `home_mailbox` | |

---

# Parte 3 — Maildir

```bash
sudo -u alice mkdir -p /home/alice/Maildir/{cur,new,tmp}
sudo -u bob mkdir -p /home/bob/Maildir/{cur,new,tmp}
```

---

# Parte 4 — Valide

```bash
sudo postfix check
```

Depois:

```bash
sudo systemctl restart postfix
```

Verifique:

```bash
systemctl is-active postfix
ss -lntp | grep ':25'
```

---

# Parte 5 — Veja a configuração efetiva

```bash
postconf -n
```

---

# Parte 6 — Envie

Cliente:

```bash
nc 192.168.50.10 25
```

Use:

```text
EHLO cli.empresa.test
MAIL FROM:<alice@empresa.test>
RCPT TO:<bob@empresa.test>
DATA
Subject: Aula 19

Mensagem entregue pelo Postfix configurado pela turma.
.
QUIT
```

---

# Parte 7 — Confirme

Servidor:

```bash
sudo find /home/bob/Maildir/new -maxdepth 1 -type f
```

Leia uma mensagem:

```bash
sudo sed -n '1,80p' <ARQUIVO>
```

---

# Parte 8 — Fila

```bash
postqueue -p
```

Resultado:

____________________________________________________________________

---

# Parte 9 — Logs

```bash
sudo journalctl -u postfix -n 50
```

Se o professor indicar:

```bash
sudo tail -n 50 /var/log/mail.log
```

---

# Parte 10 — Incidente

O professor alterará temporariamente um parâmetro relacionado aos destinos locais.

Não corrija imediatamente.

Use:

```bash
postconf mydestination
sudo postfix check
sudo journalctl -u postfix -n 30
```

Registre:

```text
Sintoma:
____________________________________________________________

Evidência:
____________________________________________________________

Causa:
____________________________________________________________

Correção:
____________________________________________________________
```

---

# Parte 11 — Portfólio

Crie:

```text
email/aula-19/
├── README.md
└── postfix-parametros.txt
```

No servidor:

```bash
postconf -n > ~/postfix-parametros.txt
```

Copie o arquivo para seu portfólio com `scp`.

README:

```markdown
# Aula 19 — Postfix

## Identidade
- hostname:
- domínio:

## Entrega local
- mydestination:
- Maildir:

## Testes
- TCP/25:
- mensagem:
- fila:
- logs:

## Incidente
### Sintoma
### Evidência
### Causa
### Correção
### Validação
```

Versione e encerre a autenticação.

---

# Próxima aula

Dovecot: POP3 e IMAP.
