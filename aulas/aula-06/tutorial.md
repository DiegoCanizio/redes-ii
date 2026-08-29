# Aula 06 — Observando DHCP: Discover, Offer, Request e ACK

## Situação-problema

Até agora configuramos manualmente:

```text
192.168.50.20/24
```

no cliente.

Nesta aula o cliente passará a receber automaticamente um endereço na rede `REDES2`.

Antes de aprender a configurar o servidor, vamos observar o protocolo funcionando.

```text
Discover
  ↓
Offer
  ↓
Request
  ↓
ACK
```

Essa sequência é conhecida como **DORA**.

---

# Objetivos

Você deverá:

- compreender a finalidade do DHCP;
- identificar UDP 67 e 68;
- capturar o DORA;
- identificar o endereço concedido;
- verificar que a Internet continua pela NAT;
- salvar a captura;
- documentar evidências.

---

# Bloco 0 — Ambiente

## Servidor

Hostname:

```bash
sudo hostnamectl set-hostname srv-redes2
```

A rede interna deve ser:

```text
192.168.50.10/24
```

Instale:

```bash
sudo apt update
sudo apt install -y kea-dhcp4-server tcpdump iproute2
```

## Cliente

```bash
sudo hostnamectl set-hostname cli-redes2
sudo apt update
sudo apt install -y tcpdump iproute2 iputils-ping git gh
```

Prepare seu portfólio:

```bash
gh auth login --web --git-protocol https
gh auth setup-git
cd ~
git clone <URL-DO-SEU-REPOSITORIO>
cd <NOME-DA-PASTA>
```

---

# Parte 1 — Antes do DHCP

No cliente:

```bash
ip -br addr
ip route
```

Identifique a interface `REDES2`.

MAC da interface:

```bash
ip link show <INTERFACE-REDES2>
```

Registre:

```text
Interface: ___________________________
MAC:       ___________________________
```

---

# Parte 2 — O servidor de observação

Nesta aula o professor fornecerá uma configuração pronta do Kea.

Ela existe apenas para observarmos o protocolo antes de construirmos nossa própria configuração.

No servidor, faça backup:

```bash
sudo cp /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf.bak
```

Use o arquivo fornecido pelo professor e substitua:

```text
<INTERFACE-REDES2>
```

pelo nome real da interface interna.

Valide:

```bash
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
```

Depois:

```bash
sudo systemctl restart kea-dhcp4-server
systemctl is-active kea-dhcp4-server
```

---

# Parte 3 — Configure o cliente para pedir endereço

No cliente:

```bash
sudo nano /etc/netplan/60-redes2.yaml
```

Use:

```yaml
network:
  version: 2
  ethernets:
    <INTERFACE-REDES2>:
      dhcp4: true
      dhcp4-overrides:
        use-routes: false
```

Substitua a interface.

Valide:

```bash
sudo netplan generate
```

**Ainda não aplique.**

---

# Parte 4 — Inicie a captura

No servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn -vvv 'udp port 67 or udp port 68'
```

Agora, no cliente:

```bash
sudo netplan try
```

Confirme.

Observe a captura no servidor.

---

# Parte 5 — Identifique o DORA

Procure mensagens correspondentes a:

```text
Discover
Offer
Request
ACK
```

Preencha:

| Etapa | Quem enviou? | O que aconteceu? |
|---|---|---|
| Discover | | |
| Offer | | |
| Request | | |
| ACK | | |

---

# Parte 6 — Verifique o endereço

No cliente:

```bash
ip -br addr
```

IPv4 recebido:

```text
____________________________________
```

Ele deve pertencer ao pool:

```text
192.168.50.100–192.168.50.150
```

---

# Parte 7 — Verifique as rotas

```bash
ip route
```

Responda:

### Existe uma rota para `192.168.50.0/24`?

```text
☐ Sim
☐ Não
```

### A rota padrão mudou para REDES2?

```text
☐ Sim
☐ Não
```

### Por que ela não deve mudar?

____________________________________________________________________

---

# Parte 8 — Testes

```bash
ping -c 3 192.168.50.10
```

e:

```bash
ping -c 3 1.1.1.1
```

Ambos devem funcionar.

---

# Parte 9 — Salve a captura

No servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn -c 12 \
  -w aula-06-dhcp-dora.pcap \
  'udp port 67 or udp port 68'
```

Provoque nova negociação conforme orientação do professor.

Depois:

```bash
tcpdump -nn -vvv -r aula-06-dhcp-dora.pcap
```

---

# Parte 10 — Lease

Consulte:

```bash
networkctl status <INTERFACE-REDES2>
```

Procure informações relativas ao endereço DHCP.

Quando orientado:

```bash
sudo networkctl renew <INTERFACE-REDES2>
```

Uma renovação pode não apresentar exatamente o mesmo DORA completo.

---

# Parte 11 — Registre no portfólio

Crie:

```bash
mkdir -p dhcp/aula-06
```

Copie a captura do servidor para essa pasta com `scp`, se necessário.

Crie:

```bash
nano dhcp/aula-06/README.md
```

Use:

```markdown
# Aula 06 — DHCP DORA

## Cliente
- interface:
- MAC:
- IPv4 recebido:

## Sequência observada
- Discover:
- Offer:
- Request:
- ACK:

## Parâmetros
- servidor DHCP:
- endereço oferecido:
- lease observado:

## Rota
Explique por que a rota padrão continuou pela interface NAT.

## Síntese
Por que o cliente utiliza broadcast no início do processo?
```

---

# Parte 12 — Versione

```bash
git add dhcp/aula-06
git diff --cached --stat
git commit -m "Aula 06 - registra processo DHCP DORA"
git push
```

Depois:

```bash
gh auth logout
```

---

# Próxima aula

Na próxima aula você deixará de usar uma configuração pronta e construirá o servidor DHCP com **Kea**.
