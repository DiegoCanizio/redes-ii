# Aula 29 — Checkpoint e preparação para a Avaliação 2

**Bloco de referência:** 100 minutos

## Objetivo

Verificar se você consegue operar, validar e diagnosticar a infraestrutura do segundo bloco sem receber um roteiro de correção.

Esta aula é um checkpoint, não uma nova apresentação de conteúdo.

## 1. Verificação inicial

Antes de alterar qualquer coisa, registre o estado:

~~~bash
ip -br addr
ip route
systemctl --failed
sudo ss -lntup
~~~

Depois execute as validações adequadas aos serviços que estiverem ativos.

## 2. Incidente controlado

O professor aplicará um ou mais incidentes.

Você receberá:

- o estado final esperado;
- os serviços que devem funcionar;
- eventuais restrições.

Você não receberá:

- a causa;
- o arquivo incorreto;
- o comando de correção.

## 3. Método

~~~text
Sintoma
→ Hipótese
→ Teste
→ Evidência
→ Causa
→ Correção
→ Validação
~~~

## 4. Autoavaliação

~~~text
[ ] Consigo validar rede antes de investigar aplicação.
[ ] Consigo separar DNS de serviço.
[ ] Consigo testar uma porta explicitamente.
[ ] Consigo ler logs.
[ ] Consigo validar Postfix e Dovecot.
[ ] Consigo validar nftables antes de aplicar.
[ ] Consigo interpretar ACL do Squid.
[ ] Consigo usar tcpdump para comprovar uma hipótese.
[ ] Consigo documentar causa, correção e validação.
~~~

## 5. Registro

~~~text
checkpoint/aula-29/
└── README.md
~~~

Documente o incidente e a validação final.

A avaliação será apresentada separadamente.
