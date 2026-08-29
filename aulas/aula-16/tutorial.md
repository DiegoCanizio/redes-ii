# Aula 16 — FTP com vsftpd

## Objetivo

Configurar FTP e observar:

```text
controle
dados
modo ativo
modo passivo
credenciais em texto claro
```

> Use somente a rede interna `REDES2`.

---

# Bloco 0

Servidor:

```bash
sudo apt update
sudo apt install -y vsftpd tcpdump
```

Cliente:

```bash
sudo apt update
sudo apt install -y lftp tcpdump git gh
```

Prepare seu portfólio.

---

# Parte 1 — Crie um usuário de laboratório

Servidor:

```bash
sudo adduser ftpuser
```

Crie uma senha **temporária exclusiva desta aula**.

Não reutilize senha pessoal, do GitHub ou institucional.

Crie:

```bash
sudo -u ftpuser bash -c \
  'echo "Arquivo do servidor FTP" > /home/ftpuser/servidor.txt'
```

---

# Parte 2 — Configure vsftpd

Backup:

```bash
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.original
```

Edite:

```bash
sudo nano /etc/vsftpd.conf
```

Use:

```conf
listen=YES
listen_ipv6=NO

anonymous_enable=NO
local_enable=YES
write_enable=YES

chroot_local_user=YES
allow_writeable_chroot=YES

pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40010
```

Reinicie:

```bash
sudo systemctl restart vsftpd
```

Verifique:

```bash
systemctl status vsftpd --no-pager
ss -lntp | grep ':21'
```

---

# Parte 3 — Transferência em modo passivo

Cliente:

```bash
echo "Arquivo enviado pelo cliente" > arquivo-cliente.txt
```

Conecte:

```bash
lftp -u ftpuser ftp://192.168.50.10
```

Informe a senha quando solicitado.

Dentro do `lftp`:

```text
ls
get servidor.txt
put arquivo-cliente.txt
bye
```

Confira os arquivos.

---

# Parte 4 — Modo ativo

Conecte novamente.

Dentro do `lftp`:

```text
set ftp:passive-mode false
ls
```

Depois:

```text
set ftp:passive-mode true
```

Complete:

```text
Modo passivo:
____________________________________________________________

Modo ativo:
____________________________________________________________
```

---

# Parte 5 — Capture o canal de controle

Servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn -A 'tcp port 21'
```

No cliente, faça novo login.

Procure:

```text
USER
PASS
```

Pergunta:

### A credencial ficou protegida por criptografia?

```text
☐ Sim
☐ Não
```

---

# Parte 6 — Observe portas passivas

Servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn \
  'tcp port 21 or portrange 40000-40010'
```

No cliente, faça uma transferência.

Procure conexão:

```text
TCP/21
```

e uma porta:

```text
40000–40010
```

---

# Parte 7 — Incidente

O professor introduzirá uma restrição de escrita.

Teste:

```text
login
listagem
download
upload
```

Registre:

```text
O que continuou funcionando?
____________________________________________________________

O que falhou?
____________________________________________________________

Evidência:
____________________________________________________________
```

---

# Parte 8 — Portfólio

```text
transferencia/aula-16/
├── README.md
└── vsftpd.conf
```

README:

```markdown
# Aula 16 — FTP

## Serviço
- endereço:
- porta de controle:

## Modos
### Passivo
### Ativo

## Transferências

## Captura
Quais informações apareceram em texto claro?

## Segurança
Por que uma senha real não deve ser reutilizada neste experimento?

## Incidente
### Sintoma
### Evidência
### Causa
### Correção
```

**Não inclua a senha no README.**

Versione:

```bash
git add transferencia/aula-16
git commit -m "Aula 16 - configura e analisa FTP"
git push
gh auth logout
```

---

# Próxima aula

SFTP e SCP sobre SSH.
