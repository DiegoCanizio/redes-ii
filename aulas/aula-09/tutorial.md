# Aula 09 — DHCP: leases, reservas e diagnóstico

**Data:** 29/10/2026  
**Duração:** 150 minutos

---

## Objetivo

Partindo do DHCP funcional da Aula 08, hoje você deverá:

- interpretar leases;
- identificar o cliente pelo MAC;
- criar uma reserva;
- validar opções entregues ao cliente;
- provocar e diagnosticar uma falha;
- documentar o serviço no portfólio.

---

# 1. Confirme o estado inicial

No servidor:

```bash
ip -br addr show lab0
systemctl is-active kea-dhcp4-server
sudo ss -lunp | grep ':67'
```

No cliente:

```bash
ip -br addr show lab0
```

---

# 2. Observe os leases

No servidor:

```bash
sudo cat /var/lib/kea/kea-leases4.csv
```

Localize:

```text
address
hwaddr
valid_lifetime
expire
hostname
```

O arquivo é estado de execução. Não é o principal arquivo de configuração.

---

# 3. Descubra o MAC do cliente

No cliente:

```bash
ip link show lab0
```

Localize:

```text
link/ether
```

Registre:

```text
MAC do cliente:
____________________________________
```

---

# 4. Crie uma reserva

No servidor, edite:

```bash
sudo nano /etc/kea/kea-dhcp4.conf
```

Dentro da subnet, adicione:

```json
"reservations": [
  {
    "hw-address": "MAC_DO_CLIENTE",
    "ip-address": "192.168.50.50",
    "hostname": "cliente"
  }
]
```

Atenção à posição das vírgulas no JSON.

---

# 5. Valide novamente

```bash
python3 -m json.tool /etc/kea/kea-dhcp4.conf >/dev/null
```

```bash
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
```

Somente depois:

```bash
sudo systemctl restart kea-dhcp4-server
```

---

# 6. Faça o cliente solicitar novamente

Uma reserva nova não necessariamente substitui imediatamente um lease ainda válido.

Para o laboratório, o professor poderá orientar a limpeza controlada do lease anterior.

Depois, no cliente:

```bash
sudo networkctl renew lab0
```

Se necessário:

```bash
sudo systemctl restart systemd-networkd
```

A sessão SSH pode cair temporariamente.

No servidor, confirme:

```bash
sudo tail -n 10 /var/lib/kea/kea-leases4.csv
```

Resultado esperado para o cliente reservado:

```text
192.168.50.50
```

---

# 7. Verifique as opções entregues

No cliente:

```bash
ip -br addr show lab0
ip route
```

Quando disponível:

```bash
resolvectl status lab0
```

Observe se o servidor DNS informado pelo DHCP é:

```text
192.168.50.10
```

e se o domínio é:

```text
empresa.test
```

O DNS ainda será implantado nas próximas aulas. Hoje estamos verificando apenas a informação entregue pelo DHCP.

---

# 8. Logs e evidências

No servidor:

```bash
sudo journalctl -u kea-dhcp4-server -n 50 --no-pager
```

Capture uma nova renovação:

```bash
sudo tcpdump -i lab0 -nn -vvv \
  'udp port 67 or udp port 68'
```

---

# 9. Incidente DHCP

O professor indicará um incidente ou uma condição incorreta.

Utilize:

```text
Sintoma
→ Hipótese
→ Teste
→ Evidência
→ Causa
→ Correção
→ Validação
```

Ferramentas úteis:

```bash
systemctl status kea-dhcp4-server
journalctl -u kea-dhcp4-server
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
sudo ss -lunp
ip -br addr
tcpdump
```

---

# 10. Portfólio

No servidor:

```bash
cd ~/SEU_REPOSITORIO
mkdir -p dhcp
```

Salve a configuração:

```bash
sudo cat /etc/kea/kea-dhcp4.conf > dhcp/kea-dhcp4.conf
```

Crie:

```bash
nano dhcp/README.md
```

Estrutura sugerida:

```markdown
# DHCP com Kea

## Rede
- servidor:
- rede:
- pool:

## Cliente
- MAC:
- endereço inicialmente recebido:
- endereço reservado:

## Opções DHCP
- DNS:
- domínio:

## Testes
- serviço:
- porta:
- lease:
- renovação:

## Troubleshooting
Sintoma:
Hipótese:
Teste:
Evidência:
Causa:
Correção:
Validação:
```

> Não versione arquivos temporários de lease como se fossem configuração.

---

# 11. Marco DHCP

Confira:

```bash
git status
```

Depois:

```bash
git add dhcp/
git status
git commit -m "Implanta e documenta DHCP com Kea"
git push
```

---

# Checklist

```text
[ ] Kea escuta somente na interface de laboratório.
[ ] pool está correto.
[ ] cliente obtém endereço por DHCP.
[ ] identifiquei o lease.
[ ] criei reserva para o cliente.
[ ] cliente recebeu 192.168.50.50.
[ ] DHCP informa DNS 192.168.50.10.
[ ] DHCP informa domínio empresa.test.
[ ] usei logs/captura como evidência.
[ ] documentei e versionei o serviço.
```
