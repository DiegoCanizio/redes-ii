# Aula 22 — Firewall com nftables

## Objetivos

Ao final desta aula, você deverá conseguir:

- explicar o papel de um firewall no host;
- identificar quais serviços precisam ser acessíveis;
- criar uma política básica com nftables;
- permitir conexões estabelecidas;
- liberar serviços explicitamente;
- validar regras e observar o ruleset;
- distinguir falha de serviço de bloqueio por firewall;
- diagnosticar um incidente de filtragem.

## 1. Antes do firewall

~~~bash
sudo ss -lntup
~~~

Relacione porta e serviço:

~~~text
22 SSH
25 SMTP
53 DNS
80 HTTP
110 POP3
143 IMAP
993 IMAPS
995 POP3S
~~~

## 2. Instale

~~~bash
sudo apt update
sudo apt install -y nftables
sudo nft list ruleset
~~~

## 3. Política inicial

Backup:

~~~bash
sudo cp /etc/nftables.conf /etc/nftables.conf.original
~~~

Use uma estrutura de laboratório:

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

## 4. Valide antes de aplicar

~~~bash
sudo nft -c -f /etc/nftables.conf
sudo systemctl restart nftables
sudo nft list ruleset
~~~

## 5. Libere serviços necessários

Conforme o cenário, acrescente regras como:

~~~nft
tcp dport 25 accept
udp dport 53 accept
tcp dport 53 accept
tcp dport 80 accept
tcp dport 110 accept
tcp dport 143 accept
tcp dport 993 accept
tcp dport 995 accept
~~~

Valide novamente antes de reiniciar.

## 6. Teste do cliente

~~~bash
dig @192.168.50.10 empresa.test
curl -I http://192.168.50.10/
nc -vz 192.168.50.10 25
nc -vz 192.168.50.10 143
~~~

Teste também uma porta que não deveria estar liberada.

## 7. Ferramentas de diagnóstico e validação

~~~bash
sudo nft -c -f /etc/nftables.conf
sudo nft -a list ruleset
sudo ss -lntup
systemctl is-active NOME_DO_SERVICO
nc -vz 192.168.50.10 PORTA
sudo tcpdump -ni lab0 port PORTA
~~~

Separe:

~~~text
serviço não escutando
≠ pacote não chegando
≠ firewall descartando
≠ aplicação rejeitando
~~~

## 8. Troubleshooting

O professor introduzirá uma regra incompatível com o estado esperado.

Exemplo:

~~~text
DNS funciona.
SMTP funciona.
HTTP deixou de responder.
O Nginx continua ativo.
~~~

O aluno deverá provar em qual camada está a falha.

## 9. Portfólio

~~~text
firewall/aula-22/
├── README.md
└── nftables.conf
~~~

Registre política, serviços liberados, testes e troubleshooting.
