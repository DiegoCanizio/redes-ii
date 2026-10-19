# Aula 10 — DNS: resolução de nomes e `dig`

**Data:** 03/11/2026  
**Duração:** 100 minutos

---

## Situação-problema

Até agora acessamos serviços principalmente por endereço IP.

Humanos preferem nomes:

```text
www.empresa.test
```

Computadores precisam relacioná-los a endereços:

```text
www.empresa.test
        ↓
192.168.50.10
```

Hoje o foco é entender **como uma consulta DNS funciona** antes de criar nosso próprio servidor autoritativo.

---

# Objetivos

- compreender a função do DNS;
- diferenciar nome e endereço;
- utilizar `dig`;
- identificar tipos de registros;
- observar servidor consultado e resposta;
- capturar tráfego DNS.

---

# 1. Conceitos

Alguns registros:

```text
A      → nome para IPv4
AAAA   → nome para IPv6
CNAME  → apelido para outro nome
MX     → servidor de e-mail
NS     → servidor responsável pela zona
PTR    → resolução reversa
```

---

# 2. Verifique a resolução atual do servidor

No servidor:

```bash
cat /etc/resolv.conf
```

Quando disponível:

```bash
resolvectl status
```

Teste:

```bash
getent hosts github.com
```

---

# 3. Instale ferramentas DNS

No servidor:

```bash
sudo apt update
sudo apt install -y dnsutils
```

Confira:

```bash
dig -v
```

---

# 4. Faça consultas

```bash
dig github.com A
```

Observe as seções:

```text
QUESTION
ANSWER
AUTHORITY
ADDITIONAL
```

Faça uma consulta resumida:

```bash
dig +short github.com
```

---

# 5. Consulte tipos diferentes

Exemplos:

```bash
dig google.com A
dig google.com AAAA
dig gmail.com MX
dig com NS
```

Registre uma diferença observada entre os resultados.

---

# 6. Consulte um servidor explicitamente

Exemplo:

```bash
dig @1.1.1.1 example.com A
```

O símbolo:

```text
@SERVIDOR
```

indica qual servidor DNS será consultado.

---

# 7. Resolução reversa

Escolha um IPv4 obtido em uma consulta anterior:

```bash
dig -x ENDERECO_IP
```

O resultado utiliza registros:

```text
PTR
```

---

# 8. Observe DNS no tráfego

Em um terminal do servidor:

```bash
sudo tcpdump -i host0 -nn 'port 53'
```

Em outro:

```bash
dig @1.1.1.1 example.com A
```

Observe:

- IP de origem;
- IP do servidor DNS;
- porta 53;
- requisição e resposta.

> Nesta etapa `host0` está apenas sendo observada. Não altere sua configuração.

---

# 9. Compare `dig` e `getent`

```bash
dig example.com
```

e:

```bash
getent hosts example.com
```

`dig` é uma ferramenta de investigação DNS.

`getent` consulta o mecanismo de resolução utilizado pelo sistema.

Isso será importante quando integrarmos o cliente ao nosso DNS.

---

# 10. Planeje a zona da disciplina

Nas próximas aulas utilizaremos:

```text
empresa.test
```

Nomes previstos:

```text
ns.empresa.test
srv.empresa.test
www.empresa.test
mail.empresa.test
```

Endereço principal do servidor:

```text
192.168.50.10
```

Pense:

```text
Qual registro aponta ns.empresa.test para um IPv4?
____________________________________

Qual registro pode tornar www um apelido de srv?
____________________________________

Qual registro indica o servidor de e-mail?
____________________________________
```

---

# 11. Preparação do portfólio

Crie:

```bash
cd ~/SEU_REPOSITORIO
mkdir -p dns
```

Não faça o commit ainda.

As Aulas 10, 11 e 12 formam o marco:

```text
DNS + integração DHCP/DNS
```
