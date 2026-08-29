# Aula 07 — Configurando DHCP com Kea

## Objetivo da aula

Na aula anterior você observou o DORA usando uma configuração pronta.

Agora você construirá o servidor DHCP.

Rede:

```text
192.168.50.0/24
```

Servidor:

```text
192.168.50.10/24
```

Pool:

```text
192.168.50.100–192.168.50.150
```

---

# Bloco 0

Servidor:

```bash
sudo apt update
sudo apt install -y kea-dhcp4-server tcpdump
```

Cliente:

```bash
sudo apt update
sudo apt install -y iproute2 iputils-ping git gh
```

Garanta que:

```text
srv-redes2 → 192.168.50.10/24
cli-redes2 → DHCP na interface REDES2
```

Prepare seu portfólio.

---

# Parte 1 — Backup

No servidor:

```bash
sudo cp /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf.original
```

Identifique a interface interna:

```bash
ip -br addr
ip route
```

Registre:

```text
Interface REDES2: ______________________
```

---

# Parte 2 — Crie a configuração

```bash
sudo nano /etc/kea/kea-dhcp4.conf
```

Use:

```json
{
  "Dhcp4": {
    "interfaces-config": {
      "interfaces": [ "<INTERFACE-REDES2>" ]
    },

    "lease-database": {
      "type": "memfile",
      "persist": true,
      "name": "/var/lib/kea/kea-leases4.csv"
    },

    "valid-lifetime": 600,
    "renew-timer": 200,
    "rebind-timer": 400,

    "subnet4": [
      {
        "subnet": "192.168.50.0/24",
        "pools": [
          { "pool": "192.168.50.100 - 192.168.50.150" }
        ]
      }
    ]
  }
}
```

Substitua a interface.

---

# Parte 3 — Entenda o arquivo

Complete:

| Bloco | Função |
|---|---|
| `interfaces-config` | |
| `subnet4` | |
| `pools` | |
| `valid-lifetime` | |
| `lease-database` | |

Pergunta:

### Por que não configuramos `routers`?

____________________________________________________________________

---

# Parte 4 — Valide

```bash
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
```

Se houver erro:

> Não reinicie o serviço.

Corrija primeiro.

---

# Parte 5 — Inicie o serviço

```bash
sudo systemctl restart kea-dhcp4-server
```

Verifique:

```bash
systemctl status kea-dhcp4-server --no-pager
```

Porta:

```bash
sudo ss -lunp | grep ':67'
```

---

# Parte 6 — Cliente

Confirme que a interface interna usa DHCP:

```yaml
dhcp4: true
dhcp4-overrides:
  use-routes: false
```

Valide/aplique.

Depois:

```bash
ip -br addr
ip route
```

IPv4 recebido:

```text
____________________________________
```

---

# Parte 7 — Teste

```bash
ping -c 3 192.168.50.10
```

e:

```bash
ping -c 3 1.1.1.1
```

---

# Parte 8 — Veja o lease no servidor

```bash
sudo cat /var/lib/kea/kea-leases4.csv
```

Localize o endereço do cliente.

---

# Parte 9 — Logs

```bash
sudo journalctl -u kea-dhcp4-server -n 30
```

Procure evidências relacionadas ao cliente.

---

# Parte 10 — Incidente de validação

O professor orientará uma alteração temporária inválida no pool.

Antes de reiniciar:

```bash
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
```

Registre:

```text
Erro encontrado:
____________________________________________________________

Por que a validação antes do restart foi útil?
____________________________________________________________
```

Restaure a configuração correta e valide novamente.

---

# Parte 11 — Portfólio

Crie:

```text
dhcp/aula-07/
```

Copie a configuração final para:

```text
dhcp/aula-07/kea-dhcp4.conf
```

Crie `README.md` com:

```markdown
# Aula 07 — Servidor DHCP Kea

## Servidor
- interface:
- IPv4:

## DHCP
- subnet:
- pool:
- lease:
- gateway interno: não configurado

## Cliente
- IPv4 recebido:

## Evidências
- validação:
- serviço:
- porta UDP/67:
- lease:

## Incidente
- erro:
- evidência:
- correção:
```

Versione:

```bash
git add dhcp/aula-07
git commit -m "Aula 07 - configura servidor DHCP Kea"
git push
gh auth logout
```

---

# Próxima aula

Reservas, leases e troubleshooting de DHCP.
