# Aula 08 — Reserva DHCP e diagnóstico

## Objetivo

Hoje o cliente deverá receber sempre:

```text
192.168.50.50/24
```

por DHCP.

O pool dinâmico continuará:

```text
192.168.50.100–192.168.50.150
```

---

# Bloco 0

Reconstrua o servidor DHCP utilizando sua configuração da Aula 7.

Valide:

```bash
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
sudo systemctl restart kea-dhcp4-server
```

Prepare o portfólio no cliente.

---

# Parte 1 — Descubra o MAC

No cliente:

```bash
ip link show <INTERFACE-REDES2>
```

MAC:

```text
____________________________________
```

---

# Parte 2 — Crie a reserva

No servidor, edite a subnet do Kea e acrescente:

```json
"reservations": [
  {
    "hw-address": "SEU:MAC:AQUI",
    "ip-address": "192.168.50.50"
  }
]
```

Atenção à posição das vírgulas no JSON.

---

# Parte 3 — Valide antes de reiniciar

```bash
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
```

Depois:

```bash
sudo systemctl restart kea-dhcp4-server
```

---

# Parte 4 — Renove o cliente

```bash
sudo networkctl renew <INTERFACE-REDES2>
```

Verifique:

```bash
ip -br addr
```

Esperado:

```text
192.168.50.50/24
```

Se o lease antigo persistir, siga a orientação do professor para reconfigurar a interface.

---

# Parte 5 — Leases e logs

Servidor:

```bash
sudo cat /var/lib/kea/kea-leases4.csv
```

e:

```bash
sudo journalctl -u kea-dhcp4-server -n 40
```

---

# Parte 6 — Captura

Servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn -vvv 'udp port 67 or udp port 68'
```

Renove o cliente e observe.

---

# Parte 7 — Incidente

O professor introduzirá uma falha.

Não corrija imediatamente.

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

Comandos possíveis:

```bash
systemctl status kea-dhcp4-server
ss -lunp | grep ':67'
ip -br addr
journalctl -u kea-dhcp4-server -n 30
tcpdump ...
```

Registre:

```text
Sintoma:
____________________________________________________________

Hipótese:
____________________________________________________________

Evidência 1:
____________________________________________________________

Evidência 2:
____________________________________________________________

Causa:
____________________________________________________________

Correção:
____________________________________________________________

Validação:
____________________________________________________________
```

---

# Parte 8 — Portfólio

Crie:

```text
dhcp/aula-08/
├── README.md
└── kea-dhcp4-reserva.conf
```

README:

```markdown
# Aula 08 — Reserva DHCP

## Cliente
- MAC:
- endereço anterior:
- endereço reservado: 192.168.50.50/24

## DHCP
- pool:
- reserva:

## Evidências
- lease:
- log:
- captura:

## Incidente
### Sintoma
### Hipótese
### Testes
### Evidências
### Causa
### Correção
### Validação
```

Versione:

```bash
git add dhcp/aula-08
git commit -m "Aula 08 - configura reserva DHCP"
git push
gh auth logout
```

---

# Próxima aula

DNS: como nomes se transformam em informações utilizadas pelas aplicações.
