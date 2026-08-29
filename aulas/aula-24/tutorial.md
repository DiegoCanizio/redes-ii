# Aula 24 — Proxy e filtragem com Squid

## Objetivo

Usar um proxy explícito:

```text
cliente → Squid :3128 → destino
```

e aplicar política de acesso.

---

# Bloco 0

Servidor:

```bash
sudo apt update
sudo apt install -y squid nginx curl
```

Cliente:

```bash
sudo apt update
sudo apt install -y curl git gh
```

Prepare seu portfólio.

---

# Parte 1 — Backup

Servidor:

```bash
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.original
```

---

# Parte 2 — ACL da rede

Edite:

```bash
sudo nano /etc/squid/squid.conf
```

Antes das regras finais de negação, configure:

```conf
acl redes2 src 192.168.50.0/24

http_access allow localhost
http_access allow redes2
http_access deny all
```

---

# Parte 3 — Valide

```bash
sudo squid -k parse
```

Se não houver erro:

```bash
sudo systemctl restart squid
```

Verifique:

```bash
ss -lntp | grep ':3128'
```

---

# Parte 4 — Use o proxy

Cliente:

```bash
curl -x http://192.168.50.10:3128 \
  http://example.com/
```

Se o professor indicar um destino local, utilize o endereço fornecido.

---

# Parte 5 — Observe o log

Servidor:

```bash
sudo tail -f /var/log/squid/access.log
```

Repita uma requisição.

Registre:

```text
cliente:
____________________________________________________________

destino:
____________________________________________________________

resultado:
____________________________________________________________
```

---

# Parte 6 — Bloqueie um domínio

Antes do `allow redes2`, adicione:

```conf
acl bloqueados dstdomain .example.com
http_access deny bloqueados
```

Valide:

```bash
sudo squid -k parse
```

Recarregue:

```bash
sudo systemctl reload squid
```

Cliente:

```bash
curl -v -x http://192.168.50.10:3128 \
  http://example.com/
```

---

# Parte 7 — Analise a negação

Pergunta:

### Houve timeout de rede?

```text
☐ Sim
☐ Não
```

### O Squid respondeu?

```text
☐ Sim
☐ Não
```

Veja:

```bash
sudo tail -n 20 /var/log/squid/access.log
```

---

# Parte 8 — HTTPS

Cliente:

```bash
curl -v -x http://192.168.50.10:3128 \
  https://example.com/
```

Procure no log algo relacionado a:

```text
CONNECT
```

Responda:

### O Squid está recebendo o conteúdo HTTP interno da sessão TLS em texto claro?

```text
☐ Sim
☐ Não
```

---

# Parte 9 — Limites

Explique:

```text
HTTP:
____________________________________________________________

HTTPS:
____________________________________________________________

Por que não faremos interceptação TLS:
____________________________________________________________
```

---

# Parte 10 — nftables × Squid

Complete:

| Aspecto | nftables | Squid |
|---|---|---|
| Atua como proxy da aplicação? | | |
| Pode responder “Access Denied”? | | |
| Regras por porta/IP | | |
| ACL de destino Web | | |

---

# Parte 11 — Portfólio

```text
proxy/aula-24/
├── README.md
└── squid-aula24.conf
```

README:

```markdown
# Aula 24 — Squid

## Proxy explícito

## ACL de origem

## Requisição permitida

## Requisição bloqueada

## Logs

## HTTPS/CONNECT
Explique o limite de inspeção.

## Comparação com nftables
```

Versione e encerre a autenticação.

---

# Próxima aula

Avaliação Prática 2 — Troubleshooting.
