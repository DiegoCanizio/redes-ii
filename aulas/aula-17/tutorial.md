# Aula 17 — SMTP e Postfix

## Objetivos

Ao final desta aula, você deverá conseguir:

- explicar o papel do SMTP na arquitetura de correio eletrônico;
- diferenciar MUA, MTA e caixa postal;
- configurar um Postfix para entrega local no domínio empresa.test;
- realizar uma sessão SMTP manual;
- interpretar códigos básicos de resposta SMTP;
- consultar configuração efetiva, fila e logs;
- validar uma entrega até a Maildir;
- diagnosticar um incidente relacionado ao serviço SMTP.

Nesta etapa o foco é o SMTP. POP3 e IMAP serão adicionados posteriormente.

---

## 1. Arquitetura inicial

~~~text
cliente
  │
  │ SMTP
  │ TCP/25
  ▼
Postfix
  │
  ▼
Maildir do usuário
~~~

Termos:

~~~text
MUA → programa utilizado pelo usuário para lidar com mensagens
MTA → servidor responsável por transportar/entregar mensagens
Maildir → formato de armazenamento da caixa postal
~~~

Nesta aula o Postfix atua como MTA.

---

## 2. Instale as ferramentas

Servidor:

~~~bash
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y postfix
~~~

Cliente:

~~~bash
sudo apt update
sudo apt install -y netcat-openbsd
~~~

Confirme no servidor:

~~~bash
systemctl status postfix --no-pager
sudo ss -lntp | grep ':25'
~~~

---

## 3. Crie usuários de laboratório

Servidor:

~~~bash
sudo adduser alice
sudo adduser bob
~~~

Utilize senhas temporárias de laboratório.

Prepare a Maildir:

~~~bash
sudo -u alice mkdir -p /home/alice/Maildir/{cur,new,tmp}
sudo -u bob mkdir -p /home/bob/Maildir/{cur,new,tmp}
~~~

---

## 4. Configure o Postfix

Aplique:

~~~bash
sudo postconf -e 'myhostname = mail.empresa.test'
sudo postconf -e 'mydomain = empresa.test'
sudo postconf -e 'myorigin = $mydomain'
sudo postconf -e 'inet_interfaces = all'
sudo postconf -e 'inet_protocols = ipv4'
sudo postconf -e 'mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain'
sudo postconf -e 'mynetworks = 127.0.0.0/8, 192.168.50.0/24'
sudo postconf -e 'home_mailbox = Maildir/'
~~~

Observe a configuração efetiva:

~~~bash
postconf -n
~~~

Consulte individualmente:

~~~bash
postconf myhostname
postconf mydomain
postconf mydestination
postconf mynetworks
postconf home_mailbox
~~~

---

## 5. Valide antes de reiniciar

~~~bash
sudo postfix check
~~~

Se não houver erro:

~~~bash
sudo systemctl restart postfix
~~~

Depois:

~~~bash
systemctl is-active postfix
sudo ss -lntp | grep ':25'
~~~

---

## 6. Converse manualmente com o SMTP

No cliente:

~~~bash
nc 192.168.50.10 25
~~~

Digite:

~~~text
EHLO cli.empresa.test
MAIL FROM:<alice@empresa.test>
RCPT TO:<bob@empresa.test>
DATA
Subject: Teste SMTP
From: alice@empresa.test
To: bob@empresa.test

Mensagem enviada manualmente durante a aula.
.
QUIT
~~~

Observe os códigos retornados.

Códigos que devem aparecer em uma sessão normal:

~~~text
220 → serviço pronto
250 → operação aceita
354 → servidor aguardando o conteúdo da mensagem
221 → encerramento da sessão
~~~

---

## 7. Confirme a entrega

No servidor:

~~~bash
sudo find /home/bob/Maildir/new -maxdepth 1 -type f -printf '%f
'
~~~

Escolha uma mensagem e leia as primeiras linhas:

~~~bash
sudo sed -n '1,80p' /home/bob/Maildir/new/ARQUIVO
~~~

Neste momento nenhum POP3 ou IMAP foi necessário.

O Postfix recebeu a mensagem por SMTP e realizou a entrega local.

---

## 8. Observe a fila

~~~bash
postqueue -p
~~~

Em situação normal de entrega local imediata, a fila tende a estar vazia.

Também conheça:

~~~bash
mailq
~~~

---

## 9. Observe os logs

~~~bash
sudo journalctl -u postfix -n 60 --no-pager
~~~

Quando disponível no sistema:

~~~bash
sudo tail -n 60 /var/log/mail.log
~~~

Procure informações relacionadas a:

~~~text
conexão
remetente
destinatário
queue ID
entrega
status
~~~

---

## 10. Ferramentas de diagnóstico e validação

### Configuração efetiva

~~~bash
postconf -n
~~~

Pergunta: quais valores diferem dos padrões do Postfix?

### Validação

~~~bash
sudo postfix check
~~~

Pergunta: a configuração apresenta inconsistência estrutural conhecida pelo Postfix?

### Serviço e porta

~~~bash
systemctl is-active postfix
sudo ss -lntp | grep ':25'
~~~

Pergunta: o serviço está ativo e aceitando conexões SMTP?

### Sessão SMTP

~~~bash
nc 192.168.50.10 25
~~~

Pergunta: a rede, a porta e o protocolo estão funcionando até qual etapa?

### Fila

~~~bash
postqueue -p
~~~

Pergunta: a mensagem foi entregue ou permaneceu pendente?

### Logs

~~~bash
sudo journalctl -u postfix -n 60 --no-pager
~~~

Pergunta: qual decisão o MTA tomou para a mensagem?

### Caixa postal

~~~bash
sudo find /home/bob/Maildir -maxdepth 2 -type f
~~~

Pergunta: a mensagem chegou ao armazenamento final?

---

## 11. Troubleshooting

O professor introduzirá uma inconsistência no ambiente SMTP.

Você receberá o sintoma, não a causa.

Exemplos de comportamento que podem ser observados:

~~~text
TCP/25 responde, mas um destinatário local é rejeitado.
ou
A mensagem é aceita, mas não aparece na Maildir esperada.
~~~

A correção não deve ser feita por tentativa aleatória.

Registre:

~~~text
Sintoma
→ Hipótese
→ Teste
→ Evidência
→ Causa
→ Correção
→ Validação
~~~

---

## 12. Portfólio

Organize:

~~~text
email/aula-17/
├── README.md
└── postfix-parametros.txt
~~~

Gere:

~~~bash
postconf -n > ~/postfix-parametros.txt
~~~

O README deve conter:

~~~markdown
# Aula 17 — SMTP e Postfix

## Arquitetura
- MUA:
- MTA:
- Maildir:

## Parâmetros
- myhostname:
- mydomain:
- mydestination:
- mynetworks:
- home_mailbox:

## Sessão SMTP
- porta:
- comandos:
- códigos observados:

## Validação
- postfix check:
- serviço:
- porta:
- entrega:
- fila:
- logs:

## Troubleshooting
### Sintoma
### Hipótese
### Testes e evidências
### Causa
### Correção
### Validação
~~~

Não versione senhas ou outros segredos.
