# Aula 24 — Proxy e filtragem de conteúdo com Squid

## Objetivos

Ao final desta aula, você deverá conseguir:

- diferenciar firewall e proxy de aplicação;
- configurar um proxy explícito;
- definir ACL por origem e destino;
- observar requisições permitidas e negadas;
- interpretar o access.log;
- validar a configuração antes de recarregar;
- diagnosticar falhas de proxy ou ACL.

## 1. Arquitetura

~~~text
cliente
  │
  │ proxy HTTP :3128
  ▼
Squid
  │
  ▼
destino Web
~~~

## 2. Instale

~~~bash
sudo apt update
sudo apt install -y squid
systemctl status squid --no-pager
sudo ss -lntp | grep ':3128'
~~~

## 3. Backup e configuração mínima

~~~bash
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.original
sudo nano /etc/squid/squid.conf
~~~

Use:

~~~conf
http_port 3128

acl redes2 src 192.168.50.0/24

http_access allow redes2
http_access deny all
~~~

Valide:

~~~bash
sudo squid -k parse
sudo systemctl restart squid
~~~

## 4. Teste

~~~bash
curl -v -x http://192.168.50.10:3128 http://example.com/
~~~

Servidor:

~~~bash
sudo tail -n 20 /var/log/squid/access.log
~~~

## 5. ACL por destino

Antes de `allow redes2`:

~~~conf
acl bloqueados dstdomain .example.com
http_access deny bloqueados
~~~

Valide e recarregue:

~~~bash
sudo squid -k parse
sudo systemctl reload squid
~~~

Teste novamente.

## 6. HTTPS via proxy explícito

~~~bash
curl -v -x http://192.168.50.10:3128 https://example.com/
~~~

Observe `CONNECT` no log.

Não faremos interceptação TLS.

## 7. Firewall x proxy

Compare atuação por IP/porta, participação na aplicação, ACL por domínio e logs.

## 8. Ferramentas de diagnóstico e validação

~~~bash
sudo squid -k parse
systemctl is-active squid
sudo ss -lntp | grep ':3128'
curl -v -x http://192.168.50.10:3128 URL
sudo tail -n 50 /var/log/squid/access.log
sudo journalctl -u squid -n 50 --no-pager
sudo nft list ruleset
~~~

## 9. Troubleshooting

O professor introduzirá inconsistência em ACL, ordem, porta ou origem.

O aluno recebe somente o comportamento esperado.

## 10. Portfólio

~~~text
proxy/aula-24/
├── README.md
└── squid.conf
~~~

Registre arquitetura, ACLs, testes, logs, comparação com firewall e troubleshooting.
