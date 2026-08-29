# Aula 04 — Processos, serviços, portas e SSH

## Situação-problema

Na aula anterior fizemos cliente e servidor se comunicarem por IP.

Hoje vamos responder uma pergunta importante:

> **Se o servidor responde ao ping, isso significa que todos os serviços dele estão funcionando?**

Não.

Nesta aula você vai instalar e operar o primeiro serviço de rede da disciplina: **SSH**.

Vamos relacionar:

```text
processo
serviço
porta
socket
log
acesso remoto
```

e provocar uma falha em que:

```text
ping funciona
SSH não funciona
```

O objetivo é perceber que **conectividade com a máquina e disponibilidade de um serviço são coisas diferentes**.

---

# Objetivos

Ao final da aula, você deverá conseguir:

- identificar processos;
- consultar e controlar serviços com `systemctl`;
- identificar portas em escuta com `ss`;
- instalar e testar SSH;
- acessar o servidor remotamente;
- consultar logs com `journalctl`;
- diagnosticar um serviço parado;
- explicar por que `ping` não prova que uma aplicação está funcionando;
- registrar evidências no seu portfólio.

---

# Topologia

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

                    SSH → TCP/22
```

---

# Bloco 0 — Preparação do ambiente

As VMs podem estar limpas novamente.

## 1. Configure os hostnames, se necessário

Cliente:

```bash
sudo hostnamectl set-hostname cli-redes2
```

Servidor:

```bash
sudo hostnamectl set-hostname srv-redes2
```

---

## 2. Verifique as interfaces

Nas duas VMs:

```bash
ip -br addr
```

Confirme que existem duas interfaces além de `lo`.

---

## 3. Verifique a rede interna

Servidor:

```text
192.168.50.10/24
```

Cliente:

```text
192.168.50.20/24
```

Se a configuração não existir mais, recupere a configuração utilizada na Aula 3 e recrie:

```text
/etc/netplan/60-redes2.yaml
```

Valide:

```bash
sudo netplan generate
sudo netplan try
```

---

## 4. Teste cliente → servidor

No cliente:

```bash
ping -c 3 192.168.50.10
```

Não continue enquanto cliente e servidor não conseguirem se alcançar pela rede interna.

---

## 5. Prepare seu portfólio

No cliente:

```bash
sudo apt update
sudo apt install -y git gh
```

Autentique:

```bash
gh auth login --web --git-protocol https
gh auth setup-git
```

Clone seu portfólio:

```bash
cd ~
git clone <URL-DO-SEU-REPOSITORIO>
cd <NOME-DA-PASTA>
```

Confira:

```bash
git log --oneline
```

---

# Parte 1 — Processo

Um **processo** é uma instância de um programa que está sendo executado.

No servidor:

```bash
ps aux | head
```

Você verá vários processos.

Não é necessário memorizar todos eles.

---

# Parte 2 — Serviço

Um **serviço** é um programa executado para fornecer determinada função ao sistema ou à rede.

Em Linux, serviços em segundo plano também são frequentemente chamados de **daemons**.

No SSH teremos, de forma simplificada:

```text
cliente → ssh
servidor → sshd
```

---

# Parte 3 — Instale o SSH

## Servidor

```bash
sudo apt update
sudo apt install -y openssh-server iproute2
```

## Cliente

```bash
sudo apt update
sudo apt install -y openssh-client iproute2
```

---

# Parte 4 — Consulte o serviço

No servidor:

```bash
systemctl status ssh
```

Observe especialmente:

```text
Loaded:
Active:
Main PID:
```

---

# Parte 5 — Comandos básicos de serviço

Não execute todos aleatoriamente. Leia primeiro.

```bash
sudo systemctl start ssh
sudo systemctl stop ssh
sudo systemctl restart ssh
sudo systemctl enable ssh
sudo systemctl disable ssh
```

Significado:

```text
start   → inicia agora
stop    → para agora
restart → reinicia agora
enable  → configura início automático
disable → remove início automático
```

Consulte:

```bash
systemctl is-active ssh
```

e:

```bash
systemctl is-enabled ssh
```

---

# Parte 6 — Porta e socket

Um endereço IP identifica uma interface/máquina na rede.

Uma porta identifica um ponto de comunicação usado por uma aplicação.

Nosso servidor SSH será acessado em:

```text
192.168.50.10:22
```

O SSH utiliza normalmente:

```text
TCP/22
```

---

# Parte 7 — Veja o que está escutando

No servidor:

```bash
ss -lntp
```

Significado:

```text
-l → listening
-n → números
-t → TCP
-p → processo
```

Procure uma linha contendo:

```text
:22
```

Você pode filtrar:

```bash
ss -lntp | grep ':22'
```

---

# Parte 8 — Primeiro acesso SSH

Antes:

```bash
systemctl is-active ssh
```

Depois:

```bash
ss -lntp | grep ':22'
```

No cliente:

```bash
ping -c 3 192.168.50.10
```

Agora conecte:

```bash
ssh <USUARIO-DO-SERVIDOR>@192.168.50.10
```

Substitua pelo usuário real existente no servidor.

Na primeira conexão, o SSH pode apresentar uma mensagem sobre a chave do host.

Leia e confirme conforme orientação do professor.

Depois de entrar:

```bash
hostname
```

Resultado esperado:

```text
srv-redes2
```

Execute:

```bash
whoami
```

Quando terminar:

```bash
exit
```

---

# Parte 9 — De onde os comandos estão sendo executados?

Antes da conexão SSH:

```bash
hostname
```

deve indicar o cliente.

Durante a conexão SSH:

```bash
hostname
```

deve indicar o servidor.

Responda:

> Ao usar SSH, o teclado continua no computador cliente. Onde os comandos são executados?

____________________________________________________________________

---

# Parte 10 — Observe conexões SSH

Abra uma sessão SSH e mantenha-a ativa.

No servidor, em outro terminal:

```bash
ps aux | grep ssh
```

Depois:

```bash
ss -tnp | grep ':22'
```

Observe que pode existir:

```text
LISTEN
```

para o servidor aguardando conexões e:

```text
ESTAB
```

para uma conexão já estabelecida.

---

# Parte 11 — Logs

No servidor:

```bash
sudo journalctl -u ssh -n 20
```

Observe os registros recentes.

Agora acompanhe em tempo real:

```bash
sudo journalctl -u ssh -f
```

No cliente, faça outra tentativa de conexão SSH.

Observe se aparecem novas mensagens.

Para sair do acompanhamento:

```text
Ctrl+C
```

---

# Parte 12 — Incidente proposital

Agora vamos provocar uma falha.

No servidor:

```bash
sudo systemctl stop ssh
```

Não faça mais nada ainda.

---

# Parte 13 — Observe o sintoma

No cliente:

```bash
ping -c 3 192.168.50.10
```

Registre:

```text
Resultado do ping:

____________________________________________________________
```

Agora:

```bash
ssh <USUARIO-DO-SERVIDOR>@192.168.50.10
```

Registre a mensagem:

```text
____________________________________________________________

____________________________________________________________
```

---

# Parte 14 — A rede está fora?

Responda antes de corrigir:

```text
☐ Sim
☐ Não
☐ Ainda não tenho evidência suficiente
```

Explique:

____________________________________________________________________

____________________________________________________________________

---

# Parte 15 — Diagnóstico

Use o método:

```text
Sintoma
→ Hipótese
→ Teste
→ Evidência
→ Causa
→ Correção
→ Validação
```

## Sintoma

____________________________________________________________________

## Hipótese

____________________________________________________________________

---

## 1. Verifique conectividade

No cliente:

```bash
ping -c 3 192.168.50.10
```

## Evidência

____________________________________________________________________

---

## 2. Verifique o serviço

No servidor:

```bash
systemctl status ssh
```

## Evidência

____________________________________________________________________

---

## 3. Verifique a porta

```bash
ss -lntp | grep ':22'
```

## Evidência

____________________________________________________________________

---

## 4. Consulte logs

```bash
sudo journalctl -u ssh -n 20
```

## Evidência

____________________________________________________________________

---

# Parte 16 — Identifique a causa

Causa:

____________________________________________________________________

---

# Parte 17 — Corrija

No servidor:

```bash
sudo systemctl start ssh
```

Confirme:

```bash
systemctl is-active ssh
```

Depois:

```bash
ss -lntp | grep ':22'
```

---

# Parte 18 — Valide de ponta a ponta

No cliente:

```bash
ssh <USUARIO-DO-SERVIDOR>@192.168.50.10
```

Se entrar, execute:

```bash
hostname
```

Depois:

```bash
exit
```

Validação:

____________________________________________________________________

---

# Parte 19 — Compare os testes

Complete:

| Teste | O que ele ajuda a verificar? |
|---|---|
| `ping 192.168.50.10` | |
| `systemctl status ssh` | |
| `ss -lntp` | |
| `ssh usuario@192.168.50.10` | |
| `journalctl -u ssh` | |

---

# Parte 20 — Documente no portfólio

No repositório individual:

```bash
mkdir -p rede/aula-04
nano rede/aula-04/README.md
```

Use:

```markdown
# Aula 04 — Serviços, portas e SSH

## Ambiente

Servidor:
- hostname: srv-redes2
- IPv4: 192.168.50.10/24

Cliente:
- hostname: cli-redes2
- IPv4: 192.168.50.20/24

## Serviço SSH

Estado do serviço:

Saída relevante de `ss -lntp`:

Teste de acesso:

## Incidente

### Sintoma

### Hipótese

### Testes executados

### Evidências

### Causa

### Correção

### Validação

## Síntese

Explique a diferença entre:
- host alcançável;
- porta em escuta;
- serviço ativo;
- acesso de ponta a ponta.
```

Preencha com o que realmente observou.

---

# Parte 21 — Versione

```bash
git status
git add rede/aula-04
git diff --cached
git commit -m "Aula 04 - documenta servico SSH"
git push
```

---

# Parte 22 — Logout

```bash
gh auth logout
```

Depois:

```bash
gh auth status
```

---

# Testes finais

## Servidor

```bash
systemctl is-active ssh
ss -lntp | grep ':22'
```

## Cliente

```bash
ping -c 3 192.168.50.10
ssh <USUARIO-DO-SERVIDOR>@192.168.50.10
```

---

# O que deve estar salvo no portfólio

```text
rede/
└── aula-04/
    └── README.md
```

---

# Você deve ter aprendido

Ao final, seja capaz de explicar:

```text
ping funcionando
```

não significa:

```text
todos os serviços funcionando
```

E saiba responder:

> Como posso verificar se o problema está na conectividade, no serviço, na porta ou na aplicação?

---

# Próxima aula

Na próxima aula vamos transformar essas verificações em um método de troubleshooting mais completo e observar o tráfego real com:

```text
tcpdump
ARP
ICMP
TCP
```

incluindo o estabelecimento de uma conexão TCP.
