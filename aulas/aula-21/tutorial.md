# Aula 21 — Sistema de e-mail integrado

**Bloco de referência:** 100 minutos

## Objetivos

Ao final desta aula, você deverá conseguir:

- integrar DNS, MX, SMTP, Maildir, IMAP e POP3;
- explicar o caminho completo de uma mensagem;
- validar cada camada separadamente;
- distinguir falha de resolução, transporte, entrega local e acesso à caixa postal;
- utilizar ferramentas de diagnóstico em sequência coerente;
- diagnosticar um incidente integrado.

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
empresa.test MX 10 mail.empresa.test.
mail.empresa.test A 192.168.50.10
~~~

## 2. Verifique os serviços

~~~bash
systemctl is-active bind9
systemctl is-active postfix
systemctl is-active dovecot
sudo ss -lntup
~~~

## 3. Valide DNS

~~~bash
dig empresa.test MX
dig mail.empresa.test A
getent hosts mail.empresa.test
~~~

## 4. Valide SMTP e entrega

~~~bash
nc mail.empresa.test 25
~~~

Envie uma mensagem para bob@empresa.test.

No servidor:

~~~bash
sudo find /home/bob/Maildir/new -maxdepth 1 -type f
~~~

## 5. Valide o acesso à caixa

IMAP:

~~~bash
nc mail.empresa.test 143
~~~

POP3:

~~~bash
nc mail.empresa.test 110
~~~

Utilize os comandos praticados na Aula 20.

## 6. Validação por camadas

~~~text
1. endereço/interface
2. DNS
3. serviço
4. porta
5. protocolo
6. entrega local
7. Maildir
8. acesso à caixa
9. logs
~~~

## 7. Ferramentas de diagnóstico e validação

~~~bash
ip -br addr
resolvectl status lab0
dig
getent
systemctl
ss
nc
postconf -n
postfix check
postqueue -p
doveconf -n
find
journalctl
~~~

O objetivo é sempre responder a uma pergunta técnica específica.

## 8. Troubleshooting integrado

O professor introduzirá uma inconsistência em uma das camadas.

Exemplo:

~~~text
mail.empresa.test resolve.
TCP/25 responde.
A mensagem é aceita.
O usuário não consegue recuperá-la pelo IMAP.
~~~

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

## 9. Portfólio

~~~text
email/aula-21/
└── README.md
~~~

Documente o fluxo completo, validações por camada e troubleshooting.
