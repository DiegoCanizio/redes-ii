# Aula 11 — BIND9: zona direta e reversa

**Data:** 05/11/2026  
**Duração:** 150 minutos

---

## Objetivo

Hoje seu servidor se tornará autoritativo pelo domínio:

```text
empresa.test
```

Topologia:

```text
cli-r2-sNN
      │
      │ DNS
      ▼
192.168.50.10
srv-r2-sNN
      │
      └── BIND9
```

---

# 1. Instale o BIND

No servidor:

```bash
sudo apt update
sudo apt install -y bind9 bind9-utils dnsutils
```

Confira:

```bash
systemctl status bind9
```

---

# 2. Faça backup

```bash
sudo cp /etc/bind/named.conf.local \
  /etc/bind/named.conf.local.bak-aula11
```

```bash
sudo cp /etc/bind/named.conf.options \
  /etc/bind/named.conf.options.bak-aula11
```

---

# 3. Limite a escuta ao laboratório

Edite:

```bash
sudo nano /etc/bind/named.conf.options
```

Dentro de `options { ... };`, configure de forma equivalente a:

```text
listen-on {
    127.0.0.1;
    192.168.50.10;
};

listen-on-v6 { none; };

allow-query {
    127.0.0.1;
    192.168.50.0/24;
};
```

Mantenha as demais opções necessárias do arquivo.

> O objetivo é atender a rede de laboratório, não transformar `host0` em interface de serviço DNS da disciplina.

---

# 4. Declare a zona direta

Edite:

```bash
sudo nano /etc/bind/named.conf.local
```

Adicione:

```bind
zone "empresa.test" {
    type master;
    file "/etc/bind/db.empresa.test";
};
```

---

# 5. Crie a zona direta

```bash
sudo nano /etc/bind/db.empresa.test
```

Exemplo:

```dns
$TTL 3600

@   IN SOA ns.empresa.test. admin.empresa.test. (
        2026110501
        3600
        1800
        604800
        86400
)

@       IN NS      ns.empresa.test.
@       IN MX 10   mail.empresa.test.

ns      IN A       192.168.50.10
srv     IN A       192.168.50.10
mail    IN A       192.168.50.10
www     IN CNAME   srv.empresa.test.
```

---

# 6. O serial

O serial deve aumentar quando a zona é alterada.

Nesta disciplina utilizaremos o padrão:

```text
AAAAMMDDNN
```

Exemplo:

```text
2026110501
```

Se alterar novamente no mesmo dia:

```text
2026110502
```

---

# 7. Valide a zona direta

```bash
sudo named-checkconf
```

Depois:

```bash
sudo named-checkzone empresa.test \
  /etc/bind/db.empresa.test
```

Somente se estiver correto:

```bash
sudo systemctl restart bind9
```

---

# 8. Teste diretamente o servidor DNS

```bash
dig @192.168.50.10 empresa.test NS
```

```bash
dig @192.168.50.10 srv.empresa.test A
```

```bash
dig @192.168.50.10 www.empresa.test CNAME
```

```bash
dig @192.168.50.10 empresa.test MX
```

---

# 9. Zona reversa

Para a rede:

```text
192.168.50.0/24
```

a zona reversa será:

```text
50.168.192.in-addr.arpa
```

Adicione em:

```text
/etc/bind/named.conf.local
```

```bind
zone "50.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168.50";
};
```

---

# 10. Crie o arquivo reverso

```bash
sudo nano /etc/bind/db.192.168.50
```

Exemplo:

```dns
$TTL 3600

@   IN SOA ns.empresa.test. admin.empresa.test. (
        2026110501
        3600
        1800
        604800
        86400
)

@       IN NS      ns.empresa.test.

10      IN PTR     srv.empresa.test.
50      IN PTR     cliente.empresa.test.
```

---

# 11. Valide a zona reversa

```bash
sudo named-checkzone 50.168.192.in-addr.arpa \
  /etc/bind/db.192.168.50
```

Depois:

```bash
sudo systemctl reload bind9
```

Teste:

```bash
dig @192.168.50.10 -x 192.168.50.10
```

---

# 12. Portas e logs

```bash
sudo ss -lunp | grep ':53'
sudo ss -lntp | grep ':53'
```

Logs:

```bash
sudo journalctl -u bind9 -n 30 --no-pager
```

---

# 13. Capture uma consulta

Servidor:

```bash
sudo tcpdump -i lab0 -nn 'port 53'
```

A partir do cliente ou de outro terminal:

```bash
dig @192.168.50.10 www.empresa.test
```

Observe a requisição e a resposta.

---

# 14. Ainda não conclua o commit

Na próxima aula, o cliente utilizará o BIND automaticamente por meio das informações entregues pelo DHCP.

Por enquanto, deixe preparados no portfólio:

```text
dns/
```

O marco será concluído após a integração.
