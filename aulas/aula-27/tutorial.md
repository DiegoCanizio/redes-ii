# Aula 27 — Docker

## Objetivo

Executar um servidor Web em container e reconstruí-lo a partir de arquivos persistentes.

---

# Bloco 0

Servidor:

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable --now docker
```

Verifique:

```bash
sudo docker version
```

Cliente:

```bash
sudo apt update
sudo apt install -y curl git gh
```

Prepare seu portfólio.

---

# Parte 1 — Primeiro container

Servidor:

```bash
sudo docker run --name web-aula27 nginx:alpine
```

Interrompa com:

```text
Ctrl+C
```

Liste:

```bash
sudo docker ps -a
```

O container ainda existe?

```text
☐ Sim
☐ Não
```

---

# Parte 2 — Background e porta

Remova:

```bash
sudo docker rm web-aula27
```

Execute:

```bash
sudo docker run -d \
  --name web-aula27 \
  -p 8080:80 \
  nginx:alpine
```

Veja:

```bash
sudo docker ps
```

Cliente:

```bash
curl http://192.168.50.10:8080/
```

---

# Parte 3 — Interprete

```text
8080:
____________________________________________________________

80:
____________________________________________________________
```

---

# Parte 4 — Logs

```bash
sudo docker logs web-aula27
```

Faça outra requisição no cliente.

Depois:

```bash
sudo docker logs --tail 20 web-aula27
```

---

# Parte 5 — Execute comando no container

```bash
sudo docker exec web-aula27 \
  nginx -v
```

Depois:

```bash
sudo docker exec web-aula27 \
  ls -l /usr/share/nginx/html
```

---

# Parte 6 — Ciclo de vida

```bash
sudo docker stop web-aula27
```

Teste do cliente.

Depois:

```bash
sudo docker start web-aula27
```

Teste novamente.

---

# Parte 7 — Conteúdo externo ao container

Servidor:

```bash
mkdir -p ~/docker-aula27/site
```

```bash
echo '<h1>Site versionado da Aula 27</h1>' \
  > ~/docker-aula27/site/index.html
```

Remova:

```bash
sudo docker rm -f web-aula27
```

Recrie:

```bash
sudo docker run -d \
  --name web-aula27 \
  -p 8080:80 \
  -v "$HOME/docker-aula27/site:/usr/share/nginx/html:ro" \
  nginx:alpine
```

Cliente:

```bash
curl http://192.168.50.10:8080/
```

---

# Parte 8 — Destrua e reconstrua

Servidor:

```bash
sudo docker rm -f web-aula27
```

O arquivo ainda existe?

```bash
cat ~/docker-aula27/site/index.html
```

Agora recrie o container com o mesmo comando.

---

# Parte 9 — Compare VM e container

Complete:

| Aspecto | VM | Container |
|---|---|---|
| kernel próprio | | |
| sistema operacional completo | | |
| processo isolado | | |
| imagem para reconstrução | | |

---

# Parte 10 — Portfólio

```text
containers/aula-27/
├── README.md
└── site/
    └── index.html
```

README:

```markdown
# Aula 27 — Docker

## Imagem

## Container

## Porta
- host:
- container:

## Bind mount

## Reconstrução
Registre o comando necessário.

## VM × container
Explique a principal diferença.
```

Versione e encerre a autenticação.

---

# Próxima aula

Docker Compose e múltiplos serviços.
