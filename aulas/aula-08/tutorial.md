# Aula 08 — DHCP: protocolo e implantação inicial

**Data:** 27/10/2026  
**Duração:** 100 minutos

---

## Situação-problema

Na Aula 06 o cliente recebeu manualmente:

```text
192.168.50.20/24
```

Isso funciona em uma rede pequena de laboratório, mas não escala.

Hoje o servidor começará a fornecer configuração IPv4 automaticamente:

```text
cli-r2-sNN
     │
     │ DHCP
     ▼
srv-r2-sNN
lab0: 192.168.50.10/24
```

---

# Objetivos

- compreender o processo DHCP;
- identificar portas UDP 67 e 68;
- instalar e iniciar o Kea DHCP;
- criar um pool;
- fazer o cliente obter endereço automaticamente;
- observar o protocolo em captura.

---

# 1. O processo DORA

O processo inicial pode ser representado como:

```text
CLIENTE                         SERVIDOR
   │                               │
   │──── DHCPDISCOVER ────────────>│
   │<──── DHCPOFFER ───────────────│
   │──── DHCPREQUEST ─────────────>│
   │<──── DHCPACK ─────────────────│
```

Portas:

```text
Servidor DHCP → UDP/67
Cliente DHCP  → UDP/68
```

---

# 2. Confirme a rede do servidor

No servidor:

```bash
ip -br addr show lab0
```

Deve existir:

```text
192.168.50.10/24
```

Se não existir, corrija a rede antes de continuar.

---

# 3. Instale o Kea

No servidor:

```bash
sudo apt update
sudo apt install -y kea-dhcp4-server
```

Verifique:

```bash
systemctl status kea-dhcp4-server
```

O serviço pode ainda não estar pronto para uso. Isso é esperado antes da configuração.

---

# 4. Faça backup

```bash
sudo cp /etc/kea/kea-dhcp4.conf \
  /etc/kea/kea-dhcp4.conf.bak-aula08
```

---

# 5. Configure o DHCP

Edite:

```bash
sudo nano /etc/kea/kea-dhcp4.conf
```

Utilize como base:

```json
{
  "Dhcp4": {
    "interfaces-config": {
      "interfaces": [ "lab0" ]
    },

    "lease-database": {
      "type": "memfile",
      "persist": true,
      "name": "/var/lib/kea/kea-leases4.csv"
    },

    "valid-lifetime": 600,
    "renew-timer": 300,
    "rebind-timer": 500,

    "subnet4": [
      {
        "subnet": "192.168.50.0/24",

        "pools": [
          {
            "pool": "192.168.50.100 - 192.168.50.150"
          }
        ],

        "option-data": [
          {
            "name": "domain-name-servers",
            "data": "192.168.50.10"
          },
          {
            "name": "domain-name",
            "data": "empresa.test"
          }
        ]
      }
    ]
  }
}
```

---

# 6. Valide antes de reiniciar

Valide JSON:

```bash
python3 -m json.tool /etc/kea/kea-dhcp4.conf >/dev/null
```

Valide o Kea:

```bash
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
```

Se houver erro:

```text
NÃO reinicie o serviço.
```

Corrija primeiro.

---

# 7. Inicie o serviço

```bash
sudo systemctl restart kea-dhcp4-server
```

Confira:

```bash
systemctl is-active kea-dhcp4-server
```

Depois:

```bash
sudo ss -lunp | grep ':67'
```

---

# 8. Prepare a captura DHCP

No servidor:

```bash
sudo tcpdump -i lab0 -nn -vvv \
  'udp port 67 or udp port 68'
```

Mantenha a captura aberta.

---

# 9. Altere o cliente para DHCP

No cliente, edite:

```bash
sudo nano /etc/netplan/90-redes2-lab.yaml
```

Use:

```yaml
network:
  version: 2
  ethernets:
    lab0:
      dhcp4: true
```

Valide:

```bash
sudo netplan generate
```

Depois:

```bash
sudo netplan apply
```

> A conexão SSH atual com o cliente pode ser encerrada porque o endereço está mudando. Isso é esperado.

---

# 10. Descubra o endereço concedido

No servidor:

```bash
sudo tail -n 10 /var/lib/kea/kea-leases4.csv
```

Também consulte:

```bash
sudo journalctl -u kea-dhcp4-server -n 30 --no-pager
```

Identifique o endereço concedido ao cliente.

---

# 11. Reconecte ao cliente

A partir do servidor:

```bash
ssh SEU_USUARIO@IP_RECEBIDO
```

No cliente:

```bash
ip -br addr show lab0
ip route
```

---

# 12. Relacione com a captura

Na captura do servidor, procure mensagens DHCP.

Tente identificar:

```text
Discover
Offer
Request
Ack
```

Nem toda renovação exibe necessariamente a sequência inicial completa. O importante é relacionar o tráfego observado com o funcionamento do protocolo.

---

# 13. Não faça o commit ainda

A Aula 08 e a Aula 09 formam o marco:

```text
DHCP
```

Hoje concentre-se em fazer o serviço funcionar e anotar dúvidas.

Na próxima aula entraremos em:

- leases;
- reservas;
- renovação;
- logs;
- diagnóstico;
- documentação final.
