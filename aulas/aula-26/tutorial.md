# Aula 26 — Monitoramento com SNMP

## Objetivo

Consultar remotamente informações do servidor usando:

```text
SNMP
```

Nesta aula:

```text
cli-redes2 → gerente
srv-redes2 → agente
UDP/161
```

> Usaremos SNMPv2c somente na rede isolada do laboratório.

---

# Bloco 0

Servidor:

```bash
sudo apt update
sudo apt install -y snmpd snmp
```

Cliente:

```bash
sudo apt update
sudo apt install -y snmp git gh
```

Garanta:

```text
srv-redes2 → 192.168.50.10
cli-redes2 → 192.168.50.20
```

Prepare seu portfólio.

---

# Parte 1 — Configure o agente

Servidor:

```bash
sudo cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.original
```

Edite:

```bash
sudo nano /etc/snmp/snmpd.conf
```

Utilize:

```conf
agentAddress udp:161

rocommunity redes2lab 192.168.50.0/24

sysLocation Laboratorio Redes II
sysContact professor@empresa.test
```

Reinicie:

```bash
sudo systemctl restart snmpd
```

Verifique:

```bash
systemctl is-active snmpd
sudo ss -lunp | grep ':161'
```

---

# Parte 2 — Consulte o nome do sistema

Cliente:

```bash
snmpget -v2c -c redes2lab \
  192.168.50.10 \
  1.3.6.1.2.1.1.5.0
```

Resultado:

```text
____________________________________________________________
```

---

# Parte 3 — Consulte o uptime

```bash
snmpget -v2c -c redes2lab \
  192.168.50.10 \
  1.3.6.1.2.1.1.3.0
```

---

# Parte 4 — Faça um walk

```bash
snmpwalk -v2c -c redes2lab \
  192.168.50.10 \
  1.3.6.1.2.1.1
```

Observe vários objetos.

---

# Parte 5 — Interfaces

```bash
snmpwalk -v2c -c redes2lab \
  192.168.50.10 \
  1.3.6.1.2.1.2.2.1.2
```

No servidor:

```bash
ip -br link
```

Compare os nomes.

---

# Parte 6 — Contadores

O professor indicará a interface e os OIDs de contadores que serão consultados.

Registre:

```text
Interface:
____________________________________________________________

Contador antes:
____________________________________________________________
```

Gere tráfego entre cliente e servidor.

Consulte novamente.

```text
Contador depois:
____________________________________________________________
```

Explique a diferença:

____________________________________________________________________

---

# Parte 7 — Capture SNMP

Servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn -A 'udp port 161'
```

Cliente: repita um `snmpget`.

Observe a captura.

---

# Parte 8 — Segurança

Responda:

### A community do SNMPv2c deve ser tratada como senha segura?

```text
☐ Sim
☐ Não
```

### Devemos usar essa configuração fora da rede isolada do laboratório?

```text
☐ Sim
☐ Não
```

Por quê?

____________________________________________________________________

---

# Parte 9 — SNMPv3

Registre a ideia:

```text
SNMPv3 pode adicionar:
- autenticação;
- integridade;
- privacidade/criptografia.
```

Não será necessário configurá-lo nesta aula.

---

# Parte 10 — Observabilidade

Complete:

```text
SNMP:
____________________________________________________________

Zabbix:
____________________________________________________________

Prometheus:
____________________________________________________________

Grafana:
____________________________________________________________
```

O objetivo não é escolher uma única “melhor” ferramenta.

---

# Parte 11 — Portfólio

Crie:

```text
monitoramento/aula-26/
├── README.md
└── snmpd.conf
```

README:

```markdown
# Aula 26 — SNMP

## Agente
- endereço:
- porta:
- versão:

## Consultas
- hostname:
- uptime:
- interfaces:

## Contadores
- interface:
- antes:
- tráfego:
- depois:

## Segurança
Por que SNMPv2c ficou restrito à REDES2?

## Observabilidade
Como uma ferramenta de monitoramento pode usar essas métricas?
```

Versione e encerre a autenticação.

---

# Próxima aula

Docker e containers.
