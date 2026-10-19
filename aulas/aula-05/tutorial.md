# Aula 05 — Meu Servidor de Redes II: ambiente persistente e consolidação do SSH

**Data:** 15/10/2026  
**Duração prevista:** 150 minutos

---

## Situação-problema

Até agora trabalhamos em máquinas virtuais preparadas no laboratório.

A partir de hoje, cada estudante passa a possuir um **servidor Linux individual e persistente** para Redes de Computadores II.

Isso muda a forma de trabalhar:

```text
antes
VM do laboratório
→ podia ser restaurada
→ reconstrução frequente

agora
srv-r2-sNN
→ individual
→ persistente
→ acessado por SSH
→ configurações permanecem entre as aulas
```

O objetivo desta aula é conhecer esse novo ambiente, estabelecer regras de operação e consolidar o conteúdo de SSH trabalhado no encontro anterior.

> **O servidor é persistente. Não trate uma alteração de configuração como descartável.**

---

# Objetivos

Ao final da aula, você deverá conseguir:

- acessar seu servidor individual pelo Windows;
- trocar a senha inicial;
- confirmar usuário e hostname;
- identificar `host0` e `lab0`;
- interpretar a rota padrão;
- testar Internet e resolução de nomes;
- explicar a função de cada interface;
- consultar o serviço SSH e sua porta;
- realizar uma alteração segura na configuração complementar do SSH;
- validar a configuração antes de reiniciar o serviço;
- confirmar o acesso em uma segunda sessão SSH;
- configurar Git/GitHub no servidor persistente;
- registrar no portfólio a configuração SSH;
- documentar seu novo ambiente de Redes II.

---

# Topologia a partir de hoje

```text
Computador Windows
        │
        │ SSH
        │ 172.16.2.34:PORTA_INDIVIDUAL
        ▼
┌─────────────────────────────┐
│ srv-r2-sNN                  │
│ seu servidor persistente    │
│                             │
│ host0 → gerenciamento       │
│ lab0  → laboratório         │
└──────────────┬──────────────┘
               │
               │ rede individual
               │
┌──────────────┴──────────────┐
│ cli-r2-sNN                  │
│ cliente individual          │
└─────────────────────────────┘
```

> **Hoje trabalharemos principalmente no servidor. O cliente será utilizado progressivamente nas próximas aulas.**

---

# Parte 1 — Receba suas credenciais

O professor fornecerá individualmente:

```text
Servidor: 172.16.2.34
Porta SSH: __________
Usuário: __________
Senha inicial: __________
```

Não compartilhe sua senha.

Cada aluno possui seu próprio usuário e sua própria porta de acesso.

---

# Parte 2 — Primeiro acesso pelo Windows

Abra o PowerShell, Prompt de Comando ou Windows Terminal.

Utilize:

```powershell
ssh -p SUA_PORTA SEU_USUARIO@172.16.2.34
```

Exemplo apenas de formato:

```powershell
ssh -p 2201 ana@172.16.2.34
```

No primeiro acesso pode aparecer uma confirmação de chave do host.

Leia a mensagem e, quando for o servidor informado pelo professor, confirme:

```text
yes
```

Digite a senha inicial.

> Ao digitar a senha no terminal, os caracteres não aparecem na tela.

---

# Parte 3 — Troque a senha inicial

Após entrar, altere sua senha com:

```bash
sudo passwd "$(whoami)"
```

Quando o `sudo` solicitar a senha, informe a senha temporária utilizada no login.

Depois escolha sua nova senha e confirme-a.

> A nova senha é pessoal. Não a registre no GitHub e não a compartilhe.

---

# Parte 4 — Confirme onde você está

Execute:

```bash
whoami
hostname
pwd
```

Registre:

```text
Meu usuário: __________________________________

Meu hostname: _________________________________
```

O hostname deverá seguir o padrão:

```text
srv-r2-sNN
```

---

# Parte 5 — Conheça suas interfaces

Execute:

```bash
ip -br addr
```

Procure:

```text
lo
host0
lab0
```

## `host0`

É a interface de gerenciamento.

Ela fornece:

- acesso SSH;
- Internet;
- acesso ao GitHub;
- instalação de pacotes.

### Regra

> **Não altere `host0` sem orientação do professor.**

## `lab0`

É a interface reservada aos experimentos da disciplina.

Ela será utilizada para comunicação com seu cliente individual e para os serviços que estudaremos.

Hoje ela pode aparecer **sem endereço IPv4**.

Isso é esperado.

### Regra

> **Não crie gateway padrão pela `lab0` sem orientação.**

---

# Parte 6 — Observe as rotas

Execute:

```bash
ip route
```

Localize a rota:

```text
default via ...
```

Observe por qual interface ela utiliza.

Responda:

```text
A rota padrão utiliza: _______________________
```

Ela deve estar relacionada à interface de gerenciamento, e não à `lab0`.

---

# Parte 7 — Teste acesso externo

Teste conectividade IP:

```bash
ping -c 3 1.1.1.1
```

Teste resolução de nomes:

```bash
getent hosts github.com
```

Se ambos funcionarem, temos evidências diferentes:

```text
ping para 1.1.1.1
→ conectividade IP

getent hosts github.com
→ resolução de nomes
```

---

# Parte 8 — Revise o SSH no novo servidor

Consulte:

```bash
systemctl status ssh
```

Depois:

```bash
sudo ss -lntp | grep ':22'
```

Observe:

- serviço ativo;
- processo;
- porta em `LISTEN`.

Consulte também:

```bash
sudo sshd -T | head
```

O comando `sshd -T` mostra a configuração efetiva interpretada pelo servidor SSH.

---

# Parte 9 — Regra especial do novo ambiente

O acesso externo ao seu servidor depende da porta individual fornecida pelo professor e do encaminhamento até a **porta 22 do container**.

Portanto:

> **NÃO altere a diretiva `Port 22` do SSH no servidor persistente.**

Uma alteração da porta interna poderia impedir seu acesso normal ao ambiente.

Nesta disciplina, quando quisermos estudar outra porta, faremos isso de forma controlada.

---

# Parte 10 — Faça backup da configuração

Antes de alterar:

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak-aula05
```

Confira:

```bash
sudo ls -l /etc/ssh/sshd_config*
```

---

# Parte 11 — Use um arquivo complementar

Em vez de alterar muitas linhas do arquivo principal, utilizaremos um arquivo complementar.

Verifique primeiro:

```bash
ls -l /etc/ssh/sshd_config.d/
```

Crie:

```bash
sudo nano /etc/ssh/sshd_config.d/90-redes2.conf
```

Conteúdo da aula:

```text
# Redes de Computadores II
PermitRootLogin no
MaxAuthTries 3
LoginGraceTime 60
```

Essas opções:

```text
PermitRootLogin no
→ impede login SSH direto como root

MaxAuthTries 3
→ limita tentativas de autenticação por conexão

LoginGraceTime 60
→ limita o tempo disponível para autenticação
```

> Não adicione uma diretiva `Port` neste arquivo.

---

# Parte 12 — Valide ANTES de reiniciar

Execute:

```bash
sudo sshd -t
```

Se houver erro:

```text
NÃO reinicie o serviço.
```

Leia a mensagem, corrija o arquivo e execute novamente:

```bash
sudo sshd -t
```

Se não houver saída, prossiga.

---

# Parte 13 — Mantenha sua sessão atual aberta

Não feche o terminal SSH em que você está trabalhando.

Reinicie o serviço:

```bash
sudo systemctl restart ssh
```

Confira:

```bash
systemctl is-active ssh
```

Resultado esperado:

```text
active
```

---

# Parte 14 — Valide em uma SEGUNDA janela

Abra outra janela do PowerShell/Prompt no Windows.

Conecte novamente:

```powershell
ssh -p SUA_PORTA SEU_USUARIO@172.16.2.34
```

Somente depois que a segunda conexão funcionar, considere a alteração validada.

Essa técnica reduz o risco de perder o acesso remoto durante uma alteração de SSH.

---

# Parte 15 — Consulte evidências

No servidor:

```bash
sudo ss -lntp | grep ':22'
```

Depois:

```bash
sudo journalctl -u ssh -n 20 --no-pager
```

Temos agora evidências de:

```text
configuração válida
        +
serviço ativo
        +
porta em LISTEN
        +
novo acesso remoto funcionando
```

---

# Parte 16 — Prepare Git/GitHub no servidor persistente

Verifique:

```bash
git --version
gh --version
```

Configure sua autoria, se necessário:

```bash
git config --global user.name "Seu Nome"
git config --global user.email "SEU_EMAIL"
```

Autentique:

```bash
gh auth login --web --git-protocol https
gh auth status
gh auth setup-git
```

Abra o navegador apenas para concluir a autorização solicitada.

Em computadores compartilhados, encerre depois as sessões abertas no navegador.

---

# Parte 17 — Clone o portfólio no servidor

Vá para seu diretório pessoal:

```bash
cd ~
```

Clone seu repositório individual:

```bash
git clone <URL-DO-SEU-REPOSITORIO>
```

Entre:

```bash
cd <NOME-DO-REPOSITORIO>
```

Confira o histórico:

```bash
git log --oneline
```

Você deverá reconhecer os commits já realizados.

> Como o servidor é persistente, nas próximas aulas normalmente você apenas entrará nessa pasta. Não será necessário clonar novamente.

---

# Parte 18 — Encerre a pendência da Aula 04

Crie:

```bash
mkdir -p aula-04/ssh
```

Salve uma cópia do arquivo principal:

```bash
sudo cat /etc/ssh/sshd_config > aula-04/ssh/sshd_config
```

Salve também a configuração complementar criada hoje:

```bash
sudo cat /etc/ssh/sshd_config.d/90-redes2.conf > aula-04/ssh/90-redes2.conf
```

Confira:

```bash
ls -l aula-04/ssh
```

E:

```bash
cat aula-04/ssh/90-redes2.conf
```

---

# Parte 19 — Terceiro commit: SSH

Confira antes:

```bash
git status
```

Adicione somente os arquivos da atividade:

```bash
git add aula-04/ssh/
```

Veja novamente:

```bash
git status
```

Commit:

```bash
git commit -m "Aula 04 - registra configuracao do SSH"
```

Envie:

```bash
git push
```

Confira:

```bash
git log --oneline
```

Agora a atividade de SSH está registrada no histórico.

---

# Parte 20 — Documente seu novo servidor

Crie:

```bash
mkdir -p aula-05
nano aula-05/ambiente.md
```

Utilize como estrutura:

```markdown
# Meu Servidor de Redes II

## Identificação

Usuário:
Hostname:
Porta SSH externa:

## Interfaces

Interface de gerenciamento: host0
Endereço observado em host0:

Interface de laboratório: lab0
Endereço observado em lab0:

## Rota padrão

Interface utilizada:

## Testes

Ping para 1.1.1.1:
Resolução de github.com:

## SSH

Status do serviço:
Porta interna:
Arquivo complementar utilizado:

## Regras importantes

- não alterar host0;
- não criar gateway padrão por lab0;
- não alterar a porta interna 22 do SSH sem orientação.
```

Preencha com os dados do seu ambiente.

> **Não coloque sua senha no arquivo.**

---

# Parte 21 — Quarto commit: ambiente persistente

Confira:

```bash
git status
```

Depois:

```bash
git add aula-05/ambiente.md
git commit -m "Aula 05 - documenta servidor persistente"
git push
```

Confira no histórico:

```bash
git log --oneline
```

---

# Resultado esperado no portfólio

O histórico deve possuir, no mínimo, a sequência de trabalhos realizados:

```text
1º commit
→ identificação/README

2º commit
→ script e/ou saída de diagnóstico de rede

3º commit
→ configuração SSH

4º commit
→ documentação do servidor persistente
```

Os nomes exatos dos commits podem variar.

---

# Checklist da aula

```text
[ ] Acessei meu servidor pela porta individual.
[ ] Troquei minha senha inicial.
[ ] Confirmei usuário e hostname.
[ ] Identifiquei host0.
[ ] Identifiquei lab0.
[ ] Localizei a rota padrão.
[ ] Testei Internet.
[ ] Testei resolução de nomes.
[ ] Verifiquei o serviço SSH.
[ ] Verifiquei a porta 22.
[ ] Criei 90-redes2.conf.
[ ] Validei com sshd -t.
[ ] Reiniciei o SSH.
[ ] Testei uma segunda conexão pelo Windows.
[ ] Clonei/abri meu portfólio no servidor.
[ ] Fiz o commit da configuração SSH.
[ ] Documentei meu ambiente persistente.
[ ] Fiz push dos novos commits.
```

---

# O que você deve ter aprendido

Ao final desta aula, você deve conseguir explicar:

1. por que seu servidor agora é persistente;
2. qual é a diferença entre `host0` e `lab0`;
3. por que não devemos alterar `host0`;
4. por que não devemos mudar a porta interna 22;
5. por que `systemctl status ssh` e `ss -lntp` fornecem evidências diferentes;
6. por que uma configuração deve ser validada antes do restart;
7. por que mantemos a sessão SSH atual aberta enquanto testamos uma nova;
8. por que configuração e documentação devem ser versionadas.

---

# Próxima aula

Na próxima etapa, utilizaremos o ambiente persistente para aprofundar o **troubleshooting estruturado** e a observação do tráfego da rede.

A partir daqui, o servidor passa a ser o ambiente principal de trabalho da disciplina.
