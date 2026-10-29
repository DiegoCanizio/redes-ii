# Aula 10 — DNS reverso, validação e diagnóstico

**Data:** 03/11/2026  
**Duração:** 100 minutos

## Objetivos

Ao final desta aula, você deverá ser capaz de:

- diferenciar resolução direta e reversa;
- explicar a função do registro `PTR`;
- compreender a estrutura `in-addr.arpa`;
- criar uma zona reversa para `192.168.50.0/24`;
- manter coerência entre registros `A` e `PTR`;
- validar uma zona reversa;
- utilizar `dig -x`;
- aplicar diagnóstico DNS em camadas;
- investigar uma falha sem começar por alterações aleatórias.

## Estado esperado ao final

```text
RESOLUÇÃO DIRETA

srv.empresa.test
        ↓
192.168.50.10

cliente.empresa.test
        ↓
192.168.50.50

RESOLUÇÃO REVERSA

192.168.50.10
        ↓
srv.empresa.test

192.168.50.50
        ↓
cliente.empresa.test
```

---

# 1. Retome e valide a zona direta

Antes de criar a zona reversa, confirme que a Aula 09 continua funcional.

No servidor:

```bash
sudo named-checkconf
```

Depois:

```bash
sudo named-checkzone empresa.test /etc/bind/db.empresa.test
```

Teste:

```bash
dig @192.168.50.10 srv.empresa.test A
```

```bash
dig @192.168.50.10 cliente.empresa.test A
```

Resultados esperados:

```text
srv.empresa.test      → 192.168.50.10
cliente.empresa.test  → 192.168.50.50
```

Se a zona direta não estiver funcional, corrija-a antes de continuar.

---

# 2. Entenda a resolução reversa 

Na resolução direta perguntamos:

```text
Qual é o endereço de cliente.empresa.test?
```

Resposta:

```text
192.168.50.50
```

Na resolução reversa fazemos a pergunta oposta:

```text
Qual nome está associado a 192.168.50.50?
```

Resposta desejada:

```text
cliente.empresa.test
```

## 2.1 A × PTR

Na zona direta utilizamos:

```dns
cliente IN A 192.168.50.50
```

Na zona reversa utilizaremos:

```dns
50 IN PTR cliente.empresa.test.
```

Portanto:

```text
A
nome → IPv4

PTR
IPv4 → nome
```

## 2.2 `in-addr.arpa`

Para IPv4, a resolução reversa utiliza a árvore:

```text
in-addr.arpa
```

Nossa rede é:

```text
192.168.50.0/24
```

A zona reversa correspondente será:

```text
50.168.192.in-addr.arpa
```

Observe a inversão:

```text
192 . 168 . 50
 ↓     ↓     ↓
50  . 168 . 192
```

Para o endereço:

```text
192.168.50.50
```

a consulta completa envolve:

```text
50.50.168.192.in-addr.arpa
```

---

# 3. Crie a zona reversa 

## 3.1 Declare a zona

Edite:

```bash
sudo nano /etc/bind/named.conf.local
```

Mantenha a zona direta existente e acrescente:

```conf
zone "50.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168.50";
};
```

Ao final, o arquivo deverá possuir as duas zonas:

```conf
zone "empresa.test" {
    type master;
    file "/etc/bind/db.empresa.test";
};

zone "50.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168.50";
};
```

## 3.2 Crie o arquivo da zona reversa

Edite:

```bash
sudo nano /etc/bind/db.192.168.50
```

Utilize:

```dns
$TTL 300

@   IN  SOA ns1.empresa.test. admin.empresa.test. (
        2026110301
        3600
        900
        604800
        300
)

    IN  NS  ns1.empresa.test.

10  IN  PTR srv.empresa.test.
50  IN  PTR cliente.empresa.test.
```

Agora temos:

```text
ZONA DIRETA

srv.empresa.test
        ↓
192.168.50.10

cliente.empresa.test
        ↓
192.168.50.50
```

E:

```text
ZONA REVERSA

192.168.50.10
        ↓
srv.empresa.test

192.168.50.50
        ↓
cliente.empresa.test
```

---

# 4. Valide e teste 

## 4.1 Valide a configuração

```bash
sudo named-checkconf
```

Depois:

```bash
sudo named-checkzone \
50.168.192.in-addr.arpa \
/etc/bind/db.192.168.50
```

Esperado:

```text
OK
```

## 4.2 Recarregue o serviço

Como o serviço já está funcionando:

```bash
sudo systemctl reload named
```

Confira:

```bash
systemctl is-active named
```

Esperado:

```text
active
```

## 4.3 Teste a resolução reversa

```bash
dig @192.168.50.10 -x 192.168.50.10
```

Esperado:

```text
srv.empresa.test.
```

Depois:

```bash
dig @192.168.50.10 -x 192.168.50.50
```

Esperado:

```text
cliente.empresa.test.
```

Compare com a resolução direta:

```bash
dig @192.168.50.10 cliente.empresa.test A
```

---

# 5. Diagnóstico DNS em camadas 

A partir de agora, não comece um diagnóstico alterando arquivos.

Comece pelo sintoma e produza evidências.

Utilize a sequência:

```text
SINTOMA
   ↓
HIPÓTESE
   ↓
TESTE
   ↓
EVIDÊNCIA
   ↓
CAUSA
   ↓
CORREÇÃO
   ↓
VALIDAÇÃO
```

Para DNS, investigue em camadas:

```text
1. configuração
        ↓
2. zona
        ↓
3. serviço
        ↓
4. porta
        ↓
5. conectividade
        ↓
6. consulta
        ↓
7. conteúdo da resposta
```

## Camada 1 — configuração

```bash
sudo named-checkconf
```

## Camada 2 — zona

Direta:

```bash
sudo named-checkzone empresa.test /etc/bind/db.empresa.test
```

Reversa:

```bash
sudo named-checkzone \
50.168.192.in-addr.arpa \
/etc/bind/db.192.168.50
```

## Camada 3 — serviço

```bash
systemctl status named --no-pager
```

Logs:

```bash
sudo journalctl -u named -n 30 --no-pager
```

## Camada 4 — porta

```bash
sudo ss -luntp | grep ':53'
```

## Camada 5 — conectividade

A partir do cliente:

```bash
ping -c 2 192.168.50.10
```

## Camada 6 — consulta

```bash
dig @192.168.50.10 cliente.empresa.test A
```

```bash
dig @192.168.50.10 -x 192.168.50.50
```

## Camada 7 — tráfego e resposta

No servidor:

```bash
sudo tcpdump -i lab0 -nn 'port 53'
```

Em outro terminal ou no cliente:

```bash
dig @192.168.50.10 -x 192.168.50.50
```

A pergunta não é apenas:

```text
"O servidor respondeu?"
```

Também precisamos perguntar:

```text
"A resposta está correta?"
```

---

# 6. Incidente controlado 

O professor introduzirá uma inconsistência em uma configuração DNS.

## Regras

1. Não altere arquivos imediatamente.
2. Observe primeiro o sintoma.
3. Produza pelo menos uma hipótese.
4. Execute testes para obter evidências.
5. Identifique a causa.
6. Faça somente a correção necessária.
7. Valide novamente o funcionamento.

Utilize, quando necessário:

```bash
sudo named-checkconf
```

```bash
sudo named-checkzone empresa.test /etc/bind/db.empresa.test
```

```bash
sudo named-checkzone \
50.168.192.in-addr.arpa \
/etc/bind/db.192.168.50
```

```bash
systemctl status named --no-pager
```

```bash
sudo ss -luntp | grep ':53'
```

```bash
sudo journalctl -u named -n 30 --no-pager
```

```bash
dig @192.168.50.10 cliente.empresa.test A
```

```bash
dig @192.168.50.10 -x 192.168.50.50
```

```bash
sudo tcpdump -i lab0 -nn 'port 53'
```

Registre o diagnóstico no formato:

```text
Sintoma:
________________________________________

Hipótese:
________________________________________

Teste:
________________________________________

Evidência:
________________________________________

Causa:
________________________________________

Correção:
________________________________________

Validação:
________________________________________
```

---

# 7. Fechamento 

Ao final das Aulas 09 e 10 temos:

```text
DHCP
MAC do cliente
        ↓
192.168.50.50
```

```text
DNS direto
cliente.empresa.test
        ↓
192.168.50.50
```

```text
DNS reverso
192.168.50.50
        ↓
cliente.empresa.test
```

Ainda existe uma limitação:

```bash
dig @192.168.50.10 cliente.empresa.test
```

Precisamos informar manualmente:

```text
@192.168.50.10
```

Na próxima etapa da disciplina integraremos DHCP e DNS para que o cliente aprenda automaticamente qual servidor DNS utilizar.

---

# Portfólio

Registre em:

```text
dns/aula-10/
```

Inclua:

- diferença entre resolução direta e reversa;
- função de `A` e `PTR`;
- explicação curta de `in-addr.arpa`;
- conteúdo da zona reversa;
- serial utilizado;
- evidência de `named-checkzone`;
- resultado de `dig -x 192.168.50.10`;
- resultado de `dig -x 192.168.50.50`;
- diagnóstico do incidente no formato:
  - Sintoma;
  - Hipótese;
  - Teste;
  - Evidência;
  - Causa;
  - Correção;
  - Validação.

---

# Resultado esperado

```text
srv.empresa.test      ↔ 192.168.50.10
cliente.empresa.test  ↔ 192.168.50.50
```

Além de configurar DNS, o objetivo é conseguir responder:

```text
Em qual camada está a falha
e qual evidência demonstra isso?
```
