# Aula 07 — Recuperação e Troubleshooting do DHCP

> **Objetivo:** colocar servidor e cliente em um estado conhecido e funcional antes de continuar a configuração DHCP.
>
> Siga o roteiro na ordem. Não pule etapas e não faça alterações aleatórias.
>
> Método da disciplina:
>
> ```text
> Sintoma → Hipótese → Teste → Evidência → Correção → Validação
> ```

---

## Estado esperado ao final

```text
SERVIDOR
srv-r2-sNN
host0 → gerenciamento / Internet
lab0  → 192.168.50.10/24
Kea   → active
UDP/67 → em escuta

              │
              │ DHCP
              ▼

CLIENTE
cli-r2-sNN
lab0 → 192.168.50.100–150/24
configuração persistente → DHCP=ipv4
```

---

# 1. Verifique o servidor

## 1.1 Acesse seu servidor

No Windows:

```bash
ssh -p 22NN SEU_USUARIO@172.16.2.34
```

Exemplo:

```bash
ssh -p 2204 christian@172.16.2.34
```

## 1.2 Confirme a máquina

```bash
hostname
whoami
```

O hostname deve seguir:

```text
srv-r2-sNN
```

## 1.3 Verifique as interfaces

```bash
ip -br addr
```

O servidor deve possuir `host0` e `lab0`.

A `lab0` deve possuir:

```text
192.168.50.10/24
```

### Se `lab0` estiver sem `.10`

Confira:

```bash
cat /etc/systemd/network/80-lab0.network
```

O conteúdo esperado é:

```ini
[Match]
Name=lab0

[Network]
Address=192.168.50.10/24
LinkLocalAddressing=no
IPv6AcceptRA=no
```

Se necessário, corrija:

```bash
sudo nano /etc/systemd/network/80-lab0.network
```

Depois:

```bash
sudo networkctl reload
sudo networkctl reconfigure lab0
```

Confira:

```bash
ip -4 -br addr show lab0
```

Se `.10` ainda não aparecer, aplique o estado atual:

```bash
sudo ip link set lab0 up
sudo ip addr add 192.168.50.10/24 dev lab0
```

Valide novamente:

```bash
ip -4 -br addr show lab0
```

## 1.4 Verifique as rotas

```bash
ip route
```

Deve existir:

```text
192.168.50.0/24 dev lab0
```

A rota `default` deve continuar pela `host0`.

> Não configure gateway na `lab0`.

## 1.5 Verifique o `systemd-networkd`

```bash
systemctl is-active systemd-networkd
```

Esperado:

```text
active
```

Se estiver inativo:

```bash
sudo systemctl restart systemd-networkd
systemctl is-active systemd-networkd
```

---

# 2. Valide o servidor DHCP

## 2.1 Confira a configuração do Kea

Abra:

```bash
sudo nano /etc/kea/kea-dhcp4.conf
```

A configuração básica deve ser equivalente a:

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
        "id": 1,
        "subnet": "192.168.50.0/24",
        "pools": [
          {
            "pool": "192.168.50.100 - 192.168.50.150"
          }
        ]
      }
    ]
  }
}
```

Confira principalmente:

```text
interface → lab0
id        → 1
subnet    → 192.168.50.0/24
pool      → 192.168.50.100 - 192.168.50.150
```

## 2.2 Valide o JSON

```bash
sudo python3 -m json.tool /etc/kea/kea-dhcp4.conf >/dev/null
```

Se não aparecer nenhuma mensagem, o JSON está válido.

Se houver erro, veja o arquivo numerado:

```bash
sudo nl -ba /etc/kea/kea-dhcp4.conf
```

Corrija a linha indicada e teste novamente.

## 2.3 Valide o Kea

```bash
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
```

Mensagens `WARN` podem aparecer.

O que não pode aparecer é:

```text
ERROR
```

### Erro `missing parameter 'id'`

Confirme que dentro de `subnet4` existe:

```json
"id": 1,
```

### Erro relacionado à interface

Confirme:

```json
"interfaces": [ "lab0" ]
```

E verifique:

```bash
ip -br link show lab0
```

## 2.4 Inicie o serviço

Somente depois de a validação passar:

```bash
sudo systemctl restart kea-dhcp4-server
```

Confira:

```bash
systemctl is-active kea-dhcp4-server
```

Esperado:

```text
active
```

### Se continuar inativo

```bash
sudo journalctl -u kea-dhcp4-server -n 40 --no-pager
```

Leia a causa, corrija a configuração e repita:

```bash
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
sudo systemctl restart kea-dhcp4-server
systemctl is-active kea-dhcp4-server
```

## 2.5 Confirme UDP/67

```bash
sudo ss -lunp | grep ':67'
```

Se nada aparecer, volte à validação e aos logs do Kea.

---

# 3. Descubra o estado do cliente

Antes de modificar qualquer coisa, descubra se o cliente ainda usa `.20` ou se já recebeu DHCP.

## 3.1 Teste o endereço antigo

No servidor:

```bash
ping -c 2 192.168.50.20
```

Se responder:

```bash
ssh SEU_USUARIO@192.168.50.20
```

Se entrar, siga para a seção **4**.

## 3.2 Se `.20` não responder, procure leases

No servidor:

```bash
sudo tail -n 20 /var/lib/kea/kea-leases4.csv
```

Procure um endereço entre:

```text
192.168.50.100
```

e:

```text
192.168.50.150
```

Teste o endereço encontrado:

```bash
ping -c 2 IP_ENCONTRADO
```

Depois:

```bash
ssh SEU_USUARIO@IP_ENCONTRADO
```

Se entrar, siga para a seção **4**.

## 3.3 Se não existir acesso nem por `.20` nem por um lease

No servidor, investigue antes de tentar correções aleatórias:

```bash
sudo journalctl -u kea-dhcp4-server -n 30 --no-pager
```

```bash
sudo tail -n 20 /var/lib/kea/kea-leases4.csv
```

E prepare uma captura:

```bash
sudo tcpdump -i lab0 -nn 'udp port 67 or udp port 68'
```

Se o cliente não puder ser acessado por nenhum endereço, registre esse estado para a recuperação administrativa do acesso. Não altere o servidor DHCP se ele já passou nas verificações anteriores.

---

# 4. Verifique o cliente

Dentro do cliente:

```bash
hostname
```

Esperado:

```text
cli-r2-sNN
```

Confira a interface:

```bash
ip -4 -br addr show lab0
```

Confira a configuração persistente:

```bash
cat /etc/systemd/network/80-lab0.network
```

O estado final desejado é:

```ini
[Match]
Name=lab0

[Network]
DHCP=ipv4
LinkLocalAddressing=no
IPv6AcceptRA=no
```

Confira também:

```bash
systemctl is-active systemd-networkd
```

Esperado:

```text
active
```

---

# 5. Identifique seu caso
Identifique seu caso de acordo com as configurações e diagnóstico do **CLIENTE.**

## Caso A — o arquivo ainda contém `Address=192.168.50.20/24`

O **CLIENTE** ainda está configurado estaticamente.

Edite:

```bash
sudo nano /etc/systemd/network/80-lab0.network
```

Deixe:

```ini
[Match]
Name=lab0

[Network]
DHCP=ipv4
LinkLocalAddressing=no
IPv6AcceptRA=no
```

Salve.

Execute um comando por vez:

```bash
sudo networkctl reload
```

```bash
sudo networkctl reconfigure lab0
```

```bash
sudo networkctl renew lab0
```

Aguarde:

```bash
sleep 3
```

Confira:

```bash
ip -4 -br addr show lab0
```

- Se aparecerem `.20` e um IP entre `.100` e `.150`, siga para o **Caso C**.
- Se aparecer **apenas** um IP entre `.100` e `.150`, siga para o **Caso D**.
- Se continuar **apenas** `.20`, siga para o **Caso B**.

---

## Caso B — o arquivo contém `DHCP=ipv4`, mas só aparece `.20`

**Não remova `.20`.** Ele ainda mantém seu acesso SSH.

Execute:

```bash
sudo networkctl reload
```

```bash
sudo networkctl reconfigure lab0
```

```bash
sudo networkctl renew lab0
```

Aguarde:

```bash
sleep 3
```

Confira:

```bash
ip -4 -br addr show lab0
```

### Se aparecer um segundo endereço

Siga para o **Caso C**.

### Se continuar somente `.20`

No cliente:

```bash
networkctl status lab0
```

```bash
sudo journalctl -u systemd-networkd -n 30 --no-pager
```

No servidor:

```bash
sudo tail -n 20 /var/lib/kea/kea-leases4.csv
```

```bash
sudo journalctl -u kea-dhcp4-server -n 30 --no-pager
```

Se ainda não estiver claro, no servidor abra:

```bash
sudo tcpdump -i lab0 -nn 'udp port 67 or udp port 68'
```

No cliente tente novamente:

```bash
sudo networkctl renew lab0
```

Interprete a captura:

```text
DISCOVER + OFFER + REQUEST + ACK
→ DHCP funcionou

DISCOVER repetido, sem OFFER
→ investigar Kea/servidor

nenhum DHCPDISCOVER
→ investigar cliente/systemd-networkd
```

---

## Caso C — aparecem `.20` e um endereço DHCP

Exemplo:

```text
192.168.50.20/24
192.168.50.104/24
```

Este é o estado ideal para realizar a transição com segurança.

Anote o endereço DHCP:

```text
Meu novo IP: ______________________________
```

**Antes de remover `.20`**, abra outra sessão no servidor e teste:

```bash
ping -c 2 IP_DHCP
```

Se responder, volte ao cliente e remova o endereço antigo:

```bash
sudo ip addr del 192.168.50.20/24 dev lab0
```

A sessão SSH pela `.20` será encerrada. Isso é esperado.

No servidor, reconecte:

```bash
ssh SEU_USUARIO@IP_DHCP
```

---

## Caso D — existe apenas um endereço entre `.100` e `.150`

Exemplo:

```text
192.168.50.107/24
```

O cliente já está corretamente usando DHCP.

Não adicione nem remova endereços.

Siga para a validação final.

---

## Caso E — `DHCP=ipv4`, mas `lab0` está sem IPv4

No cliente:

```bash
sudo networkctl reload
sudo networkctl reconfigure lab0
sudo networkctl renew lab0
```

Confira:

```bash
networkctl status lab0
```

```bash
sudo journalctl -u systemd-networkd -n 30 --no-pager
```

No servidor:

```bash
sudo journalctl -u kea-dhcp4-server -n 30 --no-pager
```

```bash
sudo tail -n 20 /var/lib/kea/kea-leases4.csv
```

Se ainda não houver endereço, abra no **servidor**:

```bash
sudo tcpdump -i lab0 -nn 'udp port 67 or udp port 68'
```

E provoque novamente no cliente:

```bash
sudo networkctl renew lab0
```

Use a captura para identificar em qual lado está a falha.

---

# 6. Validação final

## 6.1 No cliente

```bash
ip -4 -br addr show lab0
```

O estado correto deve apresentar somente um IPv4 entre:

```text
192.168.50.100/24
```

e:

```text
192.168.50.150/24
```

Confira:

```bash
networkctl status lab0
```

Teste cliente → servidor:

```bash
ping -c 3 192.168.50.10
```

## 6.2 No servidor

Saia do cliente:

```bash
exit
```

Teste servidor → cliente:

```bash
ping -c 3 IP_DO_CLIENTE
```

Teste SSH:

```bash
ssh SEU_USUARIO@IP_DO_CLIENTE
```

---

# 7. Registre as evidências

```text
Hostname do servidor:
____________________________________________

IP da lab0 do servidor:
____________________________________________

Kea:
[ ] active
[ ] inactive

UDP/67:
[ ] presente
[ ] ausente

Configuração inicial do cliente:
[ ] estática
[ ] DHCP

IP inicial do cliente:
____________________________________________

IP recebido por DHCP:
____________________________________________
```

---

# 8. Se algo ainda não funcionar

Não tente comandos aleatórios. Responda às perguntas abaixo em ordem:

```text
1. O servidor possui 192.168.50.10/24?
2. A rota da rede 192.168.50.0/24 existe?
3. O systemd-networkd está active?
4. O JSON do Kea é válido?
5. kea-dhcp4 -t passa sem ERROR?
6. kea-dhcp4-server está active?
7. UDP/67 está em escuta?
8. O cliente contém DHCP=ipv4?
9. O systemd-networkd do cliente está active?
10. O cliente envia DHCPDISCOVER?
11. O servidor responde DHCPOFFER?
12. Ocorrem DHCPREQUEST e DHCPACK?
13. Existe lease no servidor?
14. O novo IP responde ao ping?
15. O SSH funciona no novo IP?
```

Ferramentas principais:

```bash
ip -br addr
ip route
networkctl status
systemctl is-active
ss -lunp
journalctl
tail
ping
tcpdump
```

Use as evidências para decidir o próximo passo.

---

# Checklist final

```text
[ ] servidor possui 192.168.50.10/24
[ ] rota default do servidor continua pela host0
[ ] systemd-networkd está active
[ ] JSON do Kea é válido
[ ] kea-dhcp4 -t não apresenta ERROR
[ ] kea-dhcp4-server está active
[ ] UDP/67 está em escuta
[ ] cliente possui DHCP=ipv4
[ ] cliente recebeu IP entre .100 e .150
[ ] endereço antigo .20 não permanece ativo
[ ] cliente pinga 192.168.50.10
[ ] servidor pinga o cliente
[ ] SSH funciona usando o endereço DHCP
```

---

# Regra principal

> **Nunca remova `192.168.50.20/24` enquanto ainda não existir outro endereço DHCP funcional na `lab0`.**

A ordem segura é:

```text
obter DHCP
    ↓
confirmar o novo endereço
    ↓
testar o novo endereço
    ↓
remover .20
    ↓
reconectar pelo IP DHCP
```
