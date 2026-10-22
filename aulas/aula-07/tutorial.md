# Aula 07 — Troubleshooting e DHCP inicial

**Data:** 22/10/2026  
**Duração:** 150 minutos

## Objetivo

Partir da rede funcional da Aula 06, aprender a diagnosticar seus componentes e substituir o endereço manual do cliente por uma concessão DHCP.

Ao final:

```text
srv-r2-sNN
lab0 = 192.168.50.10/24
Kea DHCPv4
        │
        ▼
cli-r2-sNN
lab0 = DHCP
```

## Parte 1 — Conheça o estado saudável

No servidor:

```bash
hostname
ip -br addr
ip route
ip neigh
ping -c 3 192.168.50.20
```

No cliente:

```bash
hostname
ip -br addr
ip route
ping -c 3 192.168.50.10
```

## Parte 2 — Método de troubleshooting

```text
Sintoma
→ Hipótese
→ Teste
→ Evidência
→ Causa
→ Correção
→ Validação
```

## Parte 3 — ARP e ICMP

No servidor:

```bash
sudo tcpdump -i lab0 -nn 'arp or icmp'
```

No cliente:

```bash
sudo ip neigh flush dev lab0
ping -c 3 192.168.50.10
```

Identifique ARP antes do primeiro ICMP.

## Parte 4 — Serviço, porta e log

No servidor:

```bash
systemctl status ssh --no-pager
sudo ss -lntp | grep ':22'
sudo journalctl -u ssh -n 20 --no-pager
```

Relacione:

```text
systemctl  → serviço
ss         → socket/porta
journalctl → eventos
```

## Parte 5 — Por que DHCP?

Até agora o cliente possui endereço configurado manualmente. Em uma rede com muitos clientes, queremos automatizar a entrega de parâmetros.

Processo inicial:

```text
cliente                       servidor
   │──── DHCPDISCOVER ──────────>│
   │<──── DHCPOFFER ─────────────│
   │──── DHCPREQUEST ────────────>│
   │<──── DHCPACK ────────────────│
```

Portas:

```text
servidor → UDP/67
cliente  → UDP/68
```

## Parte 6 — Instale o Kea no servidor

```bash
sudo apt update
sudo apt install -y kea-dhcp4-server
```

Faça backup:

```bash
sudo cp /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf.bak-aula07
```

Edite:

```bash
sudo nano /etc/kea/kea-dhcp4.conf
```

Use como configuração inicial:

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
          { "pool": "192.168.50.100 - 192.168.50.150" }
        ]
      }
    ]
  }
}
```

## Parte 7 — Valide antes de reiniciar

```bash
python3 -m json.tool /etc/kea/kea-dhcp4.conf >/dev/null
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
```

Somente depois:

```bash
sudo systemctl restart kea-dhcp4-server
systemctl is-active kea-dhcp4-server
sudo ss -lunp | grep ':67'
```

## Parte 8 — Capture o DHCP

No servidor:

```bash
sudo tcpdump -i lab0 -nn -vvv 'udp port 67 or udp port 68'
```

## Parte 9 — Mude o cliente para DHCP

No cliente:

```bash
sudo cp /etc/systemd/network/80-lab0.network \
  /etc/systemd/network/80-lab0.network.bak-aula07
sudo nano /etc/systemd/network/80-lab0.network
```

Conteúdo:

```ini
[Match]
Name=lab0

[Network]
DHCP=ipv4
LinkLocalAddressing=no
IPv6AcceptRA=no
```

Reaplique:

```bash
sudo networkctl reload
sudo networkctl reconfigure lab0
```

Se necessário:

```bash
sudo systemctl restart systemd-networkd
```

A conexão SSH pela antiga `.20` pode cair. Isso é esperado.

## Parte 10 — Descubra a concessão

No servidor:

```bash
sudo tail -n 10 /var/lib/kea/kea-leases4.csv
sudo journalctl -u kea-dhcp4-server -n 30 --no-pager
```

O endereço deve pertencer a:

```text
192.168.50.100–192.168.50.150
```

Reconecte:

```bash
ssh SEU_USUARIO@IP_RECEBIDO
```

## Registro

Crie `dhcp/aula-07/README.md` e registre:

- estado inicial da rede;
- método de troubleshooting;
- pool configurado;
- endereço concedido;
- mensagens DHCP observadas;
- evidência de UDP/67;
- diferença entre endereço estático e DHCP.

## Fechamento

Não adicione ainda DNS, domínio ou reserva. Esses itens pertencem às aulas seguintes.
