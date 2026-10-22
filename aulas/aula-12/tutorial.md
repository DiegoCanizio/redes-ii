# Aula 12 — HTTP por dentro

**Data:** 10/11/2026  
**Duração:** 100 minutos

## Objetivo

Observar o protocolo HTTP antes de configurar Nginx.

Servidor temporário da aula:

```text
srv.empresa.test:8000
```

## 1. Crie uma página

No servidor:

```bash
mkdir -p ~/http-aula12
cd ~/http-aula12
cat > index.html <<'EOF'
<!doctype html>
<html>
  <head><title>Redes II</title></head>
  <body>
    <h1>HTTP funcionando</h1>
    <p>Aula 12 - Redes de Computadores II</p>
  </body>
</html>
EOF
```

## 2. Inicie um servidor simples

```bash
python3 -m http.server 8000 --bind 192.168.50.10
```

Em outro terminal:

```bash
ss -lntp | grep ':8000'
```

## 3. Teste do cliente

```bash
curl http://srv.empresa.test:8000/
curl -I http://srv.empresa.test:8000/
curl -v http://srv.empresa.test:8000/
```

Localize:

```text
GET /
Host:
HTTP/... 200
```

## 4. Gere um 404

```bash
curl -v http://srv.empresa.test:8000/inexistente.html
```

Um `404` comprova que houve conexão e resposta HTTP. Não significa que a rede caiu.

## 5. Faça uma requisição manual

```bash
nc srv.empresa.test 8000
```

Digite:

```text
GET / HTTP/1.1
Host: srv.empresa.test
Connection: close

```

A linha vazia encerra os cabeçalhos.

## 6. Capture HTTP

No servidor:

```bash
sudo tcpdump -i lab0 -nn -A 'tcp port 8000'
```

No cliente:

```bash
curl http://srv.empresa.test:8000/
```

Observe o conteúdo em texto claro.

## 7. Compare dois sintomas

### Recurso inexistente

```bash
curl -v http://srv.empresa.test:8000/inexistente
```

### Serviço indisponível

Pare o Python e execute:

```bash
curl -v http://srv.empresa.test:8000/
```

Explique a diferença entre resposta `404` e falha de conexão.

## Portfólio

Registre em `web/aula-12/`:

- requisição observada;
- resposta e status;
- papel do cabeçalho `Host`;
- diferença entre 200, 404 e serviço indisponível;
- o que ficou legível na captura.
