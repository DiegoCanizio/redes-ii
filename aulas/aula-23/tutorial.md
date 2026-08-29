# Aula 23 — Troubleshooting de firewall

## Objetivo

Distinguir:

```text
serviço parado
```

de:

```text
serviço ativo + firewall bloqueando
```

---

# Bloco 0

Servidor:

```bash
sudo apt update
sudo apt install -y nftables nginx openssh-server python3 tcpdump
```

Cliente:

```bash
sudo apt update
sudo apt install -y curl netcat-openbsd tcpdump git gh
```

Recupere o `nftables.conf` da Aula 22:

```bash
sudo nft -c -f /etc/nftables.conf
sudo nft -f /etc/nftables.conf
```

---

# Parte 1 — Aplicação de teste

Servidor:

```bash
python3 -m http.server 8080 --bind 192.168.50.10
```

Em outro terminal:

```bash
ss -lntp | grep ':8080'
```

Cliente:

```bash
curl --max-time 3 http://192.168.50.10:8080/
```

---

# Parte 2 — Libere temporariamente 8080

Servidor:

```bash
sudo nft add rule inet filter input \
  ip saddr 192.168.50.0/24 tcp dport 8080 counter accept
```

Teste novamente.

---

# Parte 3 — Incidente A

Pare o servidor Python.

Cliente:

```bash
nc -vz -w 3 192.168.50.10 8080
```

Servidor:

```bash
ss -lntp | grep ':8080'
```

Capture:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn 'tcp port 8080'
```

Registre:

```text
Sintoma:
____________________________________________________________

Evidência:
____________________________________________________________

Causa:
____________________________________________________________
```

---

# Parte 4 — Incidente B

Inicie novamente:

```bash
python3 -m http.server 8080 --bind 192.168.50.10
```

Em outro terminal, recarregue o ruleset original:

```bash
sudo nft -f /etc/nftables.conf
```

Cliente:

```bash
nc -vz -w 3 192.168.50.10 8080
```

Servidor:

```bash
ss -lntp | grep ':8080'
sudo nft list ruleset
```

Registre:

```text
Sintoma:
____________________________________________________________

Evidência:
____________________________________________________________

Causa:
____________________________________________________________
```

---

# Parte 5 — Compare

| Evidência | Serviço parado | Firewall bloqueando |
|---|---|---|
| `ss` mostra LISTEN? | | |
| pacote chega ao host? | | |
| regra permite 8080? | | |
| cliente acessa? | | |

---

# Parte 6 — Implemente o requisito

Requisito:

> TCP/8080 deve ser acessível somente a partir de `192.168.50.0/24`.

Adicione ao arquivo:

```nft
ip saddr 192.168.50.0/24 tcp dport 8080 counter accept
```

Valide:

```bash
sudo nft -c -f /etc/nftables.conf
```

Aplique:

```bash
sudo nft -f /etc/nftables.conf
```

Teste.

---

# Parte 7 — Veja counters e handles

```bash
sudo nft -a list chain inet filter input
```

Observe:

```text
counter
handle
```

---

# Parte 8 — Diagnóstico final

O professor fornecerá apenas o sintoma.

Use:

```text
Sintoma
→ Hipótese
→ Teste
→ Evidência
→ Causa
→ Correção
→ Validação
```

Não altere regras sem evidência.

---

# Parte 9 — Portfólio

```text
firewall/aula-23/
├── README.md
└── nftables-final.conf
```

README:

```markdown
# Aula 23 — Troubleshooting de firewall

## Incidente A — serviço parado
### Evidências
### Causa
### Validação

## Incidente B — firewall
### Evidências
### Causa
### Validação

## Comparação

## Política final
Justifique a regra TCP/8080.
```

Versione e encerre a autenticação.

---

# Próxima aula

Proxy e filtragem de conteúdo com Squid.
