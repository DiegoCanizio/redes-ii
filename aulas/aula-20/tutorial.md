# Aula 20 — POP3 e IMAP com Dovecot

## Objetivo

Acessar remotamente a caixa postal de:

```text
bob@empresa.test
```

usando:

```text
IMAP → TCP/143
POP3 → TCP/110
```

> Nesta aula, sem TLS apenas para observação na rede isolada.

---

# Bloco 0

Servidor:

```bash
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y postfix
sudo apt install -y dovecot-core dovecot-imapd dovecot-pop3d tcpdump
```

Cliente:

```bash
sudo apt update
sudo apt install -y netcat-openbsd git gh
```

Reconstrua o Postfix, usuários e Maildir da Aula 19.

Garanta que `bob` tenha pelo menos uma mensagem.

---

# Parte 1 — Configure protocolos

Servidor:

```bash
sudo nano /etc/dovecot/dovecot.conf
```

Garanta:

```conf
protocols = imap pop3
```

---

# Parte 2 — Maildir

```bash
sudo nano /etc/dovecot/conf.d/10-mail.conf
```

Defina:

```conf
mail_location = maildir:~/Maildir
```

---

# Parte 3 — Autenticação da aula

```bash
sudo nano /etc/dovecot/conf.d/10-auth.conf
```

Use:

```conf
disable_plaintext_auth = no
auth_mechanisms = plain login
```

Essa configuração é **somente para a aula isolada**.

---

# Parte 4 — Valide

```bash
sudo doveconf -n
```

Depois:

```bash
sudo systemctl restart dovecot
```

Verifique:

```bash
ss -lntp | grep -E ':(110|143)\b'
```

---

# Parte 5 — IMAP

Cliente:

```bash
nc 192.168.50.10 143
```

Use:

```text
a1 LOGIN bob <SENHA-DE-LABORATORIO>
a2 SELECT INBOX
a3 FETCH 1 BODY[]
a4 LOGOUT
```

Registre o que ocorreu.

---

# Parte 6 — POP3

```bash
nc 192.168.50.10 110
```

Use:

```text
USER bob
PASS <SENHA-DE-LABORATORIO>
STAT
LIST
RETR 1
QUIT
```

---

# Parte 7 — Compare

| Item | IMAP | POP3 |
|---|---|---|
| Porta desta aula | | |
| Login funcionou? | | |
| Mensagem permaneceu no servidor? | | |
| Comandos observados | | |

Não conclua que POP3 obrigatoriamente apaga mensagens; isso depende da operação realizada.

---

# Parte 8 — Capture

Servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn -A \
  'tcp port 110 or tcp port 143'
```

Faça novo login usando apenas a senha temporária de laboratório.

Pergunta:

### A senha ficou visível?

```text
☐ Sim
☐ Não
```

---

# Parte 9 — Incidente de autenticação

Use uma senha incorreta.

Registre:

```text
A porta respondeu?
____________________________________________________________

O serviço respondeu?
____________________________________________________________

A autenticação funcionou?
____________________________________________________________
```

Consulte no servidor:

```bash
sudo journalctl -u dovecot -n 30
```

---

# Parte 10 — Portfólio

Crie:

```text
email/aula-20/
├── README.md
└── dovecot-config.txt
```

No servidor:

```bash
sudo doveconf -n > ~/dovecot-config.txt
```

Copie para o portfólio.

README:

```markdown
# Aula 20 — Dovecot

## IMAP
- porta:
- comandos:

## POP3
- porta:
- comandos:

## Comparação

## Captura
O que ficou visível?

## Segurança
Por que a configuração desta aula não deve ser usada em uma rede não confiável?

## Incidente
```

Nunca registre a senha.

Versione e encerre a autenticação.

---

# Próxima aula

TLS para SMTP, IMAP e POP3.
