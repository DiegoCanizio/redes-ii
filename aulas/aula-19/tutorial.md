# Aula 19 — POP3 e IMAP4 com Dovecot

## Objetivos

Ao final desta aula, você deverá conseguir:

- explicar a diferença de função entre SMTP e os protocolos de acesso à caixa postal;
- configurar Dovecot utilizando Maildir;
- disponibilizar IMAP4 em TCP/143;
- disponibilizar POP3 em TCP/110;
- realizar autenticação e leitura manual de mensagens;
- comparar o comportamento básico de IMAP e POP3;
- utilizar logs, portas e estado da Maildir no diagnóstico;
- diagnosticar um incidente de acesso à caixa postal.

Nesta aula as credenciais trafegarão sem TLS apenas dentro da rede isolada do laboratório. A proteção será adicionada posteriormente.

---

## 1. Arquitetura

O SMTP já entrega a mensagem.

Agora adicionaremos acesso remoto à caixa postal:

~~~text
remetente
   │
   │ SMTP
   ▼
 Postfix
   │
   ▼
Maildir de bob
   ▲
   │
   ├── IMAP4 TCP/143
   │
   └── POP3  TCP/110
   │
 cliente
~~~

SMTP envia/transporta mensagens.

IMAP e POP3 permitem acesso às mensagens armazenadas.

---

## 2. Prepare o estado anterior

No servidor:

~~~bash
systemctl is-active postfix
postconf home_mailbox
sudo find /home/bob/Maildir -maxdepth 2 -type f
~~~

Garanta que bob possua pelo menos uma mensagem na Maildir.

Caso necessário, envie uma nova mensagem pelo SMTP como praticado anteriormente.

---

## 3. Instale o Dovecot

Servidor:

~~~bash
sudo apt update
sudo apt install -y dovecot-core dovecot-imapd dovecot-pop3d tcpdump
~~~

Observe:

~~~bash
systemctl status dovecot --no-pager
~~~

---

## 4. Habilite os protocolos

Edite:

~~~bash
sudo nano /etc/dovecot/dovecot.conf
~~~

Garanta:

~~~conf
protocols = imap pop3
~~~

---

## 5. Configure Maildir

Edite:

~~~bash
sudo nano /etc/dovecot/conf.d/10-mail.conf
~~~

Defina:

~~~conf
mail_location = maildir:~/Maildir
~~~

---

## 6. Permita autenticação em claro somente no laboratório

Edite:

~~~bash
sudo nano /etc/dovecot/conf.d/10-auth.conf
~~~

Para esta etapa controlada:

~~~conf
disable_plaintext_auth = no
auth_mechanisms = plain login
~~~

Não trate essa configuração como adequada para uma rede não confiável.

---

## 7. Valide a configuração

Antes de reiniciar:

~~~bash
sudo doveconf -n
~~~

Revise a saída.

Depois:

~~~bash
sudo systemctl restart dovecot
~~~

Confirme:

~~~bash
systemctl is-active dovecot
sudo ss -lntp | grep -E ':(110|143)'
~~~

---

## 8. Teste IMAP4

No cliente:

~~~bash
nc 192.168.50.10 143
~~~

Digite:

~~~text
a1 LOGIN bob SENHA_TEMPORARIA
a2 SELECT INBOX
a3 FETCH 1 BODY[]
a4 LOGOUT
~~~

Observe que os comandos IMAP utilizam identificadores como a1, a2 e a3.

Registre:

- a autenticação funcionou?
- quantas mensagens a caixa informou?
- a mensagem pôde ser lida?

---

## 9. Teste POP3

No cliente:

~~~bash
nc 192.168.50.10 110
~~~

Digite:

~~~text
USER bob
PASS SENHA_TEMPORARIA
STAT
LIST
RETR 1
QUIT
~~~

Registre:

- quantidade de mensagens;
- tamanho informado;
- conteúdo recuperado.

Não conclua que POP3 sempre remove mensagens. A remoção depende dos comandos executados e do comportamento do cliente.

---

## 10. Observe as credenciais na rede

No servidor:

~~~bash
sudo tcpdump -ni lab0 -nn -A   'tcp port 110 or tcp port 143'
~~~

No cliente, repita uma autenticação utilizando somente a senha temporária.

Observe o tráfego.

Isso prepara a motivação para TLS.

---

## 11. Compare IMAP e POP3

Registre:

| Aspecto | IMAP4 | POP3 |
|---|---|---|
| Porta desta aula | 143 | 110 |
| Acessa caixa remota | | |
| Permite selecionar mailbox | | |
| Permite recuperar mensagem | | |
| Credenciais protegidas nesta etapa | | |

A comparação deve ser baseada no que você observou, não apenas em definições memorizadas.

---

## 12. Ferramentas de diagnóstico e validação

### Configuração efetiva

~~~bash
sudo doveconf -n
~~~

### Serviço

~~~bash
systemctl status dovecot --no-pager
systemctl is-active dovecot
~~~

### Portas

~~~bash
sudo ss -lntp | grep -E ':(110|143)'
~~~

### Logs

~~~bash
sudo journalctl -u dovecot -n 60 --no-pager
~~~

### Caixa postal

~~~bash
sudo find /home/bob/Maildir -maxdepth 2 -type f
~~~

### Usuário

~~~bash
id bob
sudo ls -ld /home/bob /home/bob/Maildir
~~~

### Protocolo

~~~bash
nc 192.168.50.10 143
nc 192.168.50.10 110
~~~

### Tráfego

~~~bash
sudo tcpdump -ni lab0 -nn -A   'tcp port 110 or tcp port 143'
~~~

As ferramentas permitem separar:

~~~text
porta inacessível
≠
serviço com erro
≠
falha de autenticação
≠
caixa postal ausente/incorreta
~~~

---

## 13. Troubleshooting

O professor introduzirá uma falha relacionada ao acesso à caixa postal.

Exemplos de sintomas possíveis:

~~~text
A porta responde, mas o login falha.
~~~

ou:

~~~text
O SMTP entrega a mensagem, mas o usuário não a encontra no IMAP.
~~~

Você não receberá o arquivo responsável nem a sequência de testes.

Use evidências para localizar a causa.

---

## 14. Portfólio

Organize:

~~~text
email/aula-19/
├── README.md
└── dovecot-config.txt
~~~

No servidor:

~~~bash
sudo doveconf -n > ~/dovecot-config.txt
~~~

O README deve conter:

~~~markdown
# Aula 19 — POP3 e IMAP4

## Arquitetura
Como Postfix, Maildir e Dovecot se relacionam?

## IMAP4
- porta:
- comandos utilizados:
- resultado:

## POP3
- porta:
- comandos utilizados:
- resultado:

## Captura
O que foi observado antes de TLS?

## Ferramentas de diagnóstico
Quais perguntas cada ferramenta responde?

## Troubleshooting
### Sintoma
### Hipótese
### Testes e evidências
### Causa
### Correção
### Validação
~~~

Não registre a senha de laboratório no repositório.
