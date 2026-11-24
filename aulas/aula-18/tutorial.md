# Aula 18 — SMTP por dentro e primeira configuração do Postfix

**Bloco de referência:** 100 minutos

## Objetivos

Ao final desta aula, você deverá conseguir:

- explicar o papel do SMTP;
- diferenciar MUA, MTA e armazenamento da caixa postal;
- instalar e configurar um Postfix para entrega local;
- realizar uma sessão SMTP manual;
- interpretar respostas básicas do protocolo;
- confirmar a entrega em Maildir;
- utilizar serviço, porta, fila e logs no diagnóstico.

## 1. Arquitetura inicial

~~~text
cliente
  │
  │ SMTP / TCP 25
  ▼
Postfix
  │
  ▼
Maildir do destinatário
~~~

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

## 3. Crie usuários e Maildir

~~~bash
sudo adduser alice
sudo adduser bob
sudo -u alice mkdir -p /home/alice/Maildir/{cur,new,tmp}
sudo -u bob mkdir -p /home/bob/Maildir/{cur,new,tmp}
~~~

Use senhas temporárias.

## 4. Configure o Postfix

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

Observe:

~~~bash
postconf -n
~~~

## 5. Valide antes de reiniciar

~~~bash
sudo postfix check
sudo systemctl restart postfix
systemctl is-active postfix
sudo ss -lntp | grep ':25'
~~~

## 6. Faça uma sessão SMTP manual

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
Subject: Primeiro teste SMTP
From: alice@empresa.test
To: bob@empresa.test

Mensagem enviada manualmente.
.
QUIT
~~~

Respostas comuns:

~~~text
220 serviço pronto
250 operação aceita
354 aguardando conteúdo
221 encerramento
~~~

## 7. Confirme a entrega

~~~bash
sudo find /home/bob/Maildir/new -maxdepth 1 -type f -printf '%f\n'
~~~

Leia uma mensagem indicada pelo professor.

## 8. Fila e logs

~~~bash
postqueue -p
sudo journalctl -u postfix -n 60 --no-pager
~~~

## 9. Ferramentas de diagnóstico e validação

~~~bash
postconf -n
sudo postfix check
systemctl is-active postfix
sudo ss -lntp | grep ':25'
nc 192.168.50.10 25
postqueue -p
sudo journalctl -u postfix -n 60 --no-pager
sudo find /home/bob/Maildir -maxdepth 2 -type f
~~~

## 10. Troubleshooting

Exemplo:

~~~text
TCP/25 responde.
O remetente é aceito.
O destinatário local é rejeitado.
~~~

O aluno deve localizar a causa usando evidências.

## 11. Portfólio

~~~text
email/aula-18/
├── README.md
└── postfix-parametros.txt
~~~

Gere postfix-parametros.txt com postconf -n e documente sessão, fila, logs e troubleshooting.