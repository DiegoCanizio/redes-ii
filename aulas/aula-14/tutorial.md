# Aula 14 — HTTPS, TLS e certificados

## Objetivo

Transformar:

```text
http://web.empresa.test
```

em:

```text
https://web.empresa.test
```

usando TLS e um certificado autoassinado de laboratório.

---

# Bloco 0

Servidor:

```bash
sudo apt update
sudo apt install -y nginx openssl tcpdump
```

Cliente:

```bash
sudo apt update
sudo apt install -y curl openssl tcpdump git gh
```

Reconstrua o site `web.empresa.test` da Aula 13.

Prepare seu portfólio.

---

# Parte 1 — Gere chave e certificado

Servidor:

```bash
sudo openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout /etc/ssl/private/web.empresa.test.key \
  -out /etc/ssl/certs/web.empresa.test.crt \
  -days 30 \
  -subj "/CN=web.empresa.test" \
  -addext "subjectAltName=DNS:web.empresa.test"
```

Proteja a chave:

```bash
sudo chmod 600 /etc/ssl/private/web.empresa.test.key
```

---

# Parte 2 — Diferencie os arquivos

Complete:

```text
.key:
____________________________________________________________

.crt:
____________________________________________________________
```

Qual deles nunca deve ser publicado?

```text
____________________________________
```

---

# Parte 3 — Inspecione o certificado

```bash
openssl x509 -in /etc/ssl/certs/web.empresa.test.crt \
  -noout -subject -issuer -dates -ext subjectAltName
```

Registre:

```text
Subject:
____________________________________________________________

Issuer:
____________________________________________________________

Validade:
____________________________________________________________
```

---

# Parte 4 — Configure Nginx

Edite o site:

```nginx
server {
    listen 443 ssl;
    listen [::]:443 ssl;

    server_name web.empresa.test;

    root /var/www/web;
    index index.html;

    ssl_certificate /etc/ssl/certs/web.empresa.test.crt;
    ssl_certificate_key /etc/ssl/private/web.empresa.test.key;
}
```

Valide:

```bash
sudo nginx -t
```

Depois:

```bash
sudo systemctl reload nginx
```

Verifique:

```bash
ss -lntp | grep ':443'
```

---

# Parte 5 — Teste a confiança

Cliente:

```bash
curl -v --resolve web.empresa.test:443:192.168.50.10 \
  https://web.empresa.test/
```

Registre o erro:

____________________________________________________________________

Por que ocorreu?

____________________________________________________________________

---

# Parte 6 — Teste conscientemente ignorando confiança

```bash
curl -vk --resolve web.empresa.test:443:192.168.50.10 \
  https://web.empresa.test/
```

A página deve aparecer.

`-k` significa que o cliente:

____________________________________________________________________

---

# Parte 7 — Observe TLS

```bash
openssl s_client \
  -connect 192.168.50.10:443 \
  -servername web.empresa.test
```

Procure:

```text
subject
issuer
cipher
Verify return code
```

---

# Parte 8 — Capture

Servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn -A 'tcp port 443'
```

Cliente:

```bash
curl -sk --resolve web.empresa.test:443:192.168.50.10 \
  https://web.empresa.test/
```

Pergunta:

### Você conseguiu ler diretamente o HTML como no HTTP da Aula 12?

```text
☐ Sim
☐ Não
```

---

# Parte 9 — Proteja seu Git

No diretório da Aula 14, crie ou atualize `.gitignore`:

```gitignore
*.key
```

**Não copie a chave privada para o portfólio.**

---

# Parte 10 — Portfólio

```text
web/aula-14/
├── README.md
├── web-https.nginx
└── web.empresa.test.crt
```

O `.crt` é público e pode ser incluído para fins didáticos. A `.key` não.

README:

```markdown
# Aula 14 — HTTPS/TLS

## Certificado
- subject:
- issuer:
- SAN:
- validade:

## Chave privada
Explique por que não deve ser versionada.

## Nginx
- porta:
- validação:

## Cliente
- resultado sem `-k`:
- resultado com `-k`:

## TLS
- cipher/protocolo observado:

## Comparação HTTP × HTTPS
```

Versione:

```bash
git add web/aula-14
git status
git commit -m "Aula 14 - configura HTTPS com TLS"
git push
gh auth logout
```

Confirme antes do commit que nenhum `.key` foi adicionado.

---

# Próxima aula

Logs, backend e proxy reverso.
