# Aula 18 — SMTP, DNS e registros MX

## Objetivos

Ao final desta aula, você deverá conseguir:

- explicar o papel do registro MX;
- diferenciar resolução do servidor de correio e transporte SMTP;
- publicar a identidade mail.empresa.test no DNS;
- criar e validar um registro MX para empresa.test;
- testar DNS e SMTP separadamente;
- utilizar fila e logs para localizar uma falha de entrega;
- diagnosticar uma inconsistência entre DNS e correio eletrônico.

O Postfix configurado anteriormente continuará sendo utilizado.

---

## 1. Fluxo que será construído

~~~text
destinatário: bob@empresa.test
             │
             ▼
        consulta MX
             │
             ▼
empresa.test MX mail.empresa.test
             │
             ▼
mail.empresa.test → 192.168.50.10
             │
             ▼
          TCP/25
             │
             ▼
           Postfix
~~~

O DNS não transporta a mensagem.

O DNS informa qual host deve receber correio para um domínio.

---

## 2. Verifique o estado inicial

Servidor:

~~~bash
ip -4 -br addr show lab0
systemctl is-active bind9
systemctl is-active postfix
sudo ss -lntup | grep -E ':(25|53)'
~~~

Cliente:

~~~bash
resolvectl status lab0
dig empresa.test
~~~

---

## 3. Adicione o servidor de correio à zona direta

No servidor DNS, edite a zona empresa.test utilizada nas aulas anteriores.

Adicione:

~~~dns
mail    IN  A   192.168.50.10
@       IN  MX  10 mail.empresa.test.
~~~

Atualize o serial da zona conforme o padrão já utilizado na disciplina.

---

## 4. Valide o DNS antes de recarregar

Primeiro:

~~~bash
sudo named-checkconf
~~~

Depois valide a zona:

~~~bash
sudo named-checkzone empresa.test /etc/bind/db.empresa.test
~~~

Use o caminho real da zona caso seu arquivo tenha outro nome.

Somente após a validação:

~~~bash
sudo systemctl reload bind9
~~~

---

## 5. Consulte o MX

No cliente:

~~~bash
dig empresa.test MX
~~~

Depois:

~~~bash
dig mail.empresa.test A
~~~

Para obter somente a resposta:

~~~bash
dig +short empresa.test MX
dig +short mail.empresa.test A
~~~

O resultado esperado é equivalente a:

~~~text
10 mail.empresa.test.
192.168.50.10
~~~

---

## 6. Separe DNS de SMTP

Primeiro valide apenas o DNS:

~~~bash
dig mail.empresa.test
~~~

Depois valide apenas a conectividade SMTP usando o endereço:

~~~bash
nc 192.168.50.10 25
~~~

Encerre com:

~~~text
QUIT
~~~

Finalmente valide a integração nome + serviço:

~~~bash
nc mail.empresa.test 25
~~~

Esse raciocínio é importante:

~~~text
dig falha
→ investigar DNS

dig funciona + TCP/25 falha
→ investigar rede/porta/serviço

dig funciona + TCP/25 responde
→ avançar para comportamento SMTP
~~~

---

## 7. Envie usando o nome

No cliente:

~~~bash
nc mail.empresa.test 25
~~~

Use:

~~~text
EHLO cli.empresa.test
MAIL FROM:<alice@empresa.test>
RCPT TO:<bob@empresa.test>
DATA
Subject: DNS e SMTP integrados

Mensagem entregue utilizando o nome do servidor de correio.
.
QUIT
~~~

No servidor:

~~~bash
sudo find /home/bob/Maildir/new -maxdepth 1 -type f
~~~

---

## 8. Observe como domínios públicos anunciam correio

No cliente:

~~~bash
dig gmail.com MX
~~~

ou outro domínio indicado pelo professor.

Compare a existência de vários servidores e prioridades.

Não tentaremos enviar mensagens para a Internet nesta aula.

---

## 9. Ferramentas de diagnóstico e validação

### Configuração do BIND

~~~bash
sudo named-checkconf
~~~

### Zona

~~~bash
sudo named-checkzone empresa.test /etc/bind/db.empresa.test
~~~

### Consultas

~~~bash
dig empresa.test MX
dig mail.empresa.test A
~~~

### Resolução utilizada pelo cliente

~~~bash
resolvectl status lab0
getent hosts mail.empresa.test
~~~

### Serviço SMTP

~~~bash
systemctl is-active postfix
sudo ss -lntp | grep ':25'
~~~

### Configuração do Postfix

~~~bash
postconf myhostname
postconf mydomain
postconf mydestination
~~~

### Fila e logs

~~~bash
postqueue -p
sudo journalctl -u postfix -n 60 --no-pager
~~~

Cada ferramenta responde a uma pergunta diferente. Não trate falha de nome, falha de porta e rejeição SMTP como o mesmo problema.

---

## 10. Troubleshooting

O professor introduzirá uma inconsistência relacionada à integração DNS + SMTP.

O sintoma poderá ser semelhante a:

~~~text
O Postfix está ativo.
A porta 25 está aberta.
O cliente não consegue utilizar corretamente mail.empresa.test
para concluir a operação esperada.
~~~

Ou:

~~~text
O nome resolve, mas a mensagem para o domínio não segue o comportamento esperado.
~~~

Você deve localizar a camada responsável usando evidências.

Não será fornecida sequência de comandos.

---

## 11. Portfólio

Organize:

~~~text
email/aula-18/
├── README.md
└── zona-empresa.test.txt
~~~

O README deve conter:

~~~markdown
# Aula 18 — DNS e MX

## Registros
- A de mail:
- MX:
- prioridade:

## Fluxo
Explique como bob@empresa.test leva à descoberta de mail.empresa.test.

## Validações
- named-checkconf:
- named-checkzone:
- dig MX:
- dig A:
- TCP/25:
- entrega:

## Troubleshooting
### Sintoma
### Hipótese
### Testes e evidências
### Causa
### Correção
### Validação

## Síntese
Explique por que um MX correto não garante que o SMTP esteja funcionando.
~~~
