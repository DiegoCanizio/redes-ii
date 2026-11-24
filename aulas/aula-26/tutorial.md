# Aula 26 — Laboratório integrado

## Missão

Nesta aula você não receberá um roteiro de configuração passo a passo.

O objetivo é operar uma infraestrutura composta pelos serviços trabalhados no segundo bloco.

Você pode consultar tutoriais anteriores, portfólio, manuais, --help e documentação.

## Estado final esperado

Conforme a especificação do professor, o ambiente poderá envolver:

~~~text
rede
DHCP
DNS
HTTP
FTP
SMTP
IMAP/POP3
TLS aplicado ao correio
firewall
proxy
~~~

## Validação mínima

Rede:
~~~text
[ ] servidor com endereço esperado
[ ] cliente com configuração esperada
[ ] comunicação funcional
~~~

DNS:
~~~text
[ ] zona direta
[ ] zona reversa quando aplicável
[ ] A
[ ] MX
~~~

Web:
~~~text
[ ] Nginx ativo
[ ] nome resolve
[ ] HTTP responde
~~~

FTP:
~~~text
[ ] autenticação
[ ] listagem
[ ] download
[ ] upload
~~~

E-mail:
~~~text
[ ] SMTP
[ ] entrega local
[ ] IMAP ou POP3
[ ] TLS
~~~

Firewall/proxy:
~~~text
[ ] serviços necessários permitidos
[ ] acesso não autorizado bloqueado
[ ] proxy/ACL funcionando quando exigido
~~~

## Ferramentas disponíveis

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

## Método

~~~text
Sintoma
→ Hipótese
→ Teste
→ Evidência
→ Causa
→ Correção
→ Validação
~~~

## Registro

~~~text
integracao/aula-26/
└── README.md
~~~

Documente incidentes relevantes e o estado final validado.

Este laboratório prepara a avaliação final.
