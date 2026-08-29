# Aula 03 — Endereçamento IPv4, rotas e Netplan

## Situação-problema

Na aula anterior criamos duas máquinas virtuais conectadas à rede interna:

```text
REDES2
```

Mas essa rede ainda não possui endereçamento IPv4 definido por nós.

Nesta aula vamos transformá-la em:

```text
192.168.50.0/24
```

com:

```text
Servidor → 192.168.50.10/24
Cliente  → 192.168.50.20/24
```

A interface NAT continuará fornecendo acesso externo.

Ao final, cliente e servidor deverão conversar diretamente pela rede interna sem perder o acesso à Internet pela NAT.

> **Configurar um endereço não é apenas “colocar um IP”. É definir em que rede aquela interface participa e por onde o sistema enviará os pacotes.**

---

# Objetivos

Ao concluir esta aula, você deverá ser capaz de:

- identificar as interfaces NAT e interna;
- interpretar um endereço `/24`;
- distinguir rota conectada de rota padrão;
- configurar IPv4 estático com Netplan;
- validar a configuração antes de aplicá-la;
- testar conectividade;
- descobrir por qual interface um destino será alcançado;
- diagnosticar uma falha de endereçamento;
- documentar a configuração no seu portfólio.

---

# Topologia da aula

```text
                         INTERNET
                            │
                           NAT
                    ┌───────┴───────┐
                    │               │
             ┌──────┴──────┐ ┌──────┴──────┐
             │ cli-redes2  │ │ srv-redes2  │
             │             │ │             │
             │ REDES2:     │ │ REDES2:     │
             │ .50.20/24   │ │ .50.10/24   │
             └──────┬──────┘ └──────┬──────┘
                    │               │
                    └──── REDES2 ───┘
                     192.168.50.0/24
```

Nesta rede:

```text
Rede:      192.168.50.0/24
Servidor:  192.168.50.10/24
Cliente:   192.168.50.20/24
Broadcast: 192.168.50.255
```

> **Não existe roteador dentro de `REDES2`. Portanto, não configure gateway nessa interface.**

---

# Bloco 0 — Preparação do ambiente

As VMs podem ter sido restauradas desde a última aula.

Não presuma que alterações anteriores permanecem disponíveis.

## 1. Inicie as duas VMs

Você deverá ter:

```text
VM cliente
VM servidor
```

Verifique no hipervisor se ambas possuem:

```text
NIC 1 → NAT
NIC 2 → Rede Interna REDES2
```

Se as duas interfaces já estiverem presentes, não altere nada.

---

## 2. Reconfigure os hostnames, se necessário

Na VM cliente:

```bash
sudo hostnamectl set-hostname cli-redes2
```

Na VM servidor:

```bash
sudo hostnamectl set-hostname srv-redes2
```

Verifique em cada uma:

```bash
hostname
```

---

## 3. Observe as interfaces

Nas duas VMs:

```bash
ip -br addr
```

Não avance sem conseguir identificar duas interfaces além de `lo`.

Exemplo:

```text
lo       UNKNOWN  127.0.0.1/8
enp0s3   UP       10.0.2.15/24
enp0s8   UP
```

> Os nomes das suas interfaces podem ser diferentes.

---

## 4. Descubra qual interface é a NAT

Execute:

```bash
ip route show default
```

Exemplo:

```text
default via 10.0.2.2 dev enp0s3 proto dhcp
```

Nesse exemplo:

```text
enp0s3
```

é a interface NAT.

A outra interface será utilizada na rede interna `REDES2`.

Registre.

### Cliente

Interface NAT:

```text
____________________________________
```

Interface REDES2:

```text
____________________________________
```

### Servidor

Interface NAT:

```text
____________________________________
```

Interface REDES2:

```text
____________________________________
```

---

## 5. Prepare o portfólio no cliente

Na VM cliente:

```bash
sudo apt update
sudo apt install -y git gh iproute2 iputils-ping netplan.io
```

Autentique:

```bash
gh auth login --web --git-protocol https
```

Depois:

```bash
gh auth setup-git
gh auth status
```

Clone seu repositório individual:

```bash
cd ~
git clone <URL-DO-SEU-REPOSITORIO>
```

Entre na pasta criada:

```bash
cd <NOME-DA-PASTA>
```

Veja o histórico:

```bash
git log --oneline
```

Você deverá encontrar os commits das aulas anteriores.

---

# Parte 1 — O que significa `/24`?

Considere:

```text
192.168.50.10/24
```

O `/24` representa o tamanho do prefixo da rede.

Neste caso, a máscara equivalente é:

```text
255.255.255.0
```

Para nossa rede:

```text
Rede:      192.168.50.0
Hosts:     192.168.50.1 até 192.168.50.254
Broadcast: 192.168.50.255
```

Logo:

```text
192.168.50.10/24
192.168.50.20/24
```

estão na mesma rede.

## Pergunta

Para o cliente enviar um pacote diretamente ao servidor nessa rede, é necessário passar por um roteador?

```text
☐ Sim
☐ Não
```

---

# Parte 2 — Observe as rotas antes da configuração

Na VM cliente:

```bash
ip route
```

Na VM servidor:

```bash
ip route
```

Localize a linha:

```text
default via ...
```

Essa é a **rota padrão**.

Ela deverá permanecer associada à interface NAT.

---

## 6. Pergunte ao Linux como ele tentaria alcançar o servidor

No cliente, antes de configurar `REDES2`:

```bash
ip route get 192.168.50.10
```

Observe a interface indicada.

Registre:

```text
Interface escolhida antes da configuração: __________________
```

Depois repetiremos esse comando.

---

# Parte 3 — Conhecendo o Netplan

No servidor:

```bash
ls -l /etc/netplan/
```

Depois:

```bash
sudo cat /etc/netplan/*.yaml
```

Você poderá encontrar nomes como:

```text
00-installer-config.yaml
50-cloud-init.yaml
```

O nome pode variar.

> Não apague esses arquivos. Eles podem conter a configuração da interface NAT.

---

# Parte 4 — Faça backup antes de alterar

No servidor:

```bash
sudo mkdir -p /root/netplan-backup-aula03
sudo cp -a /etc/netplan/*.yaml /root/netplan-backup-aula03/
```

No cliente, faça o mesmo:

```bash
sudo mkdir -p /root/netplan-backup-aula03
sudo cp -a /etc/netplan/*.yaml /root/netplan-backup-aula03/
```

## Por quê?

Porque uma alteração de rede deve ser reversível.

---

# Parte 5 — Configure o servidor

Antes de editar, confirme novamente qual é a interface interna:

```bash
ip route show default
ip -br link
```

A interface da rota padrão é a NAT.

Use a outra interface para `REDES2`.

---

## 7. Crie um arquivo específico

No servidor:

```bash
sudo nano /etc/netplan/60-redes2.yaml
```

Digite:

```yaml
network:
  version: 2
  ethernets:
    <INTERFACE-INTERNA>:
      dhcp4: false
      addresses:
        - 192.168.50.10/24
```

Substitua:

```text
<INTERFACE-INTERNA>
```

pelo nome real.

### Exemplo

Se sua interface interna for `enp0s8`:

```yaml
network:
  version: 2
  ethernets:
    enp0s8:
      dhcp4: false
      addresses:
        - 192.168.50.10/24
```

---

## Atenção ao YAML

YAML depende da indentação.

Use **espaços**.

Não use tabulações.

Não acrescente:

```text
gateway4:
```

e não crie uma rota `default` nessa interface.

Também não invente:

```text
192.168.50.1
```

como gateway.

Não existe roteador em `REDES2`.

---

# Parte 6 — Valide antes de aplicar

No servidor:

```bash
sudo netplan generate
```

Se o comando apresentar erro, **não aplique a configuração**.

Leia a mensagem e corrija o arquivo.

Se não houver erro:

```bash
sudo netplan try
```

O Netplan aplicará temporariamente a configuração e solicitará confirmação.

Se tudo estiver correto, confirme.

> Caso o professor indique que `netplan try` não pode ser utilizado no ambiente, use `sudo netplan apply` somente depois de `sudo netplan generate` executar sem erros.

---

# Parte 7 — Verifique o servidor

```bash
ip -br addr
```

A interface interna deverá possuir:

```text
192.168.50.10/24
```

Agora:

```bash
ip route
```

Procure uma rota semelhante a:

```text
192.168.50.0/24 dev <INTERFACE-INTERNA> ...
```

Registre:

```text
Interface interna do servidor: __________________________
```

---

# Parte 8 — Configure o cliente

No cliente:

```bash
sudo nano /etc/netplan/60-redes2.yaml
```

Digite:

```yaml
network:
  version: 2
  ethernets:
    <INTERFACE-INTERNA>:
      dhcp4: false
      addresses:
        - 192.168.50.20/24
```

Substitua pelo nome real da interface interna.

Valide:

```bash
sudo netplan generate
```

Depois:

```bash
sudo netplan try
```

Confirme se a configuração estiver correta.

---

# Parte 9 — Verifique o cliente

```bash
ip -br addr
```

A interface interna deverá possuir:

```text
192.168.50.20/24
```

Veja as rotas:

```bash
ip route
```

Você deverá encontrar:

```text
192.168.50.0/24
```

associada à interface interna.

---

# Parte 10 — Teste cliente → servidor

No cliente:

```bash
ping -c 4 192.168.50.10
```

Resultado esperado:

```text
respostas do servidor
0% packet loss
```

---

# Parte 11 — Teste servidor → cliente

No servidor:

```bash
ping -c 4 192.168.50.20
```

---

# Parte 12 — Descubra por onde o pacote será enviado

No cliente:

```bash
ip route get 192.168.50.10
```

A saída deverá apontar para a interface interna.

Registre:

```text
Interface utilizada: ______________________________
```

No servidor:

```bash
ip route get 192.168.50.20
```

---

# Parte 13 — Observe a tabela de vizinhos

Depois dos testes:

```bash
ip neigh
```

Procure o outro endereço da rede:

```text
192.168.50.10
```

ou:

```text
192.168.50.20
```

Você provavelmente verá também um endereço MAC.

Não precisamos aprofundar esse mecanismo agora. Voltaremos a ele quando estudarmos captura de tráfego.

---

# Parte 14 — Confirme que a Internet continua funcionando

Nas duas VMs:

```bash
ip route show default
```

A rota padrão deve continuar pela interface NAT.

Teste:

```bash
ping -c 3 1.1.1.1
```

## Pergunta

Por que não configuramos um gateway em `REDES2`?

____________________________________________________________________

____________________________________________________________________

---

# Parte 15 — Incidente proposital

Agora vamos provocar uma falha.

> Não corrija antes de executar os testes solicitados.

No cliente, abra:

```bash
sudo nano /etc/netplan/60-redes2.yaml
```

Troque temporariamente:

```text
192.168.50.20/24
```

por:

```text
192.168.51.20/24
```

Valide:

```bash
sudo netplan generate
```

Aplique de acordo com a orientação do professor:

```bash
sudo netplan try
```

---

## 8. Observe o sintoma

```bash
ping -c 3 192.168.50.10
```

O esperado agora é uma falha.

Não conclua imediatamente que “a rede caiu”.

---

# Parte 16 — Diagnostique antes de corrigir

Preencha.

## Sintoma

____________________________________________________________________

## Hipótese inicial

____________________________________________________________________

Agora execute:

```bash
ip -br addr
```

Depois:

```bash
ip route
```

Depois:

```bash
ip route get 192.168.50.10
```

## Evidência encontrada

____________________________________________________________________

____________________________________________________________________

## Causa

____________________________________________________________________

---

# Parte 17 — Corrija

No cliente, restaure:

```text
192.168.50.20/24
```

Valide:

```bash
sudo netplan generate
sudo netplan try
```

Depois:

```bash
ping -c 4 192.168.50.10
```

E:

```bash
ip route get 192.168.50.10
```

## Validação

____________________________________________________________________

---

# Parte 18 — Registre a aula no portfólio

No repositório individual, crie:

```bash
mkdir -p rede/aula-03
```

Crie:

```bash
nano rede/aula-03/netplan-cliente.yaml
```

Registre a configuração utilizada no cliente.

Crie:

```bash
nano rede/aula-03/netplan-servidor.yaml
```

Registre a configuração utilizada no servidor.

> Use os nomes reais das interfaces observadas no seu ambiente.

---

# Parte 19 — Documente as evidências

Crie:

```bash
nano rede/aula-03/README.md
```

Use:

```markdown
# Aula 03 — Rede interna

## Cliente

- hostname: cli-redes2
- interface NAT:
- interface REDES2:
- IPv4 REDES2: 192.168.50.20/24

## Servidor

- hostname: srv-redes2
- interface NAT:
- interface REDES2:
- IPv4 REDES2: 192.168.50.10/24

## Testes

- ping cliente → servidor:
- ping servidor → cliente:
- acesso externo após a configuração:
- rota cliente → servidor:
- rota servidor → cliente:

## Incidente

### Sintoma

### Hipótese

### Teste

### Evidência

### Causa

### Correção

### Validação
```

Preencha com o que realmente ocorreu no seu ambiente.

---

# Parte 20 — Versione

No cliente:

```bash
git status
```

Adicione:

```bash
git add rede/aula-03
```

Revise:

```bash
git diff --cached
```

Crie o commit:

```bash
git commit -m "Aula 03 - configura rede interna"
```

Envie:

```bash
git push
```

---

# Parte 21 — Confirme no GitHub

Seu portfólio deverá conter algo semelhante a:

```text
rede/
└── aula-03/
    ├── README.md
    ├── netplan-cliente.yaml
    └── netplan-servidor.yaml
```

---

# Parte 22 — Encerre a autenticação

```bash
gh auth logout
```

Verifique:

```bash
gh auth status
```

---

# Testes finais

## Cliente

```bash
ip -br addr
ip route
ip route get 192.168.50.10
ping -c 3 192.168.50.10
```

## Servidor

```bash
ip -br addr
ip route
ip route get 192.168.50.20
ping -c 3 192.168.50.20
```

## Internet

```bash
ping -c 3 1.1.1.1
```

---

# Resultado esperado

A rede interna deve estar:

```text
192.168.50.0/24
```

com:

```text
srv-redes2 → 192.168.50.10/24
cli-redes2 → 192.168.50.20/24
```

A rota padrão deve continuar pela interface NAT.

---

# O que você deve ter aprendido

Ao final desta aula, você deve conseguir responder:

> Como o Linux decide por qual interface enviar um pacote?

Uma parte importante da resposta está em:

```bash
ip route
```

e:

```bash
ip route get <DESTINO>
```

---

# Próxima aula

Agora temos dois sistemas que conseguem se alcançar por IP.

Na próxima aula vamos colocar um serviço real no servidor, observar:

```text
processo
serviço
socket
porta
```

e realizar o primeiro acesso remoto com SSH.
