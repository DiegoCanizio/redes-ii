# Aula 01 — Git, GitHub e início do portfólio

**Data:** 01/10/2026  
**Duração realizada:** 150 minutos  
**Situação:** aula realizada — roteiro consolidado posteriormente.

> Este material registra o que foi desenvolvido no encontro. Não cria uma nova atividade retroativa.

---

## Objetivos trabalhados

Ao longo da aula foram apresentados:

- organização da disciplina;
- repositório oficial de materiais;
- portfólio individual no Classroom 50;
- diferença entre Git e GitHub;
- GitHub CLI (`gh`);
- autenticação de uma máquina no GitHub;
- clonagem do repositório individual;
- fluxo `status → add → commit → push`.

---

# 1. Dois repositórios diferentes

## Material da disciplina

```text
https://github.com/DiegoCanizio/redes-ii
```

É utilizado para consultar:

- tutoriais;
- materiais;
- arquivos de apoio.

Não é o destino dos commits do estudante.

## Portfólio individual

Cada estudante recebeu um repositório individual por meio do Classroom 50.

É nele que serão armazenados os trabalhos produzidos ao longo do semestre.

---

# 2. Git e GitHub

De forma simplificada:

```text
Git
→ controla versões dos arquivos

GitHub
→ hospeda e compartilha repositórios Git
```

O histórico do Git é formado por commits.

---

# 3. GitHub CLI

A autenticação utilizada em aula foi realizada com `gh`.

Comandos trabalhados:

```bash
gh auth login --web --git-protocol https
gh auth status
gh auth setup-git
```

Também verificamos:

```bash
git --version
gh --version
```

---

# 4. Clonagem do portfólio

A estrutura básica utilizada foi:

```bash
git clone <URL-DO-SEU-REPOSITORIO>
cd <NOME-DO-REPOSITORIO>
```

Para observar o repositório:

```bash
git status
git log --oneline
```

---

# 5. Primeiro trabalho versionado

O primeiro commit da disciplina consistiu na personalização do `README.md` do portfólio individual.

Foram registrados dados de identificação solicitados em sala.

Fluxo utilizado:

```bash
nano README.md
git status
git add README.md
git commit -m "Atualiza README do portfólio"
git push
```

---

# 6. O que ficou registrado

Ao final do encontro, o estudante deveria possuir pelo menos:

```text
Portfólio individual criado
        +
README.md personalizado
        +
primeiro commit enviado ao GitHub
```

---

## Para consulta

Comandos essenciais:

```bash
git status
git add ARQUIVO
git commit -m "mensagem"
git push
git log --oneline
```

A documentação de Git/GitHub será retomada sempre que necessário nas próximas práticas.
