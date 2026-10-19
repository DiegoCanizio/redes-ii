# Aula 13 — HTTP, Nginx e logs

**Data:** 12/11/2026  
**Duração:** 150 minutos

---

## Situação-problema

A infraestrutura já possui:

```text
rede
+
DHCP
+
DNS
```

Hoje adicionaremos um serviço de aplicação:

```text
cli-r2-sNN
      │
      │ http://www.empresa.test
      ▼
DNS resolve para 192.168.50.10
      │
      ▼
Nginx
      │
      ▼
página web
```

---

# Objetivos

- compreender requisição e resposta HTTP;
- instalar e configurar Nginx;
- usar um nome DNS para acessar o serviço;
- validar a configuração antes do reload;
- interpretar códigos HTTP;
- consultar logs;
- observar HTTP em texto claro.

---

# 1. Confirme a base

No servidor:

```bash
systemctl is-active kea-dhcp4-server
systemctl is-active bind9
```

No cliente:

```bash
getent hosts www.empresa.test
```

O nome deverá apontar para:

```text
192.168.50.10
```

---

# 2. Instale o Nginx

No servidor:

```bash
sudo apt update
sudo apt install -y nginx
```

Confira:

```bash
systemctl status nginx
```

Porta:

```bash
sudo ss -lntp | grep ':80'
```

---

# 3. Teste pelo endereço IP

No cliente:

```bash
curl -I http://192.168.50.10/
```

Depois:

```bash
curl -v http://192.168.50.10/
```

Observe:

```text
> GET
> Host:
< HTTP/...
```

---

# 4. Crie o site da disciplina

No servidor:

```bash
sudo mkdir -p /var/www/empresa
```

Crie:

```bash
sudo nano /var/www/empresa/index.html
```

Exemplo:

```html
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <title>empresa.test</title>
</head>
<body>
  <h1>Redes de Computadores II</h1>
  <p>Servidor: srv-r2-sNN</p>
  <p>Site: www.empresa.test</p>
</body>
</html>
```

Substitua `NN` pelo número do seu ambiente.

---

# 5. Configure o virtual host

Crie:

```bash
sudo nano /etc/nginx/sites-available/www.empresa.test
```

Conteúdo:

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name www.empresa.test;

    root /var/www/empresa;
    index index.html;

    access_log /var/log/nginx/empresa-access.log;
    error_log  /var/log/nginx/empresa-error.log;
}
```

---

# 6. Habilite o site

```bash
sudo ln -s \
  /etc/nginx/sites-available/www.empresa.test \
  /etc/nginx/sites-enabled/www.empresa.test
```

Remova o default, se orientado:

```bash
sudo rm -f /etc/nginx/sites-enabled/default
```

---

# 7. Valide antes do reload

```bash
sudo nginx -t
```

Somente se estiver correto:

```bash
sudo systemctl reload nginx
```

Confira:

```bash
systemctl is-active nginx
sudo ss -lntp | grep ':80'
```

---

# 8. Acesse pelo nome

No cliente:

```bash
curl -v http://www.empresa.test/
```

O fluxo agora depende de:

```text
DHCP
→ configuração do cliente

DNS
→ nome para endereço

HTTP/Nginx
→ resposta da aplicação
```

---

# 9. Código 200

Somente cabeçalhos:

```bash
curl -I http://www.empresa.test/
```

Registre:

```text
Status:
____________________________________
```

---

# 10. Código 404

No cliente:

```bash
curl -v http://www.empresa.test/arquivo-que-nao-existe
```

Pergunta:

### Um `404` significa que a rede está fora?

```text
☐ Sim
☐ Não
```

Explique:

```text
____________________________________________________________
```

Se o servidor respondeu `404`, várias etapas anteriores já funcionaram.

---

# 11. Observe logs

No servidor:

```bash
sudo tail -f /var/log/nginx/empresa-access.log
```

Em outro terminal do cliente:

```bash
curl http://www.empresa.test/
```

Depois teste um recurso inexistente:

```bash
curl http://www.empresa.test/nao-existe
```

Observe as linhas adicionadas.

Erro:

```bash
sudo tail -n 20 /var/log/nginx/empresa-error.log
```

---

# 12. Faça uma requisição manual

No cliente, se `nc` estiver disponível:

```bash
nc www.empresa.test 80
```

Digite:

```text
GET / HTTP/1.1
Host: www.empresa.test
Connection: close

```

Depois da linha `Connection: close`, deixe uma linha em branco.

Observe a resposta HTTP.

---

# 13. Capture HTTP

No servidor:

```bash
sudo tcpdump -i lab0 -nn -A 'tcp port 80'
```

No cliente:

```bash
curl http://www.empresa.test/
```

Pergunta:

### O conteúdo HTTP aparece em texto claro?

```text
☐ Sim
☐ Não
```

Esse resultado será importante quando estudarmos HTTPS/TLS.

---

# 14. Troubleshooting orientado por camadas

Se:

```bash
curl http://www.empresa.test/
```

falhar, evite começar pelo Nginx automaticamente.

Investigue:

```text
1. cliente possui IP?
2. cliente conhece o DNS?
3. nome resolve?
4. servidor responde?
5. Nginx está ativo?
6. porta 80 está em LISTEN?
7. configuração passou no nginx -t?
8. logs mostram erro?
```

---

# 15. Portfólio

No servidor:

```bash
cd ~/SEU_REPOSITORIO
mkdir -p http
```

Salve:

```bash
sudo cat /etc/nginx/sites-available/www.empresa.test \
  > http/www.empresa.test.nginx
```

```bash
sudo cat /var/www/empresa/index.html \
  > http/index.html
```

Crie:

```bash
nano http/README.md
```

Estrutura:

```markdown
# HTTP com Nginx

## Serviço
- nome:
- endereço:
- porta:

## DNS
- nome utilizado:
- endereço resolvido:

## Testes
- nginx -t:
- porta:
- HTTP 200:
- HTTP 404:

## Logs
- access:
- error:

## Captura
O conteúdo apareceu em texto claro?

## Conclusão
Explique o caminho cliente → DNS → Nginx.
```

---

# 16. Marco HTTP

```bash
git status
git add http/
git status
git commit -m "Implanta HTTP com Nginx integrado ao DNS"
git push
```

---

# Checklist

```text
[ ] www.empresa.test resolve para 192.168.50.10.
[ ] Nginx está ativo.
[ ] porta 80 está em LISTEN.
[ ] nginx -t não apresenta erro.
[ ] cliente acessa http://www.empresa.test.
[ ] observei 200 e 404.
[ ] consultei access.log e error.log.
[ ] capturei HTTP.
[ ] concluí o marco HTTP no portfólio.
```
