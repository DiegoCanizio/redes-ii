# Aula 24 — Firewall aplicado e troubleshooting

**Bloco de referência:** 100 minutos

## Objetivos

Ao final desta aula, você deverá conseguir:

- transformar requisitos em regras de firewall;
- restringir acesso por origem;
- interpretar ordem e prioridade de regras;
- testar portas permitidas e bloqueadas;
- utilizar ruleset, contadores, tcpdump e testes de aplicação;
- diagnosticar falhas de filtragem sem roteiro de correção.

## 1. Estado inicial

~~~bash
sudo nft list ruleset
sudo ss -lntup
~~~

## 2. Regras por origem

Exemplo:

~~~nft
ip saddr 192.168.50.0/24 tcp dport 80 accept
~~~

A regra combina origem, protocolo, porta e ação.

## 3. Ordem das regras

~~~bash
sudo nft -a list chain inet filter input
~~~

Leia de cima para baixo.

## 4. Testes controlados

~~~bash
nc -vz 192.168.50.10 22
nc -vz 192.168.50.10 25
nc -vz 192.168.50.10 80
nc -vz 192.168.50.10 993
~~~

Compare com:

~~~bash
sudo ss -lntup
~~~

Uma porta em LISTEN não garante acesso remoto.

## 5. Observe o tráfego

Servidor:

~~~bash
sudo tcpdump -ni lab0 tcp port 80
~~~

Cliente:

~~~bash
curl -v http://192.168.50.10/
~~~

## 6. Ferramentas de diagnóstico e validação

~~~bash
sudo nft -c -f /etc/nftables.conf
sudo nft -a list ruleset
sudo ss -lntup
systemctl is-active NOME
nc -vz 192.168.50.10 PORTA
curl -v URL
dig @192.168.50.10 NOME
sudo tcpdump -ni lab0 FILTRO
~~~

Os validadores específicos dos serviços continuam válidos.

## 7. Troubleshooting

O professor aplicará um ou mais incidentes.

Serão fornecidas as funcionalidades esperadas, não a regra incorreta.

Use o método da disciplina e registre evidências.

## 8. Portfólio

~~~text
firewall/aula-24/
└── README.md
~~~
