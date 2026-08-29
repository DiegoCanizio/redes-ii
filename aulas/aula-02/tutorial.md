# Aula 02 — Recuperando seu portfólio e montando o laboratório virtual

## Situação-problema

A VM utilizada na Aula 1 foi restaurada.

Se nosso modelo estiver correto, isso não deve apagar seu trabalho.

Nesta aula você vai:

1. autenticar uma VM limpa;
2. clonar **o mesmo repositório individual** da Aula 1;
3. confirmar que seus arquivos e commits continuam disponíveis;
4. montar a topologia cliente/servidor;
5. adicionar a documentação da Aula 2 ao mesmo portfólio.

---

# Parte 1 — O repositório que você usará

## Material oficial

```text
https://github.com/DiegoCanizio/redes-ii
```

Serve para consultar os materiais da disciplina.

Não é o destino dos seus commits.

## Seu portfólio

É o repositório individual criado para você pelo Classroom 50 na Aula 1.

Use novamente a mesma URL:

```text
____________________________________________________________
```

Se você não a tiver registrado, abra o GitHub no navegador e localize seu repositório da atividade `Portfólio Redes II`.

---

# Parte 2 — Prepare a VM limpa

```bash
sudo apt update
sudo apt install -y git gh
```

Autentique:

```bash
gh auth login --web --git-protocol https
gh auth setup-git
```

Verifique:

```bash
gh auth status
```

---

# Parte 3 — Clone novamente seu portfólio

```bash
cd ~
git clone <URL-DO-SEU-REPOSITORIO>
```

Entre na pasta criada:

```bash
cd <NOME-DA-PASTA>
```

Liste:

```bash
ls
```

Veja o histórico:

```bash
git log --oneline
```

## O que você deve encontrar?

Os arquivos e commits da Aula 1.

Responda:

### A VM preservou esses arquivos entre as aulas?

```text
☐ Sim
☐ Não
```

### Então de onde eles vieram?

____________________________________________________________________

---

# Parte 4 — Arquitetura do laboratório

Teremos:

```text
                         INTERNET
                            │
                           NAT
                    ┌───────┴───────┐
                    │               │
             ┌──────┴──────┐ ┌──────┴──────┐
             │ cli-redes2  │ │ srv-redes2  │
             └──────┬──────┘ └──────┬──────┘
                    │               │
                    └──── REDES2 ───┘
                       rede interna
```

Cada VM terá:

```text
NIC 1 → NAT
NIC 2 → Rede interna REDES2
```

> Não utilize bridge/ponte para a rede experimental sem orientação do professor.

---

# Parte 5 — Configure as interfaces no hipervisor

Se utilizar VirtualBox, com cada VM desligada:

1. Configurações;
2. Rede;
3. Adaptador 1 → NAT;
4. Adaptador 2 → Rede Interna;
5. nome da rede interna → `REDES2`.

Repita nas duas VMs.

---

# Parte 6 — Configure os hostnames

Na VM cliente:

```bash
sudo hostnamectl set-hostname cli-redes2
```

Na VM servidor:

```bash
sudo hostnamectl set-hostname srv-redes2
```

Verifique:

```bash
hostnamectl
```

---

# Parte 7 — Identifique as interfaces

Nas duas VMs:

```bash
ip -br addr
```

Registre:

| Máquina | Interface NAT | IP NAT | Interface interna |
|---|---|---|---|
| `cli-redes2` | | | |
| `srv-redes2` | | | |

---

# Parte 8 — Verifique as rotas

```bash
ip route
```

Identifique em cada VM a interface utilizada pela rota padrão.

---

# Parte 9 — Teste acesso externo

```bash
ping -c 3 1.1.1.1
ping -c 3 github.com
```

---

# Parte 10 — Não configure IP interno ainda

Não configure ainda:

```text
192.168.50.10
192.168.50.20
```

Isso será feito na próxima aula.

---

# Parte 11 — Documente no MESMO repositório

Retorne à pasta clonada do seu portfólio.

Crie:

```bash
mkdir -p ambiente
nano ambiente/README.md
```

Use:

```markdown
# Ambiente de laboratório

## Cliente

Hostname: cli-redes2
Interface NAT:
Endereço NAT:
Interface interna:

## Servidor

Hostname: srv-redes2
Interface NAT:
Endereço NAT:
Interface interna:

## Rede interna

Nome: REDES2
```

Preencha os campos.

---

# Parte 12 — Commit da Aula 2

```bash
git status
git add ambiente/README.md
git commit -m "Aula 02 - documenta ambiente virtual"
git push
```

Depois:

```bash
git log --oneline
```

Você deverá enxergar commits da Aula 1 **e** da Aula 2.

---

# Parte 13 — Confira no GitHub

Abra seu repositório individual.

A estrutura mínima deverá ser semelhante a:

```text
README.md
aula-01.txt
ambiente/
└── README.md
```

Isso comprova que o portfólio está crescendo mesmo que as VMs sejam restauradas.

---

# Parte 14 — Logout

```bash
gh auth logout
```

Verifique:

```bash
gh auth status
```

---

# Regra para as próximas aulas

Em uma VM restaurada:

```text
instalar git/gh
   ↓
autenticar
   ↓
clonar seu repositório individual
   ↓
recuperar o histórico
   ↓
trabalhar
   ↓
commit + push
   ↓
logout
```

O repositório individual é sempre o mesmo.

---

# Próxima aula

Na Aula 3 configuraremos a rede interna:

```text
Servidor → 192.168.50.10/24
Cliente  → 192.168.50.20/24
```

e começaremos a armazenar também arquivos de configuração de rede no portfólio.
