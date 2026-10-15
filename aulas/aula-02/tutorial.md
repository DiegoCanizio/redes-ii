# Aula 02 — Linux básico, comandos de rede e primeiro script Bash

**Data:** 06/10/2026  
**Duração realizada:** 100 minutos  
**Situação:** aula realizada — roteiro consolidado posteriormente.

> Este roteiro registra o conteúdo efetivamente trabalhado. O material complementar de Linux está disponível na pasta `materiais/`.

---

## Objetivos trabalhados

Neste encontro foram exercitados:

- navegação básica no terminal Linux;
- execução de comandos;
- comandos básicos de diagnóstico de rede;
- uso de `echo`;
- criação de um script Bash simples;
- execução e captura da saída;
- versionamento do resultado no portfólio.

---

# 1. Linha de comando Linux

Foram utilizados comandos básicos para navegação e observação do sistema.

Exemplos:

```bash
pwd
ls
cd
cat
nano
```

O objetivo não foi esgotar a administração Linux, mas adquirir autonomia mínima para as práticas de Redes II.

Para aprofundamento, consulte o material de apoio de linha de comando disponível neste repositório.

---

# 2. Comandos de rede utilizados

Durante a prática foram utilizados comandos como:

```bash
ifconfig
ping
route
```

Esses comandos permitiram observar:

- interfaces;
- endereços;
- conectividade;
- tabela de rotas.

Ao longo da disciplina também utilizaremos progressivamente os comandos modernos do `iproute2`:

```bash
ip addr
ip route
ip link
```

Exemplos de equivalência:

```text
ifconfig  → ip addr
route     → ip route
```

---

# 3. Bash e `echo`

Foi elaborado um script simples reunindo comandos de diagnóstico.

O `echo` foi utilizado tanto para inserir linhas em branco quanto para identificar as partes da saída.

Exemplo conceitual:

```bash
#!/bin/bash

echo "=== Interfaces ==="
ifconfig

echo
echo "=== Rotas ==="
route

echo
echo "=== Teste de conectividade ==="
ping -c 3 1.1.1.1
```

O importante nesta etapa foi perceber que um conjunto repetitivo de comandos pode ser registrado em um script.

---

# 4. Permissão e execução

Um script pode ser executado, por exemplo, com:

```bash
bash diagnostico.sh
```

ou, quando possui permissão de execução:

```bash
chmod +x diagnostico.sh
./diagnostico.sh
```

---

# 5. Registro da saída

A saída do script foi utilizada como evidência da atividade.

Uma forma de registrar a execução é:

```bash
./diagnostico.sh > saida.txt
```

Quando queremos visualizar e salvar ao mesmo tempo:

```bash
./diagnostico.sh | tee saida.txt
```

---

# 6. Segundo commit da disciplina

O segundo commit registrado pela turma correspondeu à atividade com o script Bash e sua saída.

O fluxo utilizado continuou sendo:

```bash
git status
git add <ARQUIVOS-DA-ATIVIDADE>
git commit -m "Registra diagnostico de rede em Bash"
git push
```

---

# Síntese

Até este ponto, o portfólio passou a registrar:

```text
Commit 1
→ identificação no README

Commit 2
→ script/saída de comandos básicos de rede
```

Esses dois commits formam o ponto de partida para as próximas práticas.
