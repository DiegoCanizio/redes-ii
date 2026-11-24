# Aula 21 — TLS aplicado ao correio eletrônico

## Objetivos

Ao final desta aula, você deverá conseguir:

- explicar por que as credenciais observadas anteriormente precisam de proteção;
- gerar um certificado de laboratório;
- configurar TLS no Postfix;
- configurar TLS no Dovecot;
- validar SMTP com STARTTLS;
- validar IMAPS e POP3S;
- utilizar `openssl s_client` para observar a negociação TLS;
- diagnosticar falhas básicas de certificado, porta e configuração.

O foco é TLS aplicado aos serviços já estudados, não um módulo separado de segurança.

## 1. Situação anterior

~~~text
SMTP  → STARTTLS
IMAP  → IMAPS
POP3  → POP3S
~~~

## 2. Gere um certificado

~~~bash
sudo openssl req -x509 -newkey rsa:2048 -nodes   -keyout /etc/ssl/private/mail.empresa.test.key   -out /etc/ssl/certs/mail.empresa.test.crt   -days 30   -subj "/CN=mail.empresa.test"   -addext "subjectAltName=DNS:mail.empresa.test"
sudo chmod 600 /etc/ssl/private/mail.empresa.test.key
~~~

Observe:

~~~bash
openssl x509 -in /etc/ssl/certs/mail.empresa.test.crt   -noout -subject -issuer -dates -ext subjectAltName
~~~

## 3. Configure o Postfix

~~~bash
sudo postconf -e 'smtpd_tls_cert_file = /etc/ssl/certs/mail.empresa.test.crt'
sudo postconf -e 'smtpd_tls_key_file = /etc/ssl/private/mail.empresa.test.key'
sudo postconf -e 'smtpd_tls_security_level = may'
sudo postfix check
sudo systemctl restart postfix
~~~

## 4. Configure o Dovecot

Em `/etc/dovecot/conf.d/10-ssl.conf`:

~~~conf
ssl = required
ssl_cert = </etc/ssl/certs/mail.empresa.test.crt
ssl_key = </etc/ssl/private/mail.empresa.test.key
~~~

Em `10-auth.conf`:

~~~conf
disable_plaintext_auth = yes
~~~

Valide:

~~~bash
sudo doveconf -n
sudo systemctl restart dovecot
~~~

## 5. Verifique portas

~~~bash
sudo ss -lntp | grep -E ':(25|993|995)\b'
~~~

## 6. SMTP com STARTTLS

~~~bash
openssl s_client   -connect mail.empresa.test:25   -starttls smtp   -servername mail.empresa.test
~~~

Após o handshake:

~~~text
EHLO cli.empresa.test
QUIT
~~~

## 7. IMAPS

~~~bash
openssl s_client   -connect mail.empresa.test:993   -servername mail.empresa.test
~~~

## 8. POP3S

~~~bash
openssl s_client   -connect mail.empresa.test:995   -servername mail.empresa.test
~~~

## 9. Confiança do certificado

O certificado é autoassinado.

~~~text
TLS funcionando
≠
certificado confiável por uma CA pública
~~~

## 10. Ferramentas de diagnóstico e validação

~~~bash
openssl x509 -in /etc/ssl/certs/mail.empresa.test.crt -noout -text
postconf | grep tls
sudo postfix check
sudo journalctl -u postfix -n 60 --no-pager
sudo doveconf -n | grep -E 'ssl|auth'
sudo journalctl -u dovecot -n 60 --no-pager
sudo ss -lntp | grep -E ':(25|993|995)\b'
openssl s_client -connect mail.empresa.test:993 -servername mail.empresa.test
~~~

## 11. Troubleshooting

O professor introduzirá uma inconsistência relacionada a TLS.

Possíveis sintomas:

~~~text
A porta está aberta, mas o handshake falha.
O serviço apresenta certificado diferente do esperado.
SMTP funciona sem TLS, mas STARTTLS não é anunciado corretamente.
~~~

O aluno deve localizar a causa usando evidências.

## 12. Portfólio

~~~text
email/aula-21/
└── README.md
~~~

Inclua certificado, portas, evidências de STARTTLS/IMAPS/POP3S, confiança e troubleshooting.

Não versione a chave privada.
