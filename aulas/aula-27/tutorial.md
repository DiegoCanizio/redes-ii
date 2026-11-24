# Aula 27 — Troubleshooting integrado de serviços

**Bloco de referência:** 100 minutos

## Missão

Você receberá um ambiente com serviços já estudados e um ou mais comportamentos incorretos.

Nesta aula não haverá passo a passo de correção.

As ferramentas de diagnóstico e validação continuam disponíveis nos tutoriais anteriores.

## Componentes possíveis

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

## Regra principal

Não corrija antes de produzir evidência suficiente para sustentar a hipótese.

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

## Ferramentas de referência

~~~bash
ip
ping
ip neigh
systemctl
ss
journalctl
kea-dhcp4 -t
dig
named-checkconf
named-checkzone
resolvectl
nginx -t
curl
lftp
postfix check
postconf
postqueue
doveconf
nc
openssl s_client
nft
squid -k parse
tcpdump
~~~

## Entrega

~~~text
integracao/aula-27/
└── README.md
~~~

Para cada incidente, documente sintoma, hipótese, testes, evidências, causa, correção e validação.
