# Guia rápido de Linux e Shell para Redes de Computadores II

> Material de apoio e consulta rápida para a disciplina **Redes de Computadores II**.  
> Este guia não pretende substituir um curso completo de Linux nem a documentação oficial. O objetivo é oferecer os conhecimentos de terminal e shell necessários para acompanhar as práticas da disciplina com autonomia.

---

## 1. Como usar este guia

Durante Redes de Computadores II, boa parte das atividades será realizada em servidores Linux por meio da linha de comando.

Você não precisa decorar todos os comandos apresentados aqui.

O mais importante é aprender a:

- entender a estrutura de um comando;
- navegar pelo sistema de arquivos;
- criar, copiar, mover, editar e remover arquivos;
- executar operações administrativas quando necessário;
- consultar ajuda;
- trabalhar com a saída de comandos;
- pesquisar e contar informações em arquivos;
- combinar comandos usando `|`;
- utilizar redirecionamentos;
- criar pequenos scripts para automatizar tarefas.

Sempre que encontrar um comando novo, procure entender:

```text
O que ele recebe?
O que ele faz?
O que ele produz como saída?
Como posso verificar se funcionou?
```

Essa forma de pensar será reutilizada durante toda a disciplina.

---

# 2. Terminal, shell e prompt

O **terminal** é a interface pela qual você digita comandos.

O **shell** é o programa que interpreta esses comandos. Em sistemas Ubuntu, o shell utilizado normalmente nas atividades da disciplina será o **Bash**.

Um prompt pode aparecer assim:

```text
aluno@srv-redes2:~$
```

Ele contém informações úteis:

```text
aluno        → usuário atual
srv-redes2   → nome da máquina
~            → diretório atual
$            → usuário comum
```

Quando uma sessão está sendo executada diretamente como `root`, é comum encontrar:

```text
#
```

> Durante a disciplina, prefira trabalhar com um usuário comum e utilizar `sudo` apenas quando uma operação administrativa exigir privilégios.

---

## 3. Estrutura básica de um comando

Um comando geralmente possui:

```text
comando [opções] [argumentos]
```

Exemplo:

```bash
ls -l /etc
```

Nesse caso:

```text
ls      → comando
-l      → opção
/etc    → argumento
```

Outro exemplo:

```bash
ping -c 4 192.168.50.10
```

```text
ping             → comando
-c 4             → opção e valor
192.168.50.10    → destino
```

Algumas opções possuem formas curtas e longas.

Exemplo:

```bash
ls -a
```

ou:

```bash
ls --all
```

---

# 4. Recursos úteis do terminal

## 4.1 Autocompletar com `Tab`

Digite parte de um comando ou nome de arquivo e pressione:

```text
Tab
```

Exemplo:

```bash
cd /etc/net
```

Pressione `Tab` para tentar completar o caminho.

Isso reduz erros de digitação.

## 4.2 Histórico de comandos

Use as teclas:

```text
↑
↓
```

para navegar pelos comandos anteriores.

Também é possível listar o histórico:

```bash
history
```

Pesquisar no histórico:

```bash
history | grep ssh
```

## 4.3 Interromper um comando

Quando um programa estiver em execução e você quiser interrompê-lo:

```text
Ctrl+C
```

Exemplo:

```bash
ping 192.168.50.10
```

Sem uma quantidade definida, o `ping` continuará executando. Use `Ctrl+C` para interrompê-lo.

## 4.4 Limpar a tela

```bash
clear
```

Atalho frequente:

```text
Ctrl+L
```

---

# 5. Onde estou? Navegação pelo sistema de arquivos

## 5.1 Mostrar o diretório atual

```bash
pwd
```

Exemplo:

```text
/home/aluno
```

`pwd` significa **print working directory**.

## 5.2 Listar arquivos

```bash
ls
```

Listagem detalhada:

```bash
ls -l
```

Incluir arquivos ocultos:

```bash
ls -a
```

Combinar opções:

```bash
ls -la
```

Um nome iniciado por ponto é normalmente oculto:

```text
.git
.bashrc
.ssh
```

## 5.3 Mudar de diretório

```bash
cd /etc
```

Voltar ao diretório pessoal:

```bash
cd ~
```

ou simplesmente:

```bash
cd
```

Subir um nível:

```bash
cd ..
```

Voltar para o diretório anterior:

```bash
cd -
```

---

# 6. Caminhos absolutos e relativos

Um **caminho absoluto** começa a partir da raiz `/`.

Exemplo:

```text
/etc/ssh/sshd_config
```

Um **caminho relativo** parte do diretório em que você está.

Se você estiver em:

```text
/home/aluno
```

e existir:

```text
/home/aluno/redes2/aula01
```

pode acessar com:

```bash
cd redes2/aula01
```

Símbolos importantes:

```text
/     → raiz do sistema
~     → diretório pessoal do usuário
.     → diretório atual
..    → diretório pai
```

Exemplo:

```bash
cp arquivo.txt ../
```

Copia `arquivo.txt` para o diretório imediatamente acima.

---

# 7. Diretórios importantes do Linux

Você encontrará frequentemente:

```text
/home    → diretórios pessoais dos usuários
/etc     → arquivos de configuração do sistema e serviços
/var     → dados variáveis, logs, filas e outros arquivos de serviços
/tmp     → arquivos temporários
/usr     → programas, bibliotecas e dados instalados
/root    → diretório pessoal do usuário root
```

Durante Redes II, `/etc` aparecerá constantemente porque muitos serviços armazenam suas configurações nesse diretório.

Exemplos:

```text
/etc/ssh/
/etc/netplan/
/etc/bind/
/etc/nginx/
```

> Não altere arquivos de `/etc` aleatoriamente. Leia o tutorial da aula e faça backup quando solicitado.

---

# 8. Criando arquivos e diretórios

## 8.1 Criar diretório

```bash
mkdir redes2
```

Criar uma estrutura inteira:

```bash
mkdir -p redes2/aula01/evidencias
```

## 8.2 Criar arquivo vazio

```bash
touch notas.txt
```

O comando também atualiza o horário de modificação de um arquivo existente.

---

# 9. Copiar, mover e remover

## 9.1 Copiar arquivo

```bash
cp arquivo.txt copia.txt
```

Copiar para outro diretório:

```bash
cp arquivo.txt backup/
```

Copiar diretório recursivamente:

```bash
cp -r configuracoes backup/
```

## 9.2 Fazer backup antes de editar

Durante a disciplina será comum:

```bash
sudo cp /etc/exemplo/arquivo.conf /etc/exemplo/arquivo.conf.bak
```

A ideia é simples:

```text
backup
→ editar
→ validar
→ aplicar
→ testar
```

## 9.3 Mover ou renomear

Mover:

```bash
mv arquivo.txt documentos/
```

Renomear:

```bash
mv arquivo.txt arquivo-antigo.txt
```

## 9.4 Remover arquivo

```bash
rm arquivo.txt
```

Remover diretório e conteúdo:

```bash
rm -r diretorio/
```

### Atenção

`rm` normalmente não envia arquivos para uma lixeira.

Antes de comandos destrutivos, confirme onde você está:

```bash
pwd
```

e o que será afetado:

```bash
ls
```

Evite executar comandos que você não compreende.

---

# 10. Visualizando arquivos de texto

## 10.1 `cat`

Mostrar todo o conteúdo:

```bash
cat arquivo.txt
```

Bom para arquivos pequenos.

Também é possível numerar linhas:

```bash
cat -n arquivo.txt
```

## 10.2 `less`

Para arquivos maiores:

```bash
less arquivo.txt
```

Teclas úteis:

```text
↑ / ↓      navegar
Page Up    voltar
Page Down  avançar
/termo     pesquisar
n          próxima ocorrência
q          sair
```

## 10.3 `head`

Mostrar as primeiras linhas:

```bash
head arquivo.txt
```

Escolher quantidade:

```bash
head -n 5 arquivo.txt
```

## 10.4 `tail`

Mostrar as últimas linhas:

```bash
tail arquivo.txt
```

Escolher quantidade:

```bash
tail -n 20 arquivo.txt
```

Acompanhar um arquivo enquanto novas linhas são adicionadas:

```bash
tail -f arquivo.log
```

Interrompa com:

```text
Ctrl+C
```

Esse recurso será útil para acompanhar logs.

---

# 11. Editor de texto `nano`

`nano` é um editor de texto executado diretamente no terminal.

Durante Redes II ele será utilizado principalmente para criar e editar arquivos de configuração.

Abrir ou criar:

```bash
nano arquivo.txt
```

Editar um arquivo administrativo:

```bash
sudo nano /etc/exemplo/arquivo.conf
```

## 11.1 Entendendo a barra inferior

No rodapé do Nano aparecem atalhos parecidos com:

```text
^G Help    ^O Write Out    ^W Where Is    ^K Cut    ^U Paste    ^X Exit
```

No Nano:

```text
^ = Ctrl
```

Portanto:

```text
^O = Ctrl+O
^X = Ctrl+X
```

## 11.2 Atalhos essenciais

```text
Ctrl+O    salvar (Write Out)
Enter     confirmar o nome do arquivo
Ctrl+X    sair
Ctrl+W    pesquisar
Ctrl+K    recortar a linha atual
Ctrl+U    colar
Ctrl+\    pesquisar e substituir
```

Dependendo da versão do Nano, atalhos adicionais podem aparecer na tela. Use o rodapé como referência.

## 11.3 Fluxo mais comum

Abra:

```bash
sudo nano /etc/exemplo/arquivo.conf
```

Edite o texto.

Salve:

```text
Ctrl+O
```

Confirme:

```text
Enter
```

Saia:

```text
Ctrl+X
```

## 11.4 Quero sair sem salvar

Pressione:

```text
Ctrl+X
```

Se aparecer:

```text
Save modified buffer?
```

responda:

```text
N
```

para descartar.

## 11.5 Quero salvar e sair

```text
Ctrl+O
Enter
Ctrl+X
```

## 11.6 Pesquisar dentro do arquivo

```text
Ctrl+W
```

Digite o termo e pressione:

```text
Enter
```

## 11.7 Exercício rápido com Nano

Execute:

```bash
nano notas.txt
```

Faça:

1. escreva três linhas;
2. salve;
3. feche o editor;
4. reabra o arquivo;
5. pesquise uma palavra;
6. adicione uma quarta linha;
7. salve e saia.

Depois confira:

```bash
cat notas.txt
```

---

# 12. Usuários e privilégios

## 12.1 Usuário atual

```bash
whoami
```

## 12.2 Informações do usuário

```bash
id
```

Exemplo de informações exibidas:

```text
uid
gid
grupos
```

## 12.3 Diretório pessoal

```bash
echo "$HOME"
```

## 12.4 `sudo`

Algumas operações exigem privilégios administrativos.

Exemplo:

```bash
sudo apt update
```

Editar configuração:

```bash
sudo nano /etc/exemplo/arquivo.conf
```

O `sudo` não significa “modo mágico”.

Ele significa que aquele comando será executado com privilégios elevados, conforme as permissões configuradas no sistema.

> Use `sudo` somente quando necessário.

---

# 13. Permissões de arquivos: o mínimo necessário

Execute:

```bash
ls -l
```

Você poderá encontrar algo semelhante:

```text
-rw-r--r-- 1 aluno aluno 125 out 5 10:00 notas.txt
```

O primeiro bloco representa o tipo e as permissões.

```text
-rw-r--r--
```

Simplificando:

```text
-      → arquivo comum

rw-    → proprietário
r--    → grupo
r--    → outros
```

Letras:

```text
r → leitura
w → escrita
x → execução
```

## 13.1 Tornar um script executável

```bash
chmod +x verificar.sh
```

Depois:

```bash
./verificar.sh
```

Não é necessário decorar permissões numéricas neste momento.

---

# 14. Instalando programas com APT

Ubuntu utiliza o sistema APT para gerenciamento de pacotes.

Atualizar a lista de pacotes disponíveis:

```bash
sudo apt update
```

Instalar um pacote:

```bash
sudo apt install curl
```

Sem pedir confirmação:

```bash
sudo apt install -y curl
```

Instalar vários:

```bash
sudo apt install -y git curl nano
```

Remover:

```bash
sudo apt remove curl
```

Pesquisar:

```bash
apt search tcpdump
```

Mostrar informações:

```bash
apt show tcpdump
```

### Importante

```bash
sudo apt update
```

**não atualiza todos os programas instalados**.

Ele atualiza as informações sobre os pacotes disponíveis.

Na disciplina, não utilizaremos `apt upgrade` automaticamente em toda aula.

---

# 15. Entrada, saída e erros

Um programa normalmente trabalha com três fluxos:

```text
stdin   → entrada padrão
stdout  → saída padrão
stderr  → saída de erro
```

Em muitos casos:

```text
teclado → stdin
terminal ← stdout
terminal ← stderr
```

Exemplo:

```bash
ls
```

O resultado aparece na saída padrão.

Esse conceito explica por que conseguimos redirecionar ou combinar comandos.

---

# 16. Redirecionamento de saída

## 16.1 `>` — sobrescrever

```bash
echo "Servidor de Redes II" > arquivo.txt
```

Confira:

```bash
cat arquivo.txt
```

Se executar novamente:

```bash
echo "Nova linha" > arquivo.txt
```

o conteúdo anterior será substituído.

## 16.2 `>>` — acrescentar

```bash
echo "Primeira linha" > arquivo.txt
echo "Segunda linha" >> arquivo.txt
```

Confira:

```bash
cat arquivo.txt
```

## 16.3 Salvar saída de um comando

```bash
ip -br addr > interfaces.txt
```

Depois:

```bash
cat interfaces.txt
```

## 16.4 Saída de erro

O redirecionamento básico de erro utiliza:

```text
2>
```

Exemplo:

```bash
ls /diretorio-inexistente 2> erros.txt
```

Verifique:

```bash
cat erros.txt
```

Para reunir saída padrão e erro em um mesmo arquivo:

```bash
comando > resultado.txt 2>&1
```

Você não precisa decorar essa construção imediatamente, mas ela aparecerá em atividades de administração e scripts.

---

# 17. Pipe `|`: combinando comandos

O pipe é um dos recursos mais importantes do shell.

```text
|
```

Ele envia a **saída padrão do comando à esquerda** para a **entrada padrão do comando à direita**.

Exemplo:

```bash
cat nomes.txt | grep aluno
```

Fluxo:

```text
cat nomes.txt
      │
      ▼
   conteúdo
      │
      ▼
 grep aluno
      │
      ▼
linhas encontradas
```

É possível combinar mais comandos:

```bash
cat nomes.txt | grep aluno | wc -l
```

Agora:

```text
cat      → produz as linhas
grep     → seleciona as linhas
wc -l    → conta as linhas selecionadas
```

### Observação

Muitos comandos conseguem receber diretamente o nome de um arquivo.

Assim:

```bash
grep aluno nomes.txt
```

é mais simples que:

```bash
cat nomes.txt | grep aluno
```

Mesmo assim, entender o pipe é essencial porque ele permite construir cadeias de processamento entre programas diferentes.

---

# 18. Pesquisa com `grep`

`grep` procura padrões em textos.

Arquivo:

```text
servidor ativo
cliente ativo
servidor backup
cliente inativo
```

Pesquisar:

```bash
grep servidor arquivo.txt
```

Resultado:

```text
servidor ativo
servidor backup
```

## 18.1 Ignorar maiúsculas e minúsculas

```bash
grep -i servidor arquivo.txt
```

## 18.2 Mostrar número da linha

```bash
grep -n servidor arquivo.txt
```

## 18.3 Excluir linhas que combinam

```bash
grep -v servidor arquivo.txt
```

## 18.4 Pesquisar recursivamente

```bash
grep -R "192.168.50.10" configuracoes/
```

Útil para descobrir em quais arquivos uma informação aparece.

## 18.5 `grep` com pipes

```bash
ip -br addr | grep UP
```

Mais tarde na disciplina você encontrará construções como:

```bash
ss -lntp | grep ':22'
```

ou:

```bash
journalctl -u ssh | grep -i error
```

Você não precisa conhecer `ss` ou `journalctl` antes das aulas correspondentes. O importante neste guia é compreender o funcionamento do pipe e do `grep`.

---

# 19. Contagem com `wc`

`wc` pode contar linhas, palavras e bytes/caracteres.

Contar linhas:

```bash
wc -l arquivo.txt
```

Contar palavras:

```bash
wc -w arquivo.txt
```

Exemplo combinado:

```bash
grep -i erro arquivo.log | wc -l
```

Pergunta respondida:

```text
Quantas linhas contêm "erro"?
```

---

# 20. `sort` e `uniq`

Suponha:

```text
dns
http
dns
ssh
http
dns
```

Ordenar:

```bash
sort servicos.txt
```

Remover repetições consecutivas:

```bash
sort servicos.txt | uniq
```

Contar ocorrências:

```bash
sort servicos.txt | uniq -c
```

Resultado semelhante:

```text
      3 dns
      2 http
      1 ssh
```

Ordenar pela quantidade, numericamente:

```bash
sort servicos.txt | uniq -c | sort -n
```

---

# 21. `cut`: selecionando campos

Considere:

```text
ana:192.168.50.20
bruno:192.168.50.21
carla:192.168.50.22
```

Selecionar o primeiro campo usando `:` como separador:

```bash
cut -d ':' -f 1 clientes.txt
```

Resultado:

```text
ana
bruno
carla
```

Segundo campo:

```bash
cut -d ':' -f 2 clientes.txt
```

---

# 22. `tee`: mostrar e salvar

Normalmente:

```bash
comando > arquivo.txt
```

salva a saída, mas ela deixa de aparecer normalmente no terminal.

`tee` permite mostrar e salvar:

```bash
ip -br addr | tee interfaces.txt
```

Para acrescentar em vez de substituir:

```bash
ip route | tee -a diagnostico.txt
```

Esse recurso pode ser útil na criação de evidências de laboratório.

---

# 23. Curingas

O shell permite selecionar conjuntos de arquivos.

## `*`

Representa qualquer sequência de caracteres.

```bash
ls *.txt
```

Copiar todos os arquivos `.conf`:

```bash
cp *.conf backup/
```

## `?`

Representa um único caractere.

```bash
ls aula?.txt
```

Pode corresponder a:

```text
aula1.txt
aula2.txt
```

mas não:

```text
aula10.txt
```

---

# 24. Aspas e variáveis

Considere:

```bash
NOME="Redes II"
```

Mostrar:

```bash
echo "$NOME"
```

Resultado:

```text
Redes II
```

Aspas duplas permitem expansão de variáveis:

```bash
echo "$HOME"
```

Aspas simples preservam o texto literalmente:

```bash
echo '$HOME'
```

Resultado:

```text
$HOME
```

Como regra inicial, quando usar uma variável que pode conter espaços, prefira:

```bash
"$VARIAVEL"
```

---

# 25. Ajuda: `--help` e `man`

Você não precisa decorar todas as opções.

Tente:

```bash
ls --help
```

ou:

```bash
grep --help
```

Muitos programas possuem páginas de manual:

```bash
man ls
```

```bash
man grep
```

Dentro do `man`:

```text
/termo    pesquisar
n         próxima ocorrência
q         sair
```

Exemplo:

```bash
man grep
```

Pesquise:

```text
ignore-case
```

A documentação é parte da ferramenta de trabalho.

---

# 26. Alguns comandos básicos de rede

Nesta seção, o objetivo é apenas **consultar informações e testar conectividade**.

A configuração da rede será ensinada durante Redes II.

## 26.1 Interfaces e endereços

```bash
ip addr
```

Forma resumida:

```bash
ip -br addr
```

Exemplo:

```text
lo        UNKNOWN    127.0.0.1/8
enp0s3    UP         10.0.2.15/24
enp0s8    UP         192.168.50.10/24
```

## 26.2 Rotas

```bash
ip route
```

## 26.3 Testar conectividade

```bash
ping -c 4 192.168.50.10
```

`-c 4` limita a quatro tentativas.

## 26.4 Nome da máquina

```bash
hostname
```

## 26.5 Endereços associados ao host

```bash
hostname -I
```

Use esse resultado com cuidado: uma máquina pode possuir vários endereços e interfaces.

---

# 27. Comandos encadeados: começando a pensar como operador

O objetivo não é decorar cadeias prontas.

É aprender a responder perguntas.

## Pergunta 1

**Quantas linhas existem em um arquivo?**

```bash
wc -l arquivo.txt
```

## Pergunta 2

**Quantas linhas possuem a palavra `erro`?**

```bash
grep -i erro arquivo.txt | wc -l
```

## Pergunta 3

**Quais interfaces estão `UP`?**

```bash
ip -br addr | grep UP
```

## Pergunta 4

**Quais são as 10 últimas linhas que possuem `erro`?**

```bash
grep -i erro arquivo.log | tail -n 10
```

## Pergunta 5

**Quero visualizar e salvar uma evidência.**

```bash
ip route | tee rotas.txt
```

## Pergunta 6

**Quero contar valores repetidos.**

```bash
sort servicos.txt | uniq -c
```

A lógica é mais importante que o comando final:

```text
produzir dados
→ filtrar
→ transformar
→ resumir
→ registrar
```

---

# 28. Comandos em sequência

É possível executar comandos sequencialmente.

## `;`

Executa o próximo independentemente do resultado anterior:

```bash
pwd; ls
```

## `&&`

Executa o próximo apenas se o anterior terminar com sucesso:

```bash
mkdir teste && cd teste
```

Isso será útil em automações simples.

## `||`

Executa o próximo se o anterior falhar:

```bash
ping -c 1 192.168.50.10 || echo "Falha no teste"
```

Você verá esse conceito novamente ao estudar códigos de saída.

---

# 29. Introdução a scripts Bash

Um script é um arquivo contendo comandos que serão executados pelo shell.

Scripts permitem:

```text
repetir tarefas
padronizar procedimentos
diminuir erros
registrar uma sequência operacional
automatizar verificações
```

## 29.1 Primeiro script

Crie:

```bash
nano verificar.sh
```

Conteúdo:

```bash
#!/bin/bash

echo "=== Informações do sistema ==="

whoami
hostname
ip -br addr
ip route
```

Salve e saia.

Execute:

```bash
bash verificar.sh
```

## 29.2 O que é `#!/bin/bash`?

A primeira linha:

```bash
#!/bin/bash
```

é chamada de **shebang**.

Ela indica qual interpretador deve ser usado para executar o script quando ele for iniciado diretamente.

## 29.3 Tornar executável

```bash
chmod +x verificar.sh
```

Agora:

```bash
./verificar.sh
```

O `./` indica que o arquivo está no diretório atual.

---

# 30. Variáveis em scripts

```bash
#!/bin/bash

SERVIDOR="192.168.50.10"

echo "Servidor: $SERVIDOR"
ping -c 2 "$SERVIDOR"
```

Evite espaços ao redor do `=`:

Correto:

```bash
SERVIDOR="192.168.50.10"
```

Incorreto:

```bash
SERVIDOR = "192.168.50.10"
```

---

# 31. Argumentos de linha de comando

Crie:

```bash
nano testar-host.sh
```

Conteúdo:

```bash
#!/bin/bash

ALVO="$1"

echo "Testando $ALVO"
ping -c 2 "$ALVO"
```

Execute:

```bash
bash testar-host.sh 192.168.50.10
```

ou, depois de `chmod +x`:

```bash
./testar-host.sh 192.168.50.10
```

Variáveis especiais:

```text
$0    → nome do script
$1    → primeiro argumento
$2    → segundo argumento
$#    → quantidade de argumentos
```

---

# 32. Validando argumentos

Um script simples deve evitar continuar quando falta informação.

```bash
#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <endereco-ip>"
    exit 1
fi

ALVO="$1"

ping -c 2 "$ALVO"
```

Se executar sem argumento:

```bash
./testar-host.sh
```

o script informará como deve ser usado.

---

# 33. Código de saída

Programas retornam um código ao terminar.

Execute:

```bash
ping -c 1 127.0.0.1
```

Depois:

```bash
echo $?
```

Em geral:

```text
0       → sucesso
não 0   → erro ou outra condição
```

Teste um destino inválido e compare:

```bash
ping -c 1 192.0.2.123
echo $?
```

> O significado exato dos códigos pode variar conforme o programa. Consulte a documentação quando necessário.

---

# 34. Condicional `if`

Podemos usar o resultado de um comando para tomar uma decisão.

```bash
#!/bin/bash

ALVO="$1"

if ping -c 1 "$ALVO" > /dev/null; then
    echo "OK - host respondeu"
else
    echo "ERRO - host não respondeu"
fi
```

`/dev/null` é um destino especial utilizado para descartar uma saída que não precisamos exibir.

---

# 35. Script básico de diagnóstico

Crie:

```bash
nano diagnostico.sh
```

Conteúdo:

```bash
#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <endereco-ip>"
    exit 1
fi

ALVO="$1"

echo "================================"
echo " Diagnóstico básico de rede"
echo "================================"
echo

echo "[1] Usuário"
whoami

echo
echo "[2] Host"
hostname

echo
echo "[3] Interfaces"
ip -br addr

echo
echo "[4] Rotas"
ip route

echo
echo "[5] Teste de conectividade com $ALVO"

if ping -c 2 "$ALVO" > /dev/null; then
    echo "OK - host respondeu ao ping"
else
    echo "ERRO - host não respondeu ao ping"
fi
```

Torne executável:

```bash
chmod +x diagnostico.sh
```

Execute:

```bash
./diagnostico.sh 192.168.50.10
```

Esse script não substitui o diagnóstico de rede.

Ele apenas automatiza uma sequência inicial de coleta de informações.

Durante a disciplina você aprenderá que:

> **Sintoma não é causa.**

Uma boa investigação precisa de hipótese, teste e evidência.

---

# 36. Salvando a saída de um script

```bash
./diagnostico.sh 192.168.50.10 > diagnostico.txt
```

Mostrar e salvar:

```bash
./diagnostico.sh 192.168.50.10 | tee diagnostico.txt
```

Acrescentar uma nova execução:

```bash
./diagnostico.sh 192.168.50.10 | tee -a diagnostico.txt
```

---

# 37. Comentários em scripts

Linhas iniciadas por `#` são comentários, exceto a linha especial do shebang.

```bash
#!/bin/bash

# Endereço do servidor de laboratório
SERVIDOR="192.168.50.10"

# Teste de conectividade
ping -c 2 "$SERVIDOR"
```

Comentários devem explicar decisões importantes, não repetir literalmente cada comando.

---

# 38. Boas práticas para scripts iniciais

Para os scripts simples desta disciplina:

- use nomes de variáveis claros;
- coloque variáveis entre aspas quando apropriado;
- valide argumentos;
- mostre mensagens que indiquem o que está sendo testado;
- não esconda erros importantes;
- não coloque senhas ou tokens dentro do script;
- teste cada comando manualmente antes de automatizá-lo;
- mantenha o script simples e compreensível.

Nunca versione:

```text
senhas
tokens
PATs
chaves privadas
credenciais reais
```

---

# 39. Exercício de revisão: terminal e arquivos

Sem consultar a solução pronta, tente realizar:

1. vá para seu diretório pessoal;
2. crie `redes2/linux`;
3. entre no diretório;
4. crie `notas.txt`;
5. edite o arquivo com Nano;
6. escreva quatro linhas;
7. faça uma cópia chamada `notas.bak`;
8. liste os arquivos com detalhes;
9. mostre as duas primeiras linhas;
10. mostre as duas últimas linhas;
11. conte quantas linhas existem;
12. pesquise uma palavra;
13. salve o resultado da pesquisa em `resultado.txt`.

Ao final:

```bash
ls -l
```

---

# 40. Exercício de revisão: processamento de texto

Crie:

```bash
nano servicos.txt
```

Conteúdo:

```text
dns
http
ssh
dns
http
dns
smtp
ssh
dns
```

Descubra usando comandos:

### A. Quantas linhas existem?

### B. Quantas vezes aparece `dns`?

### C. Quais valores diferentes existem?

### D. Quantas vezes aparece cada serviço?

### E. Salve a contagem em:

```text
contagem.txt
```

Sugestão: você provavelmente precisará combinar:

```text
grep
wc
sort
uniq
>
|
```

---

# 41. Exercício de revisão: informações da máquina

Crie:

```text
evidencias.txt
```

contendo a saída de:

- usuário atual;
- nome da máquina;
- endereços das interfaces;
- tabela de rotas.

Tente resolver usando uma combinação de:

```bash
whoami
hostname
ip -br addr
ip route
tee -a
```

---

# 42. Desafio de script

Crie:

```text
resumo-sistema.sh
```

O script deverá:

1. mostrar o usuário;
2. mostrar o hostname;
3. mostrar as interfaces;
4. mostrar as rotas;
5. receber um IP como primeiro argumento;
6. verificar se o IP responde ao `ping`;
7. informar claramente `OK` ou `ERRO`.

Exemplo de uso:

```bash
./resumo-sistema.sh 192.168.50.10
```

Não é necessário criar algo mais complexo do que isso.

---

# 43. Você está pronto para Redes II?

Use como autoavaliação.

```text
[ ] Sei abrir e utilizar o terminal.
[ ] Sei usar pwd, cd e ls.
[ ] Entendo caminhos absolutos e relativos.
[ ] Sei criar diretórios e arquivos.
[ ] Sei copiar, mover, renomear e remover arquivos.
[ ] Sei visualizar arquivos com cat, less, head e tail.
[ ] Sei editar e salvar arquivos utilizando nano.
[ ] Sei identificar meu usuário.
[ ] Entendo quando sudo é necessário.
[ ] Sei instalar um pacote com apt.
[ ] Consigo consultar man e --help.
[ ] Entendo o que > e >> fazem.
[ ] Entendo o funcionamento do pipe |.
[ ] Consigo pesquisar informações com grep.
[ ] Consigo contar linhas com wc -l.
[ ] Consigo combinar grep, wc, sort e uniq em tarefas simples.
[ ] Sei consultar endereços com ip -br addr.
[ ] Sei consultar rotas com ip route.
[ ] Sei realizar um teste básico com ping.
[ ] Consigo criar e executar um script Bash simples.
[ ] Entendo variáveis, argumentos e códigos de saída em nível introdutório.
```

Se alguns itens ainda não estiverem claros, use este guia como consulta durante as primeiras aulas.

---

# 44. Referência rápida

| Tarefa | Comando |
|---|---|
| Diretório atual | `pwd` |
| Listar | `ls` |
| Listar detalhado | `ls -l` |
| Mostrar ocultos | `ls -a` |
| Mudar diretório | `cd caminho` |
| Diretório pessoal | `cd ~` |
| Subir diretório | `cd ..` |
| Criar diretório | `mkdir nome` |
| Criar arquivo vazio | `touch arquivo` |
| Copiar | `cp origem destino` |
| Mover/renomear | `mv origem destino` |
| Remover arquivo | `rm arquivo` |
| Ver arquivo | `cat arquivo` |
| Navegar em arquivo | `less arquivo` |
| Primeiras linhas | `head arquivo` |
| Últimas linhas | `tail arquivo` |
| Editar | `nano arquivo` |
| Usuário | `whoami` |
| Identidade/grupos | `id` |
| Executar como administrador | `sudo comando` |
| Atualizar índice APT | `sudo apt update` |
| Instalar pacote | `sudo apt install pacote` |
| Pesquisar | `grep termo arquivo` |
| Contar linhas | `wc -l arquivo` |
| Ordenar | `sort arquivo` |
| Eliminar repetições adjacentes | `uniq` |
| Selecionar campos | `cut` |
| Pipe | `comando1 \| comando2` |
| Redirecionar/sobrescrever | `comando > arquivo` |
| Redirecionar/acrescentar | `comando >> arquivo` |
| Mostrar e salvar | `comando \| tee arquivo` |
| Ajuda rápida | `comando --help` |
| Manual | `man comando` |
| Interfaces | `ip -br addr` |
| Rotas | `ip route` |
| Testar conectividade | `ping -c 4 IP` |
| Histórico | `history` |
| Tornar script executável | `chmod +x script.sh` |
| Executar script | `./script.sh` |

---

# 45. Referências e créditos

## Bibliografia e documentação de referência

Este material foi elaborado e conferido a partir de documentação técnica da comunidade Linux e dos projetos responsáveis pelas ferramentas utilizadas, incluindo:

1. **FREE SOFTWARE FOUNDATION. GNU Bash Reference Manual.** Documentação oficial do Bash.  
   https://www.gnu.org/software/bash/manual/

2. **FREE SOFTWARE FOUNDATION. GNU Coreutils Manual.** Documentação das ferramentas GNU para manipulação de arquivos, texto e operações básicas do sistema.  
   https://www.gnu.org/software/coreutils/manual/

3. **GNU NANO PROJECT. The GNU nano text editor – Documentation.** Manual e documentação oficial do editor GNU nano.  
   https://www.nano-editor.org/docs.php

4. **LINUX MAN-PAGES PROJECT. Linux manual pages.** Documentação de referência para interfaces e comandos disponíveis em sistemas Linux.  
   https://www.kernel.org/doc/man-pages/

5. **UBUNTU. Ubuntu Manpages – APT.** Documentação do gerenciador de pacotes utilizado no Ubuntu.  
   https://manpages.ubuntu.com/

6. As páginas locais de manual e ajuda das ferramentas utilizadas também constituem referência primária durante as práticas:

```bash
man comando
comando --help
```

> Os exemplos e explicações deste guia foram redigidos especificamente para fins didáticos. O material não reproduz integralmente os manuais das ferramentas e não os substitui.

## Curadoria e adaptação didática

**Curadoria, seleção de conteúdos, organização e adaptação para a disciplina:**  
**Prof. Dr. Diego Canizio Lopes**  
Instituto Federal de Educação, Ciência e Tecnologia do Acre – IFAC

Este material foi organizado para atender aos conhecimentos de Linux e Shell necessários à disciplina **Redes de Computadores II**, com foco em:

```text
uso do terminal
manipulação de arquivos
edição de configurações
processamento de texto
composição de comandos
coleta de evidências
automação básica
diagnóstico de redes
```

O conteúdo foi deliberadamente limitado ao que oferece suporte direto às atividades práticas da disciplina.

## Apoio à elaboração

Apoio na estruturação, redação e revisão do material:

**ChatGPT – OpenAI**

A responsabilidade pela curadoria pedagógica, seleção do conteúdo e adequação à disciplina é do docente responsável.

---

## Observação final

Em Linux, saber consultar documentação é tão importante quanto memorizar comandos.

Quando surgir uma dúvida:

```text
1. identifique o que precisa fazer;
2. consulte a ajuda;
3. leia a sintaxe;
4. teste em ambiente controlado;
5. observe o resultado;
6. registre o que aprendeu.
```

Esse processo será utilizado continuamente em Redes de Computadores II.
