# Aula 12 — HTTP por dentro

## Objetivo

Hoje você observará HTTP antes de configurar Nginx.

Rede:

```text
srv-redes2 → 192.168.50.10/24
cli-redes2 → 192.168.50.20/24
```

Servidor HTTP da aula:

```text
TCP/8000
```

---

# Bloco 0

## Servidor

```bash
sudo apt update
sudo apt install -y python3 tcpdump iproute2
```

## Cliente

```bash
sudo apt update
sudo apt install -y curl netcat-openbsd tcpdump git gh
```

Prepare seu portfólio.

---

# Parte 1 — Crie uma página

No servidor:

```bash
mkdir -p ~/http-aula12
cd ~/http-aula12
nano index.html
```

Conteúdo:

```html
<!doctype html>
<html>
  <head><title>Redes II</title></head>
  <body>
    <h1>HTTP funcionando</h1>
    <p>Aula 12 - Redes de Computadores II</p>
  </body>
</html>
```

---

# Parte 2 — Inicie o servidor

```bash
python3 -m http.server 8000 --bind 192.168.50.10
```

Mantenha o terminal aberto.

Em outro terminal:

```bash
ss -lntp | grep ':8000'
```

---

# Parte 3 — Teste com curl

No cliente:

```bash
curl http://192.168.50.10:8000/
```

Depois:

```bash
curl -I http://192.168.50.10:8000/
```

Registre o status:

```text
____________________________________
```

---

# Parte 4 — Veja a conversa HTTP

```bash
curl -v http://192.168.50.10:8000/
```

Observe:

```text
> requisição
< resposta
```

Localize:

```text
GET /
Host:
HTTP/... 200
```

---

# Parte 5 — Recurso inexistente

```bash
curl -v http://192.168.50.10:8000/arquivo-que-nao-existe
```

Código:

```text
____________________________________
```

Pergunta:

### O servidor respondeu?

```text
☐ Sim
☐ Não
```

### Então um 404 significa que a rede está fora?

```text
☐ Sim
☐ Não
```

Explique:

____________________________________________________________________

---

# Parte 6 — Faça uma requisição manual

```bash
nc 192.168.50.10 8000
```

Digite:

```text
GET / HTTP/1.1
Host: 192.168.50.10
Connection: close

```

Depois de `Connection: close`, deixe uma linha em branco.

Observe a resposta.

---

# Parte 7 — Capture HTTP

No servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn -A 'tcp port 8000'
```

No cliente:

```bash
curl http://192.168.50.10:8000/
```

Procure conteúdo legível na captura.

Pergunta:

### O conteúdo HTTP apareceu em texto claro?

```text
☐ Sim
☐ Não
```

---

# Parte 8 — Salve uma captura

Servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn -c 30 \
  -w aula-12-http.pcap 'tcp port 8000'
```

Cliente:

```bash
curl http://192.168.50.10:8000/
```

---

# Parte 9 — Compare dois problemas

## Caso A

```bash
curl -v http://192.168.50.10:8000/inexistente.html
```

Resultado:

```text
____________________________________
```

## Caso B

Pare o servidor Python com `Ctrl+C`.

Depois, no cliente:

```bash
curl -v http://192.168.50.10:8000/
```

Resultado:

```text
____________________________________
```

Explique a diferença:

____________________________________________________________________

____________________________________________________________________

---

# Parte 10 — Portfólio

Crie:

```text
web/aula-12/
├── README.md
└── aula-12-http.pcap
```

README sugerido:

```markdown
# Aula 12 — HTTP

## Servidor
- endereço:
- porta:

## Requisição observada

## Resposta observada

## Códigos
- 200:
- 404:

## Diagnóstico
Explique a diferença entre:
- recurso inexistente;
- serviço HTTP indisponível.

## Captura
O que foi possível ler em texto claro?
```

Versione:

```bash
git add web/aula-12
git commit -m "Aula 12 - registra funcionamento do HTTP"
git push
gh auth logout
```

---

# Próxima aula

Nginx, virtual hosts e nomes DNS.
