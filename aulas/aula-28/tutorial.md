# Aula 28 — Docker Compose

## Objetivo

Declarar e reconstruir:

```text
cliente
  ↓
192.168.50.10:8080
  ↓
Nginx container
  ↓
app container:8000
```

---

# Bloco 0

Servidor:

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2
sudo systemctl enable --now docker
```

Verifique:

```bash
sudo docker compose version
```

Cliente:

```bash
sudo apt update
sudo apt install -y curl git gh
```

Recupere seu portfólio.

---

# Parte 1 — Estrutura

No portfólio:

```bash
mkdir -p containers/aula-28/nginx
mkdir -p containers/aula-28/app
cd containers/aula-28
```

---

# Parte 2 — Backend

Crie:

```bash
nano app/index.html
```

Conteúdo:

```html
<h1>Aplicacao interna - Aula 28</h1>
<p>Resposta fornecida pelo servico app.</p>
```

---

# Parte 3 — Nginx

Crie:

```bash
nano nginx/default.conf
```

Use:

```nginx
server {
    listen 80;

    location / {
        proxy_pass http://app:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

# Parte 4 — Compose

Crie:

```bash
nano compose.yaml
```

Use:

```yaml
services:
  app:
    image: python:3.12-alpine
    working_dir: /site
    command: python -m http.server 8000
    volumes:
      - ./app:/site:ro

  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - app
```

---

# Parte 5 — Suba

```bash
sudo docker compose up -d
```

Veja:

```bash
sudo docker compose ps
```

Cliente:

```bash
curl http://192.168.50.10:8080/
```

---

# Parte 6 — Perguntas

### Qual porta foi publicada no host?

```text
____________________________________
```

### O serviço `app` publicou a porta 8000 no host?

```text
☐ Sim
☐ Não
```

### Como o Nginx encontra `app`?

____________________________________________________________________

---

# Parte 7 — Logs

```bash
sudo docker compose logs web
```

```bash
sudo docker compose logs app
```

---

# Parte 8 — DNS interno do Compose

Servidor:

```bash
sudo docker compose exec web \
  getent hosts app
```

Resultado:

____________________________________________________________________

---

# Parte 9 — Destrua e reconstrua

```bash
sudo docker compose down
```

Depois:

```bash
sudo docker compose up -d
```

Cliente:

```bash
curl http://192.168.50.10:8080/
```

---

# Parte 10 — Incidente

Altere temporariamente:

```nginx
proxy_pass http://backend:8000;
```

Aplique/reinicie conforme orientação.

Teste.

Depois use:

```bash
sudo docker compose ps
sudo docker compose logs web
sudo docker compose exec web getent hosts app
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

Restaure:

```nginx
proxy_pass http://app:8000;
```

---

# Parte 11 — README

Crie:

```bash
nano README.md
```

Use:

```markdown
# Aula 28 — Docker Compose

## Arquitetura

## Serviços
### web
### app

## Portas

## Rede interna
Como `web` encontra `app`?

## Reconstrução
Comandos necessários:

## Incidente
### Sintoma
### Evidência
### Causa
### Correção
### Validação
```

Versione:

```bash
git add containers/aula-28
git commit -m "Aula 28 - declara infraestrutura com Compose"
git push
gh auth logout
```

---

# Próxima aula

Projeto integrado e comissionamento.
