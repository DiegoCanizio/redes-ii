# Aula 22 — Firewall com nftables

## Objetivo

Aplicar uma política:

```text
bloquear por padrão
permitir explicitamente o necessário
```

Servidor:

```text
SSH   TCP/22
HTTP  TCP/80
HTTPS TCP/443
```

---

# Bloco 0

Servidor:

```bash
sudo apt update
sudo apt install -y nftables nginx openssh-server curl python3
sudo systemctl start nginx ssh
```

Cliente:

```bash
sudo apt update
sudo apt install -y curl netcat-openbsd openssh-client git gh
```

Antes do firewall:

```bash
ss -lntp
```

Teste:

```bash
ping -c 3 192.168.50.10
nc -vz 192.168.50.10 22
curl http://192.168.50.10/
```

---

# Parte 1 — Backup

Servidor:

```bash
sudo cp /etc/nftables.conf /etc/nftables.conf.original
```

---

# Parte 2 — Crie o ruleset

```bash
sudo nano /etc/nftables.conf
```

Use:

```nft
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        iifname "lo" accept
        ct state established,related accept

        ip protocol icmp counter accept

        ip saddr 192.168.50.0/24 tcp dport 22 counter accept
        ip saddr 192.168.50.0/24 tcp dport { 80, 443 } counter accept
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
```

---

# Parte 3 — Interprete

Complete:

```text
input:
____________________________________________________________

output:
____________________________________________________________

forward:
____________________________________________________________

policy drop:
____________________________________________________________
```

---

# Parte 4 — Valide antes de aplicar

```bash
sudo nft -c -f /etc/nftables.conf
```

Se houver erro, **não aplique**.

Depois:

```bash
sudo nft -f /etc/nftables.conf
```

---

# Parte 5 — Veja as regras

```bash
sudo nft list ruleset
```

---

# Parte 6 — Teste o permitido

Cliente:

```bash
ping -c 3 192.168.50.10
```

```bash
nc -vz 192.168.50.10 22
```

```bash
curl http://192.168.50.10/
```

---

# Parte 7 — Serviço em porta não permitida

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
nc -vz -w 3 192.168.50.10 8080
```

Responda:

### O serviço está em LISTEN?

```text
☐ Sim
☐ Não
```

### O cliente consegue acessar?

```text
☐ Sim
☐ Não
```

### Que nova camada explica a diferença?

____________________________________________________________________

---

# Parte 8 — Counters

Servidor:

```bash
sudo nft list ruleset
```

Repita alguns testes e execute novamente.

O que mudou?

____________________________________________________________________

---

# Parte 9 — Persistência

```bash
sudo systemctl enable nftables
```

---

# Parte 10 — Portfólio

```text
firewall/aula-22/
├── README.md
└── nftables.conf
```

README:

```markdown
# Aula 22 — nftables

## Política
- input:
- output:
- forward:

## Regras permitidas

## Testes
- ICMP:
- SSH:
- HTTP:
- TCP/8080:

## Evidência
Explique por que LISTEN não garante acessibilidade.

## Counters
```

Copie `/etc/nftables.conf`.

Versione e encerre a autenticação.

---

# Próxima aula

Política de firewall e troubleshooting.
