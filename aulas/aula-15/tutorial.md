# Aula 15 — Logs e proxy reverso com Nginx

## Objetivo

Construir:

```text
cliente
  ↓
Nginx :80
  ↓
backend :8080
```

e diagnosticar o que acontece quando o backend falha.

---

# Bloco 0

Servidor:

```bash
sudo apt update
sudo apt install -y nginx curl python3
```

Cliente:

```bash
sudo apt update
sudo apt install -y curl git gh
```

Reconstrua seu Nginx da Aula 13.

---

# Parte 1 — Observe logs

Servidor:

```bash
sudo tail -f /var/log/nginx/access.log
```

Em outro terminal:

```bash
sudo tail -f /var/log/nginx/error.log
```

Cliente:

```bash
curl -I http://192.168.50.10/
curl -v http://192.168.50.10/
```

Relacione as requisições com o `access.log`.

---

# Parte 2 — Crie o backend

Servidor:

```bash
mkdir -p ~/backend-aula15
cd ~/backend-aula15
echo '<h1>Backend da Aula 15</h1>' > index.html
```

Inicie:

```bash
python3 -m http.server 8080 --bind 127.0.0.1
```

Em outro terminal:

```bash
curl http://127.0.0.1:8080/
```

Verifique:

```bash
ss -lntp | grep ':8080'
```

---

# Parte 3 — Proxy reverso

No Nginx, adicione:

```nginx
location /app/ {
    proxy_pass http://127.0.0.1:8080/;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

Antes de qualquer reload:

```bash
sudo nginx -t
```

Depois:

```bash
sudo systemctl reload nginx
```

---

# Parte 4 — Teste

Cliente:

```bash
curl -v http://192.168.50.10/app/
```

Resultado esperado:

```text
Backend da Aula 15
```

---

# Parte 5 — Explique o fluxo

Complete:

```text
Cliente envia para: __________________________

Quem recebe primeiro? ________________________

Quem acessa 127.0.0.1:8080? _________________
```

---

# Parte 6 — Incidente

Pare o backend Python.

No cliente:

```bash
curl -v http://192.168.50.10/app/
```

Status observado:

```text
____________________________________
```

Não reinicie ainda.

---

# Parte 7 — Produza evidências

Servidor:

```bash
sudo tail -n 20 /var/log/nginx/error.log
```

```bash
ss -lntp | grep ':8080'
```

```bash
curl http://127.0.0.1:8080/
```

Preencha:

```text
Sintoma:
____________________________________________________________

Hipótese:
____________________________________________________________

Evidência:
____________________________________________________________

Causa:
____________________________________________________________
```

---

# Parte 8 — Corrija e valide

Reinicie o backend:

```bash
cd ~/backend-aula15
python3 -m http.server 8080 --bind 127.0.0.1
```

Cliente:

```bash
curl http://192.168.50.10/app/
```

---

# Parte 9 — Portfólio

```text
web/aula-15/
├── README.md
└── reverse-proxy.nginx
```

README:

```markdown
# Aula 15 — Operação Web

## Fluxo
cliente → Nginx → backend

## Backend
- endereço:
- porta:

## Proxy
- caminho externo:
- destino interno:

## Logs

## Incidente
### Sintoma
### Hipótese
### Testes
### Evidência
### Causa
### Correção
### Validação
```

Versione:

```bash
git add web/aula-15
git commit -m "Aula 15 - configura proxy reverso"
git push
gh auth logout
```

---

# Próxima aula

FTP, conexões de controle/dados e exposição de credenciais em texto claro.
