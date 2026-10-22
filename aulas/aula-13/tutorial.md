# Aula 13 — Nginx, virtual host, DNS e logs

**Data:** 12/11/2026  
**Duração:** 150 minutos

## Objetivo

Transformar o HTTP temporário da aula anterior em um serviço permanente:

```text
http://www.empresa.test
```

Fluxo:

```text
cliente
  ↓ DNS
192.168.50.10
  ↓ TCP/80
Nginx
  ↓ Host: www.empresa.test
virtual host
  ↓
index.html
```

## 1. Instale e observe o Nginx

```bash
sudo apt update
sudo apt install -y nginx
systemctl status nginx --no-pager
sudo ss -lntp | grep ':80'
```

## 2. Crie o conteúdo

```bash
sudo mkdir -p /var/www/www.empresa.test
```

```bash
echo '<h1>www.empresa.test</h1><p>Redes II</p>' | \
  sudo tee /var/www/www.empresa.test/index.html
```

## 3. Crie um destino padrão controlado

Crie `/etc/nginx/sites-available/00-default-lab`:

```nginx
server {
    listen 80 default_server;
    server_name _;
    return 404;
}
```

Isso torna visível quando o cabeçalho `Host` não corresponde ao site esperado.

## 4. Crie o virtual host

```bash
sudo nano /etc/nginx/sites-available/www.empresa.test
```

```nginx
server {
    listen 80;
    server_name www.empresa.test;

    root /var/www/www.empresa.test;
    index index.html;
}
```

## 5. Habilite

```bash
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/00-default-lab \
  /etc/nginx/sites-enabled/00-default-lab
sudo ln -sf /etc/nginx/sites-available/www.empresa.test \
  /etc/nginx/sites-enabled/www.empresa.test
```

Valide sempre antes do reload:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## 6. Teste isolando DNS de HTTP

```bash
curl -v --resolve www.empresa.test:80:192.168.50.10 \
  http://www.empresa.test/
```

Esse teste força o endereço, mas preserva:

```text
Host: www.empresa.test
```

## 7. Teste integrado

Como DNS já está integrado:

```bash
curl -v http://www.empresa.test/
```

Também compare:

```bash
curl -i http://192.168.50.10/
```

O acesso apenas pelo IP deve atingir o servidor padrão e retornar o comportamento controlado.

## 8. Observe os logs

No servidor:

```bash
sudo tail -f /var/log/nginx/access.log
```

Em outro terminal:

```bash
sudo tail -f /var/log/nginx/error.log
```

Faça novas requisições do cliente e associe cada linha ao teste realizado.

## 9. Incidente integrado

O professor introduzirá uma inconsistência entre nome, DNS ou configuração do Nginx.

Ferramentas possíveis:

```bash
resolvectl status lab0
dig www.empresa.test
curl -v http://www.empresa.test/
curl -v --resolve www.empresa.test:80:192.168.50.10 http://www.empresa.test/
sudo nginx -t
sudo nginx -T
sudo ss -lntp | grep ':80'
sudo tail -n 20 /var/log/nginx/error.log
```

Produza:

```text
Sintoma → Hipótese → Teste → Evidência → Causa → Correção → Validação
```

## Portfólio

Registre em `web/aula-13/`:

- configuração do virtual host;
- papel do `Host`;
- diferença entre teste com `--resolve` e teste integrado;
- evidências de log;
- incidente diagnosticado.

### Marco HTTP/Nginx

Ao final, `http://www.empresa.test` deve funcionar a partir do cliente.
