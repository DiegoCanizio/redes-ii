# Aula 09 — DNS por dentro, BIND e primeira zona direta

**Data:** 29/10/2026  
**Duração:** 150 minutos

## Objetivos

Ao final desta aula, você deverá ser capaz de:

- explicar a função básica do DNS;
- diferenciar nome, endereço IP, resolver e servidor DNS;
- interpretar uma resposta do `dig`;
- reconhecer registros `A`, `AAAA`, `NS`, `MX` e `CNAME`;
- observar consultas DNS na rede;
- instalar e preparar o BIND;
- criar uma zona direta autoritativa para `empresa.test`;
- validar a configuração antes de reiniciar o serviço;
- testar a resolução diretamente contra o servidor DNS;
- aplicar uma sequência inicial de diagnóstico.

## Estado esperado ao final

```text
SERVIDOR
srv-r2-sNN
lab0 = 192.168.50.10/24

CLIENTE
cli-r2-sNN
lab0 = 192.168.50.50/24

DNS AUTORITATIVO
empresa.test
    ├── ns1.empresa.test     → 192.168.50.10
    ├── srv.empresa.test     → 192.168.50.10
    ├── cliente.empresa.test → 192.168.50.50
    ├── mail.empresa.test    → 192.168.50.10
    └── www.empresa.test     → srv.empresa.test
```

> Nesta aula ainda consultaremos o DNS explicitamente com `@192.168.50.10`.
> A integração DHCP + DNS será feita posteriormente.

---

# 1. Verifique o estado inicial 

Antes de configurar DNS, confirme que a rede construída nas aulas anteriores está funcionando.

No servidor:

```bash
hostname
ip -4 -br addr show lab0
```

Esperado:

```text
srv-r2-sNN
lab0    UP    192.168.50.10/24
```

Teste o cliente:

```bash
ping -c 2 192.168.50.50
```

Se o cliente não responder, resolva primeiro a conectividade entre servidor e cliente.

A pergunta que orientará esta aula é:

```text
Hoje acessamos o cliente por 192.168.50.50.

Como fazer para usar um nome, por exemplo:

cliente.empresa.test
```

---

# 2. DNS antes do BIND 

## 2.1 Observe o resolvedor atual

No servidor:

```bash
resolvectl status
```

Observe:

- quais interfaces aparecem;
- quais servidores DNS estão configurados;
- qual interface participa da resolução externa.

O DNS já está sendo utilizado pelo sistema antes mesmo de instalarmos o BIND.

---

## 2.2 Faça consultas públicas

Execute:

```bash
dig example.com A
```

Depois:

```bash
dig example.com AAAA
```

```bash
dig example.com NS
```

```bash
dig gmail.com MX
```

Não observe apenas o resultado final. Localize na saída:

```text
status
QUESTION SECTION
ANSWER SECTION
SERVER
Query time
TTL
```

---

## 2.3 Tipos de registro

Nesta aula utilizaremos principalmente:

```text
A       nome → endereço IPv4
AAAA    nome → endereço IPv6
NS      informa o servidor DNS responsável pela zona
MX      informa o servidor responsável por e-mail
CNAME   cria um apelido para outro nome
```

Exemplos conceituais:

```text
srv.empresa.test
        ↓ A
192.168.50.10
```

```text
www.empresa.test
        ↓ CNAME
srv.empresa.test
        ↓ A
192.168.50.10
```

> Existe também o registro `PTR`, utilizado na resolução reversa. Ele será estudado na Aula 10.

---

## 2.4 Resolver padrão × servidor específico

Execute:

```bash
dig example.com A
```

Agora consulte explicitamente outro servidor:

```bash
dig @1.1.1.1 example.com A
```

Compare o campo:

```text
SERVER
```

O formato:

```bash
dig @SERVIDOR NOME TIPO
```

será utilizado durante os testes do nosso BIND.

---

# 3. Observe DNS na rede 

Descubra a interface utilizada pela rota padrão:

```bash
ip route show default
```

No laboratório, ela normalmente será `host0`.

Abra uma captura:

```bash
sudo tcpdump -i host0 -nn 'port 53'
```

Em outro terminal:

```bash
dig iana.org A
```

Observe a consulta e a resposta.

Associe:

```text
aplicação
   ↓
resolver
   ↓
consulta DNS
   ↓
porta 53
   ↓
servidor DNS
```

Interrompa o `tcpdump` com:

```text
Ctrl+C
```

---

# 4. Instale e conheça o BIND

Instale os pacotes:

```bash
sudo apt update
sudo apt install -y bind9 bind9-utils dnsutils
```

No Ubuntu utilizado no laboratório, o pacote é `bind9` e o serviço é administrado pela unidade:

```text
named.service
```

Confira:

```bash
systemctl status named --no-pager
```

Depois:

```bash
sudo ss -luntp | grep ':53'
```

Neste momento, o serviço existe, mas ainda não criamos a nossa zona.

---

# 5. Restrinja o BIND ao laboratório 

Edite:

```bash
sudo nano /etc/bind/named.conf.options
```

Mantenha as opções necessárias existentes no arquivo e garanta estas diretivas dentro de `options`:

```conf
listen-on { 127.0.0.1; 192.168.50.10; };
listen-on-v6 { none; };

allow-query {
    localhost;
    192.168.50.0/24;
};
```

A ideia é separar os papéis:

```text
host0
→ gerenciamento e acesso externo

lab0
→ rede experimental da disciplina
→ clientes consultam o BIND
```

Antes de continuar:

```bash
sudo named-checkconf
```

Se o comando não apresentar erro, prossiga.

---

# 6. Construa a zona direta `empresa.test`

## 6.1 Declare a zona

Edite:

```bash
sudo nano /etc/bind/named.conf.local
```

Adicione:

```conf
zone "empresa.test" {
    type master;
    file "/etc/bind/db.empresa.test";
};
```

---

## 6.2 Crie o arquivo da zona

Edite:

```bash
sudo nano /etc/bind/db.empresa.test
```

Utilize:

```dns
$TTL 300

@   IN  SOA ns1.empresa.test. admin.empresa.test. (
        2026102901
        3600
        900
        604800
        300
)

        IN  NS      ns1.empresa.test.
        IN  MX 10   mail.empresa.test.

ns1      IN  A       192.168.50.10
srv      IN  A       192.168.50.10
cliente  IN  A       192.168.50.50
mail     IN  A       192.168.50.10
www      IN  CNAME   srv.empresa.test.
```

---

## 6.3 Interprete o arquivo

### `$TTL`

```dns
$TTL 300
```

Define o TTL padrão dos registros.

### SOA

```dns
@ IN SOA ns1.empresa.test. admin.empresa.test.
```

O `SOA` descreve informações fundamentais da zona.

Observe também o serial:

```text
2026102901
```

Durante a disciplina utilizaremos o padrão:

```text
AAAAMMDDNN
```

### NS

```dns
IN NS ns1.empresa.test.
```

Indica o servidor autoritativo da zona.

Por isso também precisamos:

```dns
ns1 IN A 192.168.50.10
```

### A

```dns
srv     IN A 192.168.50.10
cliente IN A 192.168.50.50
mail    IN A 192.168.50.10
```

Agora ligamos a Aula 08 ao DNS:

```text
DHCP:
MAC do cliente
      ↓
192.168.50.50

DNS:
cliente.empresa.test
      ↓
192.168.50.50
```

### CNAME

```dns
www IN CNAME srv.empresa.test.
```

`www` é um apelido de `srv`.

Observe o ponto final em:

```text
srv.empresa.test.
```

Ele representa um nome DNS completo.

### MX

```dns
IN MX 10 mail.empresa.test.
```

Define `mail.empresa.test` como servidor de e-mail da zona.

Nesta aula não configuraremos um serviço de e-mail; estamos apenas criando o registro DNS.

---

# 7. Valide e teste a zona

## 7.1 Valide a configuração global

```bash
sudo named-checkconf
```

Não prossiga se houver erro.

## 7.2 Valide especificamente a zona

```bash
sudo named-checkzone empresa.test /etc/bind/db.empresa.test
```

Esperado:

```text
OK
```

## 7.3 Reinicie o serviço

Somente depois das validações:

```bash
sudo systemctl restart named
```

Confira:

```bash
systemctl is-active named
```

Esperado:

```text
active
```

Confirme a porta:

```bash
sudo ss -luntp | grep ':53'
```

## 7.4 Teste no servidor

Execute:

```bash
dig @192.168.50.10 empresa.test NS
```

```bash
dig @192.168.50.10 srv.empresa.test A
```

```bash
dig @192.168.50.10 cliente.empresa.test A
```

```bash
dig @192.168.50.10 www.empresa.test
```

```bash
dig @192.168.50.10 empresa.test MX
```

Compare as respostas com o arquivo da zona.

## 7.5 Teste a partir do cliente

Acesse o cliente pelo endereço reservado:

```bash
ssh SEU_USUARIO@192.168.50.50
```

Teste:

```bash
dig @192.168.50.10 srv.empresa.test A
```

```bash
dig @192.168.50.10 cliente.empresa.test A
```

```bash
dig @192.168.50.10 www.empresa.test
```

Neste momento:

```text
cliente
   ↓
consulta explicitamente
   ↓
192.168.50.10
   ↓
BIND
   ↓
empresa.test
```

Ainda precisamos escrever:

```text
@192.168.50.10
```

Isso será resolvido quando integrarmos DHCP e DNS.

---

# 8. Primeira rotina de diagnóstico DNS 

Uma configuração DNS deve ser verificada em camadas.

```text
1. arquivo existe e está correto?
        ↓
2. sintaxe é válida?
        ↓
3. serviço está ativo?
        ↓
4. porta 53 está em escuta?
        ↓
5. cliente alcança o servidor?
        ↓
6. consulta chega ao DNS?
        ↓
7. resposta é a esperada?
```

Ferramentas:

```bash
sudo named-checkconf
```

```bash
sudo named-checkzone empresa.test /etc/bind/db.empresa.test
```

```bash
systemctl status named --no-pager
```

```bash
sudo ss -luntp | grep ':53'
```

```bash
ping -c 2 192.168.50.10
```

```bash
dig @192.168.50.10 cliente.empresa.test A
```

```bash
sudo journalctl -u named -n 30 --no-pager
```

```bash
sudo tcpdump -i lab0 -nn 'port 53'
```

> Na próxima aula essa sequência será utilizada em um incidente controlado.

---

# Portfólio

Registre em:

```text
dns/aula-09/
```

Inclua:

- explicação curta da função do DNS;
- diferença entre consulta padrão e `dig @servidor`;
- função dos registros `A`, `AAAA`, `NS`, `MX` e `CNAME`;
- conteúdo de `/etc/bind/named.conf.local`;
- conteúdo de `/etc/bind/db.empresa.test`;
- evidência de `named-checkzone`;
- evidência de `named` ativo;
- evidência da porta 53;
- consultas para `srv.empresa.test`, `cliente.empresa.test` e `www.empresa.test`;
- uma breve descrição da sequência de diagnóstico DNS.

---

# Resultado da aula

Ao final:

```text
cliente.empresa.test
        ↓
192.168.50.50

srv.empresa.test
        ↓
192.168.50.10

www.empresa.test
        ↓
srv.empresa.test
        ↓
192.168.50.10
```

Na Aula 10 inverteremos a pergunta:

```text
Se eu tenho 192.168.50.50,
como descubro o nome associado a esse endereço?
```
