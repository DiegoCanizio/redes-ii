# Aula 08 — DHCP: leases, reserva e diagnóstico

**Data:** 27/10/2026  
**Duração:** 100 minutos

## Objetivo

Aprofundar o DHCP já funcional. O cliente passará a receber sempre:

```text
192.168.50.50/24
```

por meio de uma reserva baseada no MAC de `lab0`.

O pool dinâmico continua:

```text
192.168.50.100–192.168.50.150
```

## 1. Confirme o estado inicial

Servidor:

```bash
ip -br addr show lab0
systemctl is-active kea-dhcp4-server
sudo ss -lunp | grep ':67'
```

Cliente:

```bash
ip -br addr show lab0
```

## 2. Observe o lease

Servidor:

```bash
sudo cat /var/lib/kea/kea-leases4.csv
```

Identifique:

- endereço concedido;
- MAC;
- validade;
- hostname, quando disponível.

## 3. Descubra o MAC da `lab0`

No cliente:

```bash
ip link show lab0
```

Registre o MAC.

## 4. Crie a reserva

No servidor, dentro da subnet de `192.168.50.0/24`, acrescente:

```json
"reservations": [
  {
    "hw-address": "SEU:MAC:AQUI",
    "ip-address": "192.168.50.50"
  }
]
```

A reserva pode ficar fora do pool dinâmico, desde que permaneça dentro da subnet.

## 5. Valide

```bash
python3 -m json.tool /etc/kea/kea-dhcp4.conf >/dev/null
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
sudo systemctl restart kea-dhcp4-server
```

## 6. Renove o cliente

No cliente:

```bash
sudo networkctl renew lab0
```

Verifique:

```bash
ip -br addr show lab0
```

Esperado:

```text
192.168.50.50/24
```

Se o lease anterior persistir, reconfigure/reinicie `systemd-networkd` conforme orientação do professor.

## 7. Produza evidências

Servidor:

```bash
sudo cat /var/lib/kea/kea-leases4.csv
sudo journalctl -u kea-dhcp4-server -n 40 --no-pager
```

Cliente:

```bash
ip -br addr show lab0
ping -c 3 192.168.50.10
```

## 8. Diagnóstico

O professor introduzirá uma falha simples relacionada ao DHCP.

Use:

```text
Sintoma → Hipótese → Teste → Evidência → Causa → Correção → Validação
```

Ferramentas úteis:

```bash
systemctl status kea-dhcp4-server
sudo ss -lunp | grep ':67'
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
sudo journalctl -u kea-dhcp4-server -n 30 --no-pager
ip -br addr
```

## Portfólio

Crie:

```text
dhcp/aula-08/
├── README.md
└── kea-dhcp4-reserva.conf
```

O README deve conter MAC, lease anterior, reserva, evidências e diagnóstico.

### Marco DHCP

Ao final desta aula, o bloco DHCP deve estar versionado e funcional.
