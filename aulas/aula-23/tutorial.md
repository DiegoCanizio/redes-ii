# Aula 23 — Firewall com nftables

**Bloco de referência:** 100 minutos

## Objetivos

Ao final desta aula, você deverá conseguir:

- explicar o papel de um firewall no host;
- identificar serviços e portas necessários;
- criar uma política básica com nftables;
- permitir conexões estabelecidas;
- liberar serviços explicitamente;
- validar regras antes de aplicar;
- distinguir falha de serviço de bloqueio por firewall.

## 1. Observe os serviços

~~~bash
sudo ss -lntup
~~~

Relacione serviço e porta já estudados.

## 2. Instale

~~~bash
sudo apt update
sudo apt install -y nftables
sudo nft list ruleset
~~~

## 3. Faça backup

~~~bash
sudo cp /etc/nftables.conf /etc/nftables.conf.original
~~~

## 4. Crie uma política inicial

~~~nft
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0;
        policy drop;

        iif "lo" accept
        ct state established,related accept
        ip protocol icmp accept
        tcp dport 22 accept
    }

    chain forward {
        type filter hook forward priority 0;
        policy drop;
    }

    chain output {
        type filter hook output priority 0;
        policy accept;
    }
}
~~~

## 5. Valide antes de aplicar

~~~bash
sudo nft -c -f /etc/nftables.conf
~~~

Depois:

~~~bash
sudo systemctl restart nftables
sudo nft list ruleset
~~~

## 6. Libere os serviços necessários

Conforme o ambiente, acrescente regras para DNS, HTTP, SMTP, IMAP/POP3 e variantes TLS.

Valide novamente antes de aplicar.

## 7. Teste do cliente

Exemplos:

~~~bash
dig @192.168.50.10 empresa.test
curl -I http://192.168.50.10/
nc -vz 192.168.50.10 25
nc -vz 192.168.50.10 993
~~~

Teste também uma porta que deve permanecer bloqueada.

## 8. Ferramentas de diagnóstico e validação

~~~bash
sudo nft -c -f /etc/nftables.conf
sudo nft -a list ruleset
sudo ss -lntup
systemctl is-active NOME_DO_SERVICO
nc -vz 192.168.50.10 PORTA
sudo tcpdump -ni lab0 port PORTA
~~~

## 9. Troubleshooting

Exemplo:

~~~text
DNS funciona.
SMTP funciona.
HTTP deixou de responder.
O Nginx continua ativo.
~~~

O aluno deverá provar se a falha está no serviço, porta, rede ou firewall.

## 10. Portfólio

~~~text
firewall/aula-23/
├── README.md
└── nftables.conf
~~~
