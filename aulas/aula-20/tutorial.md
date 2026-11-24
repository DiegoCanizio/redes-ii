# Aula 20 — Sistema de e-mail integrado

## Objetivos

Ao final desta aula, você deverá conseguir:

- integrar DNS, SMTP, Maildir, IMAP e POP3;
- explicar o caminho completo de uma mensagem;
- validar cada camada separadamente;
- distinguir falha de resolução, transporte, entrega local e acesso à caixa postal;
- utilizar ferramentas de validação já conhecidas em sequência coerente;
- diagnosticar um incidente de integração sem receber um passo a passo.

## 1. Arquitetura completa

~~~text
cliente remetente
      │
      │ SMTP
      ▼
mail.empresa.test
      │
      ▼
    Postfix
      │
      ▼
Maildir do destinatário
      ▲
      │
      ├── IMAP4
      └── POP3
      │
cliente destinatário

DNS:
empresa.test MX mail.empresa.test
mail.empresa.test A 192.168.50.10
~~~

## 2. Verifique os serviços

No servidor:

~~~bash
systemctl is-active bind9
systemctl is-active postfix
systemctl is-active dovecot
sudo ss -lntup | grep -E ':(25|53|110|143)\b'
~~~

## 3. Valide o DNS

No cliente:

~~~bash
dig empresa.test MX
dig mail.empresa.test A
getent hosts mail.empresa.test
~~~

## 4. Valide o SMTP

~~~bash
nc mail.empresa.test 25
~~~

Envie uma mensagem curta para bob@empresa.test.

No servidor:

~~~bash
sudo find /home/bob/Maildir/new -maxdepth 1 -type f
~~~

## 5. Valide IMAP

~~~bash
nc mail.empresa.test 143
~~~

~~~text
a1 LOGIN bob SENHA_TEMPORARIA
a2 SELECT INBOX
a3 FETCH 1 BODY[]
a4 LOGOUT
~~~

## 6. Valide POP3

~~~bash
nc mail.empresa.test 110
~~~

~~~text
USER bob
PASS SENHA_TEMPORARIA
STAT
LIST
RETR 1
QUIT
~~~

## 7. Validação por camadas

~~~text
1. endereço/interface
2. DNS
3. serviço
4. porta
5. protocolo
6. entrega local
7. acesso à mailbox
8. logs
~~~

Ferramentas:

~~~bash
ip -br addr
resolvectl status lab0
dig
getent
systemctl
ss
nc
postqueue
find
journalctl
~~~

## 8. Ferramentas de diagnóstico e validação

DNS:

~~~bash
dig empresa.test MX
dig mail.empresa.test A
~~~

Postfix:

~~~bash
postconf -n
sudo postfix check
postqueue -p
sudo journalctl -u postfix -n 60 --no-pager
~~~

Dovecot:

~~~bash
sudo doveconf -n
sudo journalctl -u dovecot -n 60 --no-pager
~~~

Portas:

~~~bash
sudo ss -lntup | grep -E ':(25|53|110|143)\b'
~~~

Caixa postal:

~~~bash
sudo find /home/bob/Maildir -maxdepth 2 -type f
~~~

## 9. Troubleshooting

O professor introduzirá uma inconsistência em uma das camadas do sistema.

Você receberá apenas o comportamento observado.

Exemplo:

~~~text
O cliente resolve mail.empresa.test.
A conexão SMTP funciona.
A mensagem é aceita.
O usuário não consegue recuperá-la pelo IMAP.
~~~

Não suponha imediatamente que o problema está no Dovecot.

Use:

~~~text
Sintoma
→ Hipótese
→ Teste
→ Evidência
→ Causa
→ Correção
→ Validação
~~~

## 10. Portfólio

~~~text
email/aula-20/
└── README.md
~~~

Inclua:

~~~markdown
# Aula 20 — Sistema de e-mail integrado

## Arquitetura

## DNS
- MX:
- A:

## SMTP
- envio:
- entrega:

## IMAP
- acesso:
- leitura:

## POP3
- acesso:
- leitura:

## Validação por camadas

## Troubleshooting
### Sintoma
### Hipótese
### Testes e evidências
### Causa
### Correção
### Validação
~~~
