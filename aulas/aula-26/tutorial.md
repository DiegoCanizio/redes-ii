# Aula 26 — Análise de pacotes com tcpdump

**Bloco de referência:** 100 minutos

## Objetivos

Ao final desta aula, você deverá conseguir:

- escolher a interface de captura;
- criar filtros simples;
- observar TCP e UDP;
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

~~~bash
sudo tcpdump -ni lab0 -nn 'port 53'
~~~

No cliente:

~~~bash
dig @192.168.50.10 empresa.test
~~~

## 3. HTTP

~~~bash
sudo tcpdump -ni lab0 -nn 'tcp port 80'
~~~

No cliente:

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
sudo tcpdump -ni lab0 -nn   'tcp port 21 or portrange 40000-40010'
~~~

Observe mais de uma conexão.

## 6. IMAP/POP3 e TLS

~~~bash
sudo tcpdump -ni lab0 -nn -A   'tcp port 110 or tcp port 143'
~~~

Compare com:

~~~bash
sudo tcpdump -ni lab0 -nn   'tcp port 993 or tcp port 995'
~~~

## 7. Flags TCP

~~~bash
sudo tcpdump -ni lab0 -nn -vv 'tcp port 80'
~~~

Associe SYN, SYN/ACK, ACK, FIN e RST ao comportamento observado.

## 8. Salve uma captura

~~~bash
sudo tcpdump -ni lab0 -nn -c 100 -w ~/aula26-lab0.pcap
tcpdump -nn -r ~/aula26-lab0.pcap
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
qual protocolo/porta foi utilizado?
em que ponto a conversa parou?
~~~

## 10. Troubleshooting

O professor apresentará um cenário em que uma aplicação não funciona.

O aluno deverá usar tcpdump em conjunto com outras ferramentas para provar onde está a interrupção.

## 11. Portfólio

~~~text
pacotes/aula-26/
├── README.md
└── aula26-lab0.pcap
~~~
