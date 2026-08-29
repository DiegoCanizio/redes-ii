# Aula 05 — Troubleshooting estruturado e captura de pacotes

## Situação-problema

Quando alguém diz:

> “A rede não está funcionando.”

isso ainda não é um diagnóstico.

Pode haver problema na:

```text
interface
endereço
rede
rota
nome
porta
serviço
filtragem
aplicação
```

Nesta aula vamos organizar uma forma de investigar problemas e utilizar `tcpdump` para observar os pacotes que realmente circulam na rede.

> **Sintoma não é causa. Antes de alterar uma configuração, produza evidências.**

## Objetivos

Ao concluir esta aula, você deverá conseguir:

- aplicar uma sequência de troubleshooting;
- identificar interface, endereço e rota;
- verificar portas e serviços;
- capturar pacotes com `tcpdump`;
- observar ARP;
- observar ICMP;
- observar uma conexão TCP;
- reconhecer SYN, SYN/ACK e ACK;
- salvar uma captura `.pcap`;
- diagnosticar um problema de porta;
- registrar evidências antes da correção.

## Topologia

```text
                     INTERNET
                        │
                       NAT
            ┌───────────┴───────────┐
            │                       │
     ┌──────┴──────┐         ┌──────┴──────┐
     │ cli-redes2  │         │ srv-redes2  │
     │ .50.20/24   │         │ .50.10/24   │
     └──────┬──────┘         └──────┬──────┘
            │                       │
            └────── REDES2 ─────────┘
              192.168.50.0/24
```

# Bloco 0 — Preparação do ambiente

As VMs podem estar limpas novamente.

## 1. Hostnames

Cliente:

```bash
sudo hostnamectl set-hostname cli-redes2
```

Servidor:

```bash
sudo hostnamectl set-hostname srv-redes2
```

## 2. Rede interna

Confirme com:

```bash
ip -br addr
```

Servidor:

```text
192.168.50.10/24
```

Cliente:

```text
192.168.50.20/24
```

Se necessário, recupere a configuração Netplan da Aula 3.

Valide:

```bash
sudo netplan generate
sudo netplan try
```

## 3. Teste a rede

No cliente:

```bash
ping -c 3 192.168.50.10
```

## 4. Instale todas as ferramentas necessárias

### Servidor

```bash
sudo apt update
sudo apt install -y openssh-server tcpdump netcat-openbsd iproute2 iputils-ping
```

### Cliente

```bash
sudo apt update
sudo apt install -y openssh-client tcpdump netcat-openbsd iproute2 iputils-ping git gh
```

## 5. Garanta que o SSH esteja ativo

No servidor:

```bash
sudo systemctl start ssh
systemctl is-active ssh
```

## 6. Prepare o portfólio

No cliente:

```bash
gh auth login --web --git-protocol https
gh auth setup-git
```

Depois:

```bash
cd ~
git clone <URL-DO-SEU-REPOSITORIO>
cd <NOME-DA-PASTA>
```

Confira:

```bash
git log --oneline
```

# Parte 1 — Método de troubleshooting

Utilizaremos esta sequência como referência:

```text
1. Interface
2. Endereço
3. Rede
4. Rota
5. Nome
6. Porta
7. Serviço
8. Filtragem
9. Aplicação
```

Nem todo problema exigirá todos os passos.

O importante é **não começar alterando coisas aleatoriamente**.

## Interface

```bash
ip -br link
```

Pergunta: a interface existe e está ativa?

## Endereço

```bash
ip -br addr
```

Pergunta: o endereço está correto?

## Rede

Pergunta: origem e destino pertencem à mesma rede?

No laboratório:

```text
192.168.50.10/24
192.168.50.20/24
```

sim.

## Rota

```bash
ip route
ip route get 192.168.50.10
```

Pergunta: por onde o Linux pretende enviar o pacote?

## Nome

Quando usamos nomes, precisamos saber se o nome está sendo convertido para o endereço esperado. DNS será estudado em profundidade mais adiante.

## Porta

No servidor:

```bash
ss -lntp
```

Pergunta: existe uma aplicação escutando na porta esperada?

## Serviço

```bash
systemctl status ssh
```

Pergunta: o serviço está ativo?

## Filtragem

Mais adiante estudaremos firewall. Por enquanto, saiba que um filtro pode permitir um tipo de tráfego e bloquear outro.

## Aplicação

Teste finalmente o serviço do ponto de vista do cliente.

Exemplo:

```bash
ssh <USUARIO>@192.168.50.10
```

# Parte 2 — Regra de ouro

Antes de corrigir:

```text
Observe
  ↓
Formule uma hipótese
  ↓
Escolha um teste
  ↓
Registre a evidência
```

Só então:

```text
Corrija
  ↓
Valide
```

# Parte 3 — Conhecendo o tcpdump

`tcpdump` permite observar pacotes em uma interface.

## 7. Liste as interfaces

No servidor:

```bash
sudo tcpdump -D
```

Compare com:

```bash
ip -br addr
```

Identifique a interface ligada à `REDES2`.

```text
Interface REDES2 do servidor: ______________________________
```

## 8. Inicie uma captura simples

```bash
sudo tcpdump -i <INTERFACE-REDES2>
```

Aguarde alguns segundos e interrompa com:

```text
Ctrl+C
```

## 9. Evite resolução de nomes

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn
```

`-nn` mantém endereços e portas em formato numérico.

Interrompa com `Ctrl+C`.

# Parte 4 — Capture ARP e ICMP

No servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn 'arp or icmp'
```

Deixe a captura executando.

## 10. Force uma nova descoberta de vizinho

No cliente, descubra sua interface interna:

```bash
ip route get 192.168.50.10
```

Depois:

```bash
sudo ip neigh flush dev <INTERFACE-REDES2>
```

Agora:

```bash
ping -c 3 192.168.50.10
```

## 11. Observe no servidor

Procure mensagens relacionadas a:

```text
ARP Request
ARP Reply
ICMP echo request
ICMP echo reply
```

Pare a captura com `Ctrl+C`.

# Parte 5 — Interprete

## Qual protocolo apareceu antes do primeiro ICMP?

```text
____________________________________
```

## O que o cliente estava tentando descobrir?

____________________________________________________________________

## Depois dessa descoberta, que protocolo foi utilizado pelo `ping`?

```text
____________________________________
```

# Parte 6 — Salve uma captura ARP/ICMP

No servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn -c 10 -w aula-05-arp-icmp.pcap 'arp or icmp'
```

Enquanto o comando aguarda, no cliente:

```bash
sudo ip neigh flush dev <INTERFACE-REDES2>
ping -c 3 192.168.50.10
```

Quando terminar, no servidor:

```bash
tcpdump -nn -r aula-05-arp-icmp.pcap
```

# Parte 7 — Capture uma conexão TCP

No servidor:

```bash
systemctl is-active ssh
ss -lntp | grep ':22'
```

Inicie:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn 'tcp port 22'
```

## 12. Abra uma nova conexão

No cliente:

```bash
ssh <USUARIO>@192.168.50.10
```

Depois de entrar:

```bash
hostname
exit
```

Pare o `tcpdump` com `Ctrl+C`.

# Parte 8 — O início de uma conexão TCP

No início da captura, procure flags relacionadas a:

```text
SYN
SYN, ACK
ACK
```

De forma simplificada:

```text
cliente  → SYN      → quero iniciar a conexão
servidor → SYN/ACK  → recebi e estou pronto
cliente  → ACK      → confirmação
```

Esse processo é chamado de **three-way handshake**.

Não é necessário interpretar números de sequência nesta aula.

# Parte 9 — Salve a captura TCP

No servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn -c 20 -w aula-05-tcp-ssh.pcap 'tcp port 22'
```

No cliente, abra outra conexão SSH e encerre-a.

Depois, no servidor:

```bash
tcpdump -nn -r aula-05-tcp-ssh.pcap
```

# Parte 10 — Incidente controlado

Você recebeu a seguinte informação:

> Existe um serviço TCP de teste no servidor e ele deve ser acessado na porta 8080.

Não altere configurações ainda.

## 13. Teste a conectividade

No cliente:

```bash
ping -c 3 192.168.50.10
```

## 14. Teste a porta informada

```bash
nc -vz 192.168.50.10 8080
```

Registre:

```text
____________________________________________________________

____________________________________________________________
```

# Parte 11 — Diagnostique

Use o método.

## Sintoma

____________________________________________________________________

## Hipótese

____________________________________________________________________

## Interface

```bash
ip -br link
```

Evidência:

____________________________________________________________________

## Endereço

```bash
ip -br addr
```

Evidência:

____________________________________________________________________

## Rota

```bash
ip route get 192.168.50.10
```

Evidência:

____________________________________________________________________

## Porta no servidor

No servidor:

```bash
ss -lntp | grep -E ':8080|:8081'
```

Evidência:

____________________________________________________________________

# Parte 12 — Capture a tentativa

No servidor:

```bash
sudo tcpdump -i <INTERFACE-REDES2> -nn 'tcp port 8080 or tcp port 8081'
```

No cliente:

```bash
nc -vz 192.168.50.10 8080
```

Observe e pare com `Ctrl+C`.

# Parte 13 — Identifique a causa

Complete:

```text
Porta informada ao cliente: __________________

Porta realmente em escuta: __________________

Causa:
____________________________________________________________
```

# Parte 14 — Corrija e valide

Use a porta realmente observada:

```bash
nc -vz 192.168.50.10 8081
```

Resultado:

```text
____________________________________________________________
```

## Teste com dados

No servidor, quando orientado:

```bash
nc -l 8081
```

No cliente:

```bash
nc 192.168.50.10 8081
```

Digite:

```text
teste aula 05
```

Observe no servidor.

> Dependendo da implementação do `nc`, o processo de escuta pode terminar depois da conexão. Execute novamente quando necessário.

# Parte 15 — Relatório do incidente

## Sintoma

____________________________________________________________________

## Hipótese

____________________________________________________________________

## Testes executados

____________________________________________________________________

## Evidências

Inclua pelo menos duas evidências diferentes.

____________________________________________________________________

____________________________________________________________________

## Causa

____________________________________________________________________

## Correção

____________________________________________________________________

## Validação

____________________________________________________________________

# Parte 16 — Copie as capturas para o portfólio

No cliente, entre no repositório:

```bash
cd ~/<NOME-DA-PASTA>
mkdir -p rede/aula-05
cd rede/aula-05
```

Se as capturas estão no diretório pessoal do servidor:

```bash
scp <USUARIO>@192.168.50.10:~/aula-05-arp-icmp.pcap .
scp <USUARIO>@192.168.50.10:~/aula-05-tcp-ssh.pcap .
```

Confira:

```bash
ls -lh
```

# Parte 17 — Documente

Crie:

```bash
nano README.md
```

Use:

```markdown
# Aula 05 — Troubleshooting e captura de pacotes

## Método utilizado

1. Interface
2. Endereço
3. Rede
4. Rota
5. Nome
6. Porta
7. Serviço
8. Filtragem
9. Aplicação

## Captura ARP/ICMP

Interface capturada:

O que foi observado antes do ICMP:

Resumo da sequência:

## Captura TCP/SSH

Interface capturada:

Porta:

Handshake observado:

## Incidente TCP

### Sintoma
### Hipótese
### Testes
### Evidências
### Causa
### Correção
### Validação

## Síntese

Explique por que “não funciona” não é um diagnóstico.
```

Preencha com suas observações reais.

# Parte 18 — Versione

Volte à raiz do portfólio:

```bash
git status
git add rede/aula-05
git diff --cached --stat
git commit -m "Aula 05 - registra troubleshooting e capturas"
git push
```

# Parte 19 — Logout

```bash
gh auth logout
gh auth status
```

# O que deve estar salvo

```text
rede/
└── aula-05/
    ├── README.md
    ├── aula-05-arp-icmp.pcap
    └── aula-05-tcp-ssh.pcap
```

# Testes de aprendizagem

### Se `ping` funciona, isso prova que SSH funciona?

```text
☐ Sim
☐ Não
```

### Se um pacote TCP chega ao servidor, isso prova que existe uma aplicação escutando naquela porta?

```text
☐ Sim
☐ Não
```

### Se `ss` mostra uma porta em `LISTEN`, isso prova sozinho que um cliente remoto conseguirá acessá-la?

```text
☐ Sim
☐ Não
```

### Por que precisamos combinar evidências?

____________________________________________________________________

____________________________________________________________________

# Você deve ter aprendido

Um bom troubleshooting não começa com:

```text
“vou reiniciar tudo”
```

Ele começa com:

```text
“qual é o sintoma e que evidência posso produzir?”
```

# Próxima aula

Na próxima aula vamos observar um protocolo que automatiza a configuração de rede do cliente.

Antes de instalar qualquer servidor, vamos capturar e interpretar:

```text
DHCP Discover
DHCP Offer
DHCP Request
DHCP ACK
```

processo conhecido como **DORA**.
