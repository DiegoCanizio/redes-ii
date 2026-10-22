# Aula 11 — Integração DHCP + DNS e troubleshooting integrado

**Data:** 05/11/2026  
**Duração:** 150 minutos

## Objetivo

Integrar os dois serviços construídos separadamente.

Até agora:

```text
DHCP funciona
DNS funciona
```

Ao final:

```text
cliente
  │ DHCP
  ▼
recebe IP + DNS 192.168.50.10 + domínio empresa.test
  │
  ▼
resolve www.empresa.test sem indicar @192.168.50.10
```

## 1. Confirme os serviços

Servidor:

```bash
systemctl is-active kea-dhcp4-server
systemctl is-active named
sudo ss -lunp | grep ':67'
sudo ss -luntp | grep ':53'
```

## 2. Adicione opções ao Kea

Dentro da subnet no `/etc/kea/kea-dhcp4.conf`, acrescente:

```json
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
```

Preserve pool e reserva.

## 3. Valide e aplique

```bash
python3 -m json.tool /etc/kea/kea-dhcp4.conf >/dev/null
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
sudo systemctl restart kea-dhcp4-server
```

## 4. Renove o cliente

No cliente:

```bash
sudo networkctl renew lab0
resolvectl status lab0
```

Procure:

```text
DNS Servers: 192.168.50.10
DNS Domain: empresa.test
```

## 5. Teste sem servidor explícito

Agora o teste principal muda.

Antes:

```bash
dig @192.168.50.10 www.empresa.test
```

Agora:

```bash
dig www.empresa.test
getent hosts www.empresa.test
```

O cliente deve descobrir sozinho qual servidor DNS utilizar.

## 6. Observe a cadeia

```text
Kea
 ↓ entrega DNS
systemd-networkd/systemd-resolved
 ↓ consulta
BIND
 ↓ responde
cliente recebe o endereço
```

## 7. Troubleshooting integrado

Sintoma proposto pelo professor:

> O cliente recebe endereço IPv4, mas não consegue resolver `www.empresa.test`.

Não assuma imediatamente que o problema está no BIND.

Investigue:

```bash
ip -br addr show lab0
resolvectl status lab0
systemctl status kea-dhcp4-server --no-pager
systemctl status named --no-pager
sudo ss -lunp | grep ':67'
sudo ss -luntp | grep ':53'
dig @192.168.50.10 www.empresa.test
dig www.empresa.test
sudo journalctl -u kea-dhcp4-server -n 30 --no-pager
sudo journalctl -u named -n 30 --no-pager
```

Compare especialmente:

```text
dig @192.168.50.10 ...
versus
dig ...
```

A diferença entre os resultados ajuda a separar **servidor DNS** de **configuração do cliente**.

## Portfólio

Em `dns/aula-11/`, registre:

- opções entregues pelo DHCP;
- saída relevante de `resolvectl`;
- consulta direta ao BIND;
- consulta usando o resolver do cliente;
- incidente no formato completo de troubleshooting.

### Marco DNS + integração

Ao final, DHCP e DNS devem permanecer funcionando juntos.
