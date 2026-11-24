# Aula 19 — Postfix, DNS e registros MX

**Bloco de referência:** 100 minutos

## Objetivos

Ao final desta aula, você deverá conseguir:

- explicar o papel do registro MX;
- publicar mail.empresa.test no DNS;
- criar e validar o MX de empresa.test;
- relacionar DNS e SMTP sem confundir suas funções;
- validar nome, porta, Postfix, fila e entrega separadamente;
- diagnosticar uma inconsistência entre DNS e correio eletrônico.

## 1. Fluxo esperado

~~~text
bob@empresa.test
      │
      ▼
empresa.test MX 10 mail.empresa.test.
      │
      ▼
mail.empresa.test A 192.168.50.10
      │
      ▼
TCP/25 → Postfix
~~~

## 2. Verifique o estado inicial

Servidor:

~~~bash
ip -4 -br addr show lab0
systemctl is-active bind9
systemctl is-active postfix
sudo ss -lntup | grep -E ':(25|53)$|:(25|53)[[:space:]]'
~~~

Cliente:

~~~bash
resolvectl status lab0
dig empresa.test
~~~

## 3. Adicione os registros

~~~bash
sudo nano /etc/bind/db.empresa.test
~~~

Adicione:

~~~dns
mail    IN  A   192.168.50.10
@       IN  MX  10 mail.empresa.test.
~~~

Atualize o serial SOA.

## 4. Valide antes de recarregar

~~~bash
sudo named-checkconf
sudo named-checkzone empresa.test /etc/bind/db.empresa.test
sudo systemctl reload bind9
~~~

## 5. Consulte o MX

~~~bash
dig empresa.test MX
dig mail.empresa.test A
dig +short empresa.test MX
dig +short mail.empresa.test A
~~~

Esperado:

~~~text
10 mail.empresa.test.
192.168.50.10
~~~

## 6. Separe DNS de SMTP

~~~bash
dig mail.empresa.test
nc -vz 192.168.50.10 25
nc -vz mail.empresa.test 25
~~~

Interprete:

~~~text
dig falha → investigar DNS
dig funciona + TCP/25 falha → rede, firewall, porta ou serviço
dig funciona + TCP/25 responde → avançar para SMTP
~~~

## 7. Envie usando o nome

~~~bash
nc mail.empresa.test 25
~~~

Envie uma mensagem para bob@empresa.test e confirme a Maildir.

## 8. Observe um domínio público

~~~bash
dig gmail.com MX
~~~

Observe prioridades e múltiplos servidores. Não será realizado envio externo.

## 9. Ferramentas de diagnóstico e validação

~~~bash
sudo named-checkconf
sudo named-checkzone empresa.test /etc/bind/db.empresa.test
dig empresa.test MX
dig mail.empresa.test A
getent hosts mail.empresa.test
postconf myhostname
postconf mydomain
postconf mydestination
sudo postfix check
systemctl is-active postfix
sudo ss -lntp | grep ':25'
postqueue -p
sudo journalctl -u postfix -n 60 --no-pager
~~~

## 10. Troubleshooting

Possíveis sintomas:

~~~text
mail.empresa.test não resolve
o nome resolve, mas TCP/25 não responde
DNS e porta funcionam, mas a mensagem não chega
~~~

O aluno deve localizar a camada responsável usando evidências.

## 11. Portfólio

~~~text
email/aula-19/
└── README.md
~~~

Documente A, MX, prioridade, consultas, TCP/25, entrega e troubleshooting.