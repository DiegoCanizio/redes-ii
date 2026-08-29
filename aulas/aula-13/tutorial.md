# Aula 13 — Nginx, virtual hosts e DNS

## Objetivo

Você hospedará dois sites no mesmo servidor:

```text
web.empresa.test
intranet.empresa.test
```

ambos em:

```text
192.168.50.10
```

---

# Bloco 0

Servidor:

```bash
sudo apt update
sudo apt install -y nginx bind9 bind9-utils dnsutils
```

Cliente:

```bash
sudo apt update
sudo apt install -y curl dnsutils git gh
```

Prepare seu portfólio.

---

# Parte 1 — Verifique o Nginx

```bash
systemctl status nginx
```

```bash
ss -lntp | grep ':80'
```

No cliente:

```bash
curl http://192.168.50.10/
```

---

# Parte 2 — Crie os sites

Servidor:

```bash
sudo mkdir -p /var/www/web /var/www/intranet
```

```bash
echo '<h1>Web - empresa.test</h1>' | \
  sudo tee /var/www/web/index.html
```

```bash
echo '<h1>Intranet - empresa.test</h1>' | \
  sudo tee /var/www/intranet/index.html
```

---

# Parte 3 — Site `web`

```bash
sudo nano /etc/nginx/sites-available/web.empresa.test
```

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name web.empresa.test;

    root /var/www/web;
    index index.html;
}
```

---

# Parte 4 — Site `intranet`

```bash
sudo nano /etc/nginx/sites-available/intranet.empresa.test
```

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name intranet.empresa.test;

    root /var/www/intranet;
    index index.html;
}
```

---

# Parte 5 — Habilite

```bash
sudo ln -s /etc/nginx/sites-available/web.empresa.test /etc/nginx/sites-enabled/
```

```bash
sudo ln -s /etc/nginx/sites-available/intranet.empresa.test /etc/nginx/sites-enabled/
```

```bash
sudo rm -f /etc/nginx/sites-enabled/default
```

Valide:

```bash
sudo nginx -t
```

Se estiver correto:

```bash
sudo systemctl reload nginx
```

---

# Parte 6 — Teste sem depender do DNS

Cliente:

```bash
curl --resolve web.empresa.test:80:192.168.50.10 \
  http://web.empresa.test/
```

```bash
curl --resolve intranet.empresa.test:80:192.168.50.10 \
  http://intranet.empresa.test/
```

As respostas devem ser diferentes.

---

# Parte 7 — O que diferenciou os sites?

Use:

```bash
curl -v --resolve web.empresa.test:80:192.168.50.10 \
  http://web.empresa.test/
```

Observe:

```text
Host: web.empresa.test
```

Explique:

____________________________________________________________________

---

# Parte 8 — Integre ao DNS

Na zona `empresa.test`, adicione:

```dns
web       IN A 192.168.50.10
intranet  IN A 192.168.50.10
```

Atualize o serial.

Valide:

```bash
sudo named-checkzone empresa.test /etc/bind/db.empresa.test
```

Depois:

```bash
sudo systemctl reload bind9
```

Cliente:

```bash
dig @192.168.50.10 web.empresa.test
dig @192.168.50.10 intranet.empresa.test
```

---

# Parte 9 — Logs

Servidor:

```bash
sudo tail -f /var/log/nginx/access.log
```

No cliente, faça requisições.

Depois observe:

```bash
sudo tail -n 20 /var/log/nginx/error.log
```

---

# Parte 10 — Incidente

O professor introduzirá uma inconsistência entre DNS e `server_name`.

Use evidências:

```bash
dig @192.168.50.10 ...
curl -v --resolve ...
sudo nginx -t
sudo nginx -T
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

```text
web/aula-13/
├── README.md
├── web.empresa.test.nginx
└── intranet.empresa.test.nginx
```

README:

```markdown
# Aula 13 — Nginx e virtual hosts

## Sites
- web.empresa.test:
- intranet.empresa.test:

## DNS

## Cabeçalho Host
Explique seu papel.

## Validação
- nginx -t:
- testes HTTP:

## Logs

## Incidente
```

Versione:

```bash
git add web/aula-13
git commit -m "Aula 13 - configura virtual hosts Nginx"
git push
gh auth logout
```

---

# Próxima aula

HTTPS, TLS e certificados.
