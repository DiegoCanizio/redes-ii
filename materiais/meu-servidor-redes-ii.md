# Meu Servidor de Redes II

**Disciplina:** Redes de Computadores II  
**Curso:** Tecnologia em Sistemas para Internet  
**Instituição:** Instituto Federal do Acre — IFAC  
**Professor:** Prof. Dr. Diego Canizio Lopes

---

## 1. O que é o meu servidor?

Durante a disciplina de Redes de Computadores II, cada estudante terá um **servidor Linux individual e persistente**.

Esse servidor será utilizado ao longo do semestre para atividades de configuração, testes, diagnóstico e implantação de serviços de rede.

O ambiente foi preparado para que cada estudante possa trabalhar de forma independente.

De maneira simplificada:

```text
Seu computador
      |
      | SSH
      v
Seu servidor Linux
      |
      | rede de laboratório
      v
Seu cliente Linux
```

O servidor permanece salvo entre as aulas. Portanto, arquivos, configurações, serviços instalados e alterações feitas por você continuarão disponíveis posteriormente.

> **Importante:** seu servidor não é uma máquina descartável. Antes de alterar arquivos importantes, faça cópias de segurança e documente o que foi modificado.

---

## 2. Seus dados de acesso

O professor fornecerá individualmente:

```text
Servidor: 172.16.2.34
Porta SSH: <sua_porta>
Usuário: <seu_usuario>
Senha inicial: <sua_senha_inicial>
```

Cada estudante possui uma **porta SSH exclusiva**.

Exemplo fictício:

```text
Servidor: 172.16.2.34
Porta: 2201
Usuário: ana
```

O acesso seria:

```bash
ssh -p 2201 ana@172.16.2.34
```

Não utilize a porta ou o usuário de outro estudante.

---

## 3. Primeiro acesso pelo Windows

Abra o **PowerShell**, **Windows Terminal** ou outro terminal com cliente SSH.

Execute:

```powershell
ssh -p SUA_PORTA SEU_USUARIO@172.16.2.34
```

Exemplo:

```powershell
ssh -p 2201 ana@172.16.2.34
```

No primeiro acesso, poderá aparecer uma mensagem semelhante a:

```text
The authenticity of host ... can't be established.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Digite:

```text
yes
```

Depois informe sua senha inicial.

> Durante a digitação da senha, nada aparece na tela. Isso é comportamento normal do terminal Linux.

---

## 4. Troca da senha inicial

No primeiro login, o sistema poderá exigir a troca da senha.

Caso isso ocorra, siga as solicitações exibidas no terminal.

Para alterar a senha:

```bash
sudo passwd "$(whoami)"
```

Quando o `sudo` solicitar a senha atual, informe a senha utilizada no login.

Escolha uma senha que você consiga lembrar e **não compartilhe com colegas**.

O professor não precisa conhecer sua nova senha.

---

## 5. Confirmando que você está no servidor correto

Depois de entrar, execute:

```bash
whoami
```

O resultado deve ser o seu usuário.

Exemplo:

```text
ana
```

Depois:

```bash
hostname
```

O servidor terá um nome semelhante a:

```text
srv-r2-s01
```

O formato utilizado é:

```text
srv-r2-sNN
```

onde `NN` identifica o ambiente individual do estudante.

Também é possível verificar:

```bash
hostnamectl
```

---

## 6. Conhecendo as interfaces de rede

Execute:

```bash
ip -br addr
```

Seu servidor possui duas interfaces com funções diferentes.

### `host0`

É a interface de **gerenciamento**.

Ela permite:

- acesso à Internet;
- instalação de pacotes;
- acesso ao GitHub;
- conexão SSH ao servidor;
- atualização do sistema.

O endereço de `host0` é atribuído automaticamente e pode variar.

> **Não altere manualmente a configuração de `host0`, a menos que o professor solicite explicitamente.**

### `lab0`

É a interface da **rede experimental da disciplina**.

Ela será usada nas atividades práticas para conectar seu servidor ao seu cliente Linux.

Exemplo de topologia futura:

```text
srv-r2-sNN
lab0: 192.168.50.10/24
       |
       |
     rede
       |
       |
lab0: 192.168.50.20/24
cli-r2-sNN
```

No início, `lab0` pode não possuir endereço IPv4. Isso é intencional.

Você aprenderá a configurá-la durante as aulas.

---

## 7. Uma regra importante: não configure gateway em `lab0`

A interface `host0` já fornece o caminho de gerenciamento e acesso externo do servidor.

Por isso, nas atividades iniciais, **não crie uma rota padrão pela `lab0`**.

Você pode verificar as rotas com:

```bash
ip route
```

A rota `default` não deve apontar para a rede experimental `192.168.50.0/24`, a menos que uma atividade futura determine isso explicitamente.

---

## 8. Acesso administrativo com `sudo`

Seu usuário possui permissão administrativa **dentro do seu servidor**.

Para executar um comando administrativo:

```bash
sudo comando
```

Exemplo:

```bash
sudo apt update
```

Para instalar um pacote:

```bash
sudo apt install NOME_DO_PACOTE
```

Exemplo:

```bash
sudo apt install curl
```

A senha solicitada pelo `sudo` é a **sua própria senha**.

> Seu `sudo` funciona somente dentro do seu ambiente. Você não possui acesso administrativo ao servidor físico que hospeda os laboratórios dos estudantes.

---

## 9. Verificando acesso à Internet

Teste conectividade:

```bash
ping -c 3 1.1.1.1
```

Teste resolução de nomes:

```bash
getent hosts github.com
```

Ou:

```bash
ping -c 3 github.com
```

Esses testes utilizam a interface de gerenciamento do servidor.

---

## 10. Atualizando a lista de pacotes

Antes de instalar novos programas:

```bash
sudo apt update
```

Para pesquisar um pacote:

```bash
apt search nome
```

Para instalar:

```bash
sudo apt install pacote
```

Não execute atualizações completas do sistema sem necessidade durante uma aula.

---

## 11. Serviços no Linux

Ao longo da disciplina, vários serviços serão gerenciados com `systemctl`.

Verifique o estado de um serviço:

```bash
systemctl status ssh
```

Inicie:

```bash
sudo systemctl start NOME
```

Pare:

```bash
sudo systemctl stop NOME
```

Reinicie:

```bash
sudo systemctl restart NOME
```

Configure para iniciar automaticamente:

```bash
sudo systemctl enable NOME
```

Ative e inicie ao mesmo tempo:

```bash
sudo systemctl enable --now NOME
```

Veja serviços com falha:

```bash
systemctl --failed
```

---

## 12. Portas e processos

Para verificar portas em uso:

```bash
ss -lntup
```

Somente TCP:

```bash
ss -lnt
```

Exemplo de filtro:

```bash
ss -lnt | grep ':22'
```

Ao implantar um serviço, não considere apenas que "o programa está instalado".

Verifique:

```text
serviço iniciado
        ↓
porta aberta
        ↓
configuração correta
        ↓
conectividade
        ↓
teste do protocolo
```

---

## 13. Logs

Os logs são uma das principais fontes de evidência durante o diagnóstico.

Para acompanhar logs de um serviço:

```bash
journalctl -u NOME_DO_SERVICO
```

Últimas linhas:

```bash
journalctl -u NOME_DO_SERVICO -n 30
```

Acompanhar em tempo real:

```bash
journalctl -u NOME_DO_SERVICO -f
```

Exemplo:

```bash
sudo journalctl -u ssh -n 30
```

---

## 14. Seu cliente Linux

Além do servidor, você possui um **cliente Linux individual**.

O cliente terá um nome semelhante a:

```text
cli-r2-sNN
```

Ele é utilizado somente nas atividades que exigem comunicação cliente/servidor.

O professor poderá ligá-lo antes ou durante a aula.

Quando a rede experimental estiver configurada, o acesso poderá ocorrer a partir do seu servidor, por exemplo:

```bash
ssh SEU_USUARIO@192.168.50.20
```

O endereço utilizado em cada atividade será informado pelo professor.

---

## 15. Rede isolada por estudante

Cada estudante possui sua própria rede virtual.

Isso permite que todos possam utilizar, por exemplo:

```text
192.168.50.0/24
```

ao mesmo tempo, sem conflito entre colegas.

Conceitualmente:

```text
Aluno 01

srv-r2-s01 ------- cli-r2-s01
     192.168.50.0/24


Aluno 02

srv-r2-s02 ------- cli-r2-s02
     192.168.50.0/24


Aluno 03

srv-r2-s03 ------- cli-r2-s03
     192.168.50.0/24
```

As redes são independentes.

Essa separação será especialmente importante nas aulas de:

- DHCP;
- DNS;
- firewall;
- serviços web;
- testes cliente/servidor.

---

## 16. Organização recomendada

Crie um diretório para a disciplina:

```bash
mkdir -p ~/redes2
```

Entre nele:

```bash
cd ~/redes2
```

Uma organização possível:

```text
~/redes2/
├── configuracoes/
├── scripts/
├── testes/
├── evidencias/
└── anotacoes/
```

Você poderá adaptar essa estrutura conforme as atividades evoluírem.

---

## 17. Git e o portfólio da disciplina

Seu servidor é o ambiente em que os serviços funcionam.

Seu repositório da disciplina é o local em que você registra e versiona o trabalho realizado.

A lógica será:

```text
configurar
    ↓
testar
    ↓
diagnosticar
    ↓
corrigir
    ↓
documentar
    ↓
git add
    ↓
git commit
    ↓
git push
```

Não versione senhas, chaves privadas, tokens ou outros segredos.

Antes de um `git add .`, sempre confira:

```bash
git status
```

---

## 18. Não dependa apenas do histórico do terminal

Uma configuração feita corretamente deve poder ser compreendida depois.

Quando fizer alterações relevantes, registre:

- arquivo alterado;
- objetivo;
- comandos utilizados;
- testes realizados;
- resultado;
- eventual erro encontrado;
- forma de correção.

O objetivo da disciplina não é apenas "fazer funcionar", mas compreender **por que funciona** e conseguir reproduzir a solução.

---

## 19. Método de troubleshooting

Durante a disciplina, utilize a seguinte sequência:

```text
Sintoma
   ↓
Hipótese
   ↓
Teste
   ↓
Evidência
   ↓
Causa
   ↓
Correção
   ↓
Validação
```

Exemplo:

```text
Sintoma:
cliente não acessa o servidor web

Hipótese:
Nginx não está escutando na porta 80

Teste:
ss -lnt | grep ':80'

Evidência:
nenhuma porta 80 em LISTEN

Causa:
serviço nginx parado

Correção:
sudo systemctl start nginx

Validação:
curl http://localhost
```

Evite modificar várias coisas ao mesmo tempo sem saber qual delas resolveu o problema.

---

## 20. Comandos úteis de diagnóstico

Identidade:

```bash
whoami
hostname
```

Interfaces:

```bash
ip -br addr
```

Rotas:

```bash
ip route
```

Vizinhos da rede:

```bash
ip neigh
```

Conectividade:

```bash
ping -c 3 ENDERECO
```

DNS:

```bash
getent hosts NOME
```

Portas:

```bash
ss -lntup
```

Serviços:

```bash
systemctl status SERVICO
```

Logs:

```bash
journalctl -u SERVICO
```

Processos:

```bash
ps aux
```

Espaço em disco:

```bash
df -h
```

Memória:

```bash
free -h
```

---

## 21. O que não deve ser feito

Não tente acessar o ambiente de outro aluno.

Não compartilhe sua senha.

Não altere `host0` sem orientação.

Não remova sua configuração SSH de acesso.

Não exponha senhas ou tokens no GitHub.

Não execute comandos destrutivos apenas porque foram encontrados na Internet.

Não copie uma configuração sem entender minimamente seu funcionamento.

Não trate o servidor como descartável.

---

## 22. Se algo der errado

Primeiro, colete informações.

Execute, quando forem relevantes:

```bash
hostname
whoami
ip -br addr
ip route
systemctl --failed
```

Para um serviço específico:

```bash
systemctl status SERVICO
journalctl -u SERVICO -n 30
```

Depois descreva o problema utilizando:

```text
O que eu esperava:
...

O que aconteceu:
...

Comando executado:
...

Mensagem de erro:
...

Testes realizados:
...
```

Uma mensagem de erro é uma **evidência de diagnóstico**, não algo que deve ser omitido.

---

## 23. Checklist do primeiro acesso

Após receber suas credenciais, confirme:

```text
[ ] Consegui conectar por SSH.
[ ] Troquei minha senha inicial.
[ ] whoami mostra meu usuário.
[ ] hostname mostra meu servidor individual.
[ ] Identifiquei host0.
[ ] Identifiquei lab0.
[ ] Não alterei host0.
[ ] Consigo acessar a Internet pelo servidor.
[ ] sudo funciona.
[ ] Sei verificar o status do SSH.
[ ] Sei consultar minhas interfaces e rotas.
```

---

## 24. Ideia central do laboratório

Ao longo da disciplina, o ambiente será construído progressivamente:

```text
manual
   ↓
documentado
   ↓
versionado
   ↓
scriptado
   ↓
automatizado
   ↓
containerizado
```

Você não utilizará apenas serviços prontos.

A proposta é aprender a:

> **implantar, configurar, testar, proteger, diagnosticar e reconstruir serviços reais de rede.**

---

## 25. Referência rápida

### Entrar no servidor

```bash
ssh -p SUA_PORTA SEU_USUARIO@172.16.2.34
```

### Ver interfaces

```bash
ip -br addr
```

### Ver rotas

```bash
ip route
```

### Testar Internet

```bash
ping -c 3 1.1.1.1
```

### Testar DNS

```bash
getent hosts github.com
```

### Atualizar lista de pacotes

```bash
sudo apt update
```

### Ver serviços com falha

```bash
systemctl --failed
```

### Ver portas

```bash
ss -lntup
```

### Ver logs de um serviço

```bash
journalctl -u SERVICO
```

### Trocar senha

```bash
sudo passwd "$(whoami)"
```

---

**Redes de Computadores II — IFAC**  
**Prof. Dr. Diego Canizio Lopes**
