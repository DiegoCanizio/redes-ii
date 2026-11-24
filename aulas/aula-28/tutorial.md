# Aula 28 — Integração e comissionamento da infraestrutura

**Bloco de referência:** 100 minutos

## Objetivos

Ao final desta aula, você deverá conseguir:

- verificar uma infraestrutura como um conjunto de serviços dependentes;
- construir um checklist de aceite;
- validar serviços de ponta a ponta;
- identificar dependências entre DHCP, DNS, aplicações e firewall;
- registrar um estado funcional de referência.

## 1. Estado esperado

A infraestrutura deverá reunir, conforme orientação do professor:

~~~text
rede
DHCP
DNS
HTTP
FTP
SMTP
IMAP/POP3
TLS
firewall
proxy
~~~

## 2. Comissionamento

Valide na ordem:

~~~text
1. interfaces e endereçamento
2. DHCP
3. DNS
4. serviços locais
5. portas
6. aplicações
7. integração
8. firewall
9. proxy
10. logs
~~~

## 3. Checklist

### Rede

~~~text
[ ] servidor com endereço correto
[ ] cliente com configuração correta
[ ] conectividade
~~~

### DHCP/DNS

~~~text
[ ] lease
[ ] DNS entregue ao cliente
[ ] resolução direta
[ ] resolução reversa quando aplicável
[ ] MX
~~~

### Aplicações

~~~text
[ ] HTTP
[ ] FTP
[ ] SMTP
[ ] IMAP/POP3
[ ] TLS
~~~

### Controle

~~~text
[ ] firewall permite somente o necessário
[ ] proxy aplica ACL conforme requisito
~~~

## 4. Evidências

Para cada item, registre uma evidência objetiva: comando, resposta, log ou captura.

## 5. Portfólio

~~~text
integracao/aula-28/
└── comissionamento.md
~~~

Este documento será reutilizado como referência para a preparação da avaliação final.
