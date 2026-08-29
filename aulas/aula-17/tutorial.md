# Aula 17 — SFTP e SCP

## Objetivo

Comparar a transferência insegura da Aula 16 com transferência sobre SSH.

Hoje você utilizará:

```text
SCP
SFTP
```

em:

```text
TCP/22
```

---

# Bloco 0

Servidor:

```bash
sudo apt update
sudo apt install -y openssh-server tcpdump
sudo systemctl start ssh
```

Cliente:

```bash
sudo apt update
sudo apt install -y openssh-client tcpdump git gh
```

Verifique no servidor:

```bash
systemctl is-active ssh
ss -lntp | grep ':22'
```

Prepare seu portfólio.

---

# Parte 1 — SCP

Cliente:

```bash
echo "Arquivo via SCP" > scp-cliente.txt
```

Envie:

```bash
scp scp-cliente.txt \
  <USUARIO>@192.168.50.10:~/
```

No servidor, confirme.

Depois, no cliente:

```bash
scp <USUARIO>@192.168.50.10:~/scp-cliente.txt \
  scp-retorno.txt
```

---

# Parte 2 — SFTP

Cliente:

```bash
sftp <USUARIO>@192.168.50.10
```

Dentro da sessão:

```text
pwd
lpwd
ls
lls
put scp-cliente.txt
get scp-cliente.txt copia-sftp.txt
bye
```

Explique:

```text
pwd:
____________________________________________________________

lpwd:
____________________________________________________________
```

---

# Parte 3 — Capture SFTP

Servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn -A 'tcp port 22'
```

Cliente: abra SFTP e transfira um arquivo.

Observe.

---

# Parte 4 — Compare com FTP

Complete:

| Observação | FTP | SFTP |
|---|---|---|
| Porta principal | | |
| Usuário visível em texto claro na captura? | | |
| Senha visível em texto claro? | | |
| Conteúdo do arquivo legível diretamente? | | |
| Usa SSH? | | |

---

# Parte 5 — Salve uma captura

Servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn -c 40 \
  -w aula-17-sftp.pcap 'tcp port 22'
```

Faça uma pequena transferência.

---

# Parte 6 — FTP, SFTP e SCP

Complete:

```text
FTP:
____________________________________________________________

SFTP:
____________________________________________________________

SCP:
____________________________________________________________
```

Importante:

> SFTP não é “FTP na porta 22”. Ele é um protocolo de transferência sobre SSH.

---

# Parte 7 — Incidente de permissão

Servidor:

```bash
sudo mkdir -p /srv/restrito
sudo chmod 755 /srv/restrito
sudo chown root:root /srv/restrito
```

No SFTP, tente enviar um arquivo para:

```text
/srv/restrito/
```

Registre a mensagem.

---

# Parte 8 — Diagnostique

Perguntas:

### A conexão SSH/SFTP funcionou?

```text
☐ Sim
☐ Não
```

### A autenticação funcionou?

```text
☐ Sim
☐ Não
```

### Então a falha está necessariamente na rede?

```text
☐ Sim
☐ Não
```

Servidor:

```bash
ls -ld /srv/restrito
id
```

Registre:

```text
Sintoma:
____________________________________________________________

Evidência:
____________________________________________________________

Causa:
____________________________________________________________
```

---

# Parte 9 — Portfólio

```text
transferencia/aula-17/
├── README.md
└── aula-17-sftp.pcap
```

README:

```markdown
# Aula 17 — SFTP e SCP

## SCP

## SFTP

## Comparação com FTP

| Item | FTP | SFTP/SCP |
|---|---|---|
| Porta | | |
| Criptografia | | |
| Credenciais em claro | | |
| Conteúdo em claro | | |

## Captura
O que continuou observável?
O que não apareceu em texto claro?

## Incidente de permissão
### Sintoma
### Evidência
### Causa

## Síntese
Explique por que SFTP e FTP não devem ser tratados como o mesmo protocolo.
```

Versione:

```bash
git add transferencia/aula-17
git commit -m "Aula 17 - compara SFTP SCP e FTP"
git push
gh auth logout
```

---

# Próximo bloco

Arquitetura de e-mail, SMTP, Postfix, POP3, IMAP e TLS.
