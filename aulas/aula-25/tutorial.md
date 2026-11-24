# Aula 25 — Análise de pacotes com tcpdump

## Objetivos

Ao final desta aula, você deverá conseguir:

- escolher interface de captura;
- aplicar filtros simples;
- observar conexões TCP e tráfego UDP;
- relacionar pacotes aos serviços estudados;
- identificar em qual etapa uma comunicação deixa de progredir;
- salvar capturas;
- utilizar tcpdump como ferramenta de troubleshooting.

## 1. Interface

~~~bash
ip -br link
sudo tcpdump -ni lab0
~~~

## 2. DNS

Servidor:

~~~bash
sudo tcpdump -ni lab0 -nn 'port 53'
~~~

Cliente:

~~~bash
dig @192.168.50.10 empresa.test
~~~

## 3. HTTP

~~~bash
sudo tcpdump -ni lab0 -nn 'tcp port 80'
~~~

Cliente:

~~~bash
curl http://www.empresa.test/
~~~

## 4. SMTP

~~~bash
sudo tcpdump -ni lab0 -nn -A 'tcp port 25'
~~~

Faça uma sessão curta.

## 5. FTP

~~~bash
sudo tcpdump -ni lab0 -nn 'tcp port 21 or portrange 40000-40010'
~~~

Observe mais de uma conexão.

## 6. IMAP e POP3

~~~bash
sudo tcpdump -ni lab0 -nn -A 'tcp port 110 or tcp port 143'
~~~

Compare com TLS:

~~~bash
sudo tcpdump -ni lab0 -nn 'tcp port 993 or tcp port 995'
~~~

## 7. Flags TCP

~~~bash
sudo tcpdump -ni lab0 -nn -vv 'tcp port 80'
~~~

Associe S, S., F e R a SYN, SYN/ACK, FIN e RST.

## 8. Salve uma captura

~~~bash
sudo tcpdump -ni lab0 -nn -c 100 -w ~/aula25-lab0.pcap
tcpdump -nn -r ~/aula25-lab0.pcap
~~~

## 9. Ferramentas de diagnóstico e validação

Combine tcpdump com:

~~~bash
ip -br addr
ip route
ip neigh
ss -lntup
systemctl
journalctl
dig
curl
nc
openssl s_client
nft
~~~

O tcpdump responde principalmente:

~~~text
o pacote saiu?
o pacote chegou?
houve resposta?
qual protocolo/porta?
em que ponto a conversa parou?
~~~

## 10. Troubleshooting

O professor apresentará um cenário em que uma aplicação não funciona.

O aluno deverá usar tcpdump em conjunto com outras ferramentas para provar onde está a interrupção.

Não haverá roteiro de solução.

## 11. Portfólio

~~~text
pacotes/aula-25/
├── README.md
└── aula25-lab0.pcap
~~~

Registre filtros, evidências, interpretação e troubleshooting.
