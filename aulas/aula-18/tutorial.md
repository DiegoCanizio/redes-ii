# Aula 18 — Arquitetura de e-mail e SMTP

## Objetivo

Entender que e-mail utiliza vários componentes:

```text
SMTP
DNS/MX
caixa postal
POP3/IMAP
```

Hoje o foco será SMTP.

> Todo o experimento permanece dentro da rede `REDES2`.

---

# Bloco 0

Servidor:

```bash
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y postfix tcpdump
```

Cliente:

```bash
sudo apt update
sudo apt install -y netcat-openbsd dnsutils tcpdump git gh
```

Rede:

```text
srv-redes2 → 192.168.50.10
cli-redes2 → 192.168.50.20
```

Prepare seu portfólio.

---

# Parte 1 — Prepare o servidor de observação

O professor fornecerá:

```text
arquivos/aula-18/preparar-postfix-observacao.sh
```

No servidor, execute conforme orientação.

Depois:

```bash
systemctl is-active postfix
```

```bash
ss -lntp | grep ':25'
```

---

# Parte 2 — MUA e MTA

Complete:

```text
MUA:
____________________________________________________________

MTA:
____________________________________________________________
```

O Postfix desta aula atua como:

```text
☐ MUA
☐ MTA
```

---

# Parte 3 — MX

Cliente:

```bash
dig gmail.com MX
```

Se o DNS interno estiver disponível:

```bash
dig @192.168.50.10 empresa.test MX
```

O registro MX informa:

____________________________________________________________________

---

# Parte 4 — Veja parâmetros do Postfix

Servidor:

```bash
postconf myhostname mydomain mydestination home_mailbox
```

Registre:

```text
myhostname:
____________________________________________________________

mydomain:
____________________________________________________________

home_mailbox:
____________________________________________________________
```

---

# Parte 5 — SMTP manual

Cliente:

```bash
nc 192.168.50.10 25
```

Digite:

```text
EHLO cli.empresa.test
MAIL FROM:<alice@empresa.test>
RCPT TO:<bob@empresa.test>
DATA
Subject: Teste da Aula 18
From: alice@empresa.test
To: bob@empresa.test

Mensagem enviada manualmente por SMTP.
.
QUIT
```

---

# Parte 6 — Códigos observados

Preencha conforme sua sessão:

| Código | Em que momento apareceu? |
|---|---|
| 220 | |
| 250 | |
| 354 | |
| 221 | |

---

# Parte 7 — Confirme a entrega

Servidor:

```bash
sudo find /home/bob/Maildir -maxdepth 2 -type f
```

Leia a mensagem indicada pelo professor:

```bash
sudo sed -n '1,80p' <ARQUIVO-DA-MENSAGEM>
```

Pergunta:

### Usamos POP3 ou IMAP para essa entrega?

```text
☐ Sim
☐ Não
```

Explique:

____________________________________________________________________

---

# Parte 8 — Capture SMTP

Servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn -A 'tcp port 25'
```

Cliente: envie outra mensagem curta.

Procure:

```text
MAIL FROM
RCPT TO
Subject
corpo
```

---

# Parte 9 — Destinatário inválido

Cliente:

```bash
nc 192.168.50.10 25
```

Tente:

```text
EHLO cli.empresa.test
MAIL FROM:<alice@empresa.test>
RCPT TO:<naoexiste@empresa.test>
```

Registre a resposta:

____________________________________________________________________

A conexão SMTP funcionou?

```text
☐ Sim
☐ Não
```

O destinatário foi aceito?

```text
☐ Sim
☐ Não
```

---

# Parte 10 — Portfólio

Crie:

```text
email/aula-18/
└── README.md
```

Use:

```markdown
# Aula 18 — SMTP

## Arquitetura
- MUA:
- MTA:
- caixa postal:

## DNS/MX

## SMTP
- servidor:
- porta:
- comandos observados:
- códigos observados:

## Entrega
Como a mensagem chegou à Maildir?

## Captura
O que apareceu em texto claro?

## Síntese
Explique por que SMTP e IMAP/POP3 exercem funções diferentes.
```

Versione:

```bash
git add email/aula-18
git commit -m "Aula 18 - registra arquitetura SMTP"
git push
gh auth logout
```

---

# Próxima aula

Configuração do Postfix.
