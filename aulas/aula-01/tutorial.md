# Aula 01 — Primeiros passos em Redes II e seu portfólio no GitHub

## Situação-problema

Os computadores do laboratório são restaurados. Por isso, arquivos e configurações mantidos apenas na VM podem desaparecer.

Durante Redes de Computadores II, você terá um **repositório individual de portfólio** no GitHub. Ele armazenará configurações, documentação, scripts e evidências produzidos durante o semestre.

Existem dois repositórios que você precisa distinguir:

### Material da disciplina

```text
https://github.com/DiegoCanizio/redes-ii
```

Você consulta esse repositório para obter:

- tutoriais;
- materiais;
- arquivos publicados pelo professor.

> **Você não fará `push` nesse repositório.**

### Seu portfólio
Acesse pelo link: https://classroom50.org/diego-canizio-edu/redes-ii-2026-2/assignments/portfolio-redes-ii-template/accept
Será criado individualmente para você por meio do Classroom 50.

É nele que você fará:

```text
clone
add
commit
push
```

durante o semestre.

---

## Objetivos

Ao final desta aula você deverá conseguir:

- distinguir Git de GitHub;
- distinguir o repositório da disciplina do seu repositório individual;
- aceitar a atividade `Portfólio Redes II`;
- instalar Git e GitHub CLI;
- autenticar sua VM no GitHub;
- clonar seu repositório individual;
- criar commits;
- enviá-los ao GitHub;
- encerrar sua autenticação.

---

# Parte 1 — Aceite seu portfólio

O professor fornecerá um link do Classroom 50:

```text
[LINK_CLASSROOM50_PORTFOLIO]
```

No navegador do Windows:

1. abra o link;
2. entre na sua conta GitHub (Se não tiver, eis uma boa hora para criar);
3. autorize o Classroom 50 se for solicitado;
4. aceite a atividade;
5. aguarde a criação/configuração do seu repositório;
6. abra o repositório criado para você.

> Esse repositório será reutilizado durante todo o semestre.

---

# Parte 2 — Identifique o repositório correto

No GitHub, abra seu repositório individual e copie sua URL HTTPS.

Ela será semelhante a:

```text
https://github.com/<ORGANIZACAO>/<SEU-REPOSITORIO>.git
```

Registre:

```text
Meu repositório individual:

____________________________________________________________
```

## Atenção

Não use como repositório de trabalho:

```text
https://github.com/DiegoCanizio/redes-ii.git
```

Esse é o repositório oficial da disciplina.

---

# Parte 3 — Prepare a VM

## 1. Interfaces

```bash
ip -br addr
```

## 2. Rotas

```bash
ip route
```

## 3. Internet

```bash
ping -c 3 1.1.1.1
```

## 4. Resolução de nomes

```bash
ping -c 3 github.com
```

---

# Parte 4 — Instale as ferramentas

```bash
sudo apt update
sudo apt install -y git gh
```

Verifique:

```bash
git --version
gh --version
```

---

# Parte 5 — Autentique esta VM

Execute:

```bash
gh auth login --web --git-protocol https
```

Siga as instruções exibidas no terminal e conclua a autorização no navegador do Windows.

Depois:

```bash
gh auth status
```

e:

```bash
gh auth setup-git
```

---

# Parte 6 — Configure a autoria

Consulte:

```bash
git config --global user.name
git config --global user.email
```

Se necessário:

```bash
git config --global user.name "Nome Sobrenome"
git config --global user.email "SEU_EMAIL"
```

Autenticação e autoria são coisas diferentes:

```text
gh auth → acesso à conta/repositório
git config user.* → identificação registrada no commit
```

---

# Parte 7 — Clone SEU repositório

Vá para seu diretório pessoal:

```bash
cd ~
```

Agora utilize a URL que você registrou:

```bash
git clone <URL-DO-SEU-REPOSITORIO>
```

Entre no diretório criado:

```bash
cd <NOME-DA-PASTA>
```

Veja os arquivos:

```bash
ls
```

---

# Parte 8 — Faça o primeiro commit

Verifique:

```bash
git status
```

Abra:

```bash
nano README.md
```

Acrescente:

```text
Portfólio iniciado na Aula 01 de Redes de Computadores II.
```

Salve e saia.

Confira:

```bash
git status
```

Prepare:

```bash
git add README.md
```

Confira novamente:

```bash
git status
```

Crie o commit:

```bash
git commit -m "Aula 01 - inicia portfólio"
```

Veja o histórico:

```bash
git log --oneline
```

Envie:

```bash
git push
```

---

# Parte 9 — Confirme no GitHub

Abra **seu repositório individual** no navegador.

Confirme:

- alteração do README;
- novo commit;
- autoria.

O repositório:

```text
DiegoCanizio/redes-ii
```

deve continuar sem alterações suas.

---

# Parte 10 — Miniatividade

Crie:

```bash
nano aula-01.txt
```

Conteúdo:

```text
Redes de Computadores II
Git registra versões.
GitHub hospeda o repositório remoto.
Este repositório é meu portfólio da disciplina.
```

Agora complete sozinho:

```text
git status
git add
git commit
git push
```

Mensagem sugerida:

```text
Aula 01 - adiciona atividade inicial
```

Confirme:

```bash
git log --oneline
```

---

# Parte 11 — Diagnóstico de Redes I

Responda sem pesquisar.

1. O que representa `/24` em `192.168.10.20/24`?

____________________________________________________________________

2. Qual é a função de um gateway padrão?

____________________________________________________________________

3. Para que serve DNS?

____________________________________________________________________

4. Cite uma diferença entre TCP e UDP.

____________________________________________________________________

5. Para que serve um endereço MAC em uma LAN?

____________________________________________________________________

6. O que é uma rota?

____________________________________________________________________

7. O que significa dizer que um serviço está escutando em uma porta?

____________________________________________________________________

8. Uma máquina responde ao `ping`, mas SSH não funciona. Isso é contraditório?

____________________________________________________________________

9. Que comando/ferramenta você utilizaria para descobrir o IP de uma máquina Linux?

____________________________________________________________________

10. Diante da frase “a rede não funciona”, qual seria uma das primeiras verificações?

____________________________________________________________________

---

# Parte 12 — Encerre sua autenticação

```bash
gh auth logout
```

Verifique:

```bash
gh auth status
```

---

# O que deve estar salvo

No **seu repositório individual**:

```text
README.md
aula-01.txt
```

---

# Evidência mínima

Você deve conseguir mostrar:

```bash
git log --oneline
```

e os mesmos commits no GitHub.

---

# Regra que vale para o semestre

Em cada nova aula, a VM poderá estar limpa.

Você irá:

```text
autenticar
   ↓
clonar o MESMO repositório individual
   ↓
continuar o trabalho
   ↓
commit
   ↓
push
   ↓
logout
```

Seu histórico permanecerá no GitHub.
