# Aula 09 — DNS por dentro e primeira zona BIND

**Data:** 29/10/2026  
**Duração:** 150 minutos

## Objetivo

Compreender o DNS como cliente e, em seguida, transformar o servidor em autoritativo para:

```text
empresa.test
```

Ao final, consultas explícitas ao servidor devem funcionar:

```bash
dig @192.168.50.10 srv.empresa.test A
dig @192.168.50.10 www.empresa.test
```

## 1. DNS antes do BIND

O servidor possui acesso externo pela `host0`. Use-o para observar DNS público:

```bash
resolvectl status
dig example.com A
dig example.com AAAA
dig example.com NS
dig gmail.com MX
```

Identifique em uma resposta:

```text
status
QUESTION
ANSWER
TTL
```

## 2. Consulte um servidor específico

```bash
dig @1.1.1.1 example.com A
```

Compare com:

```bash
dig example.com A
```

## 3. Observe o tráfego DNS

Descubra a interface da rota padrão:

```bash
ip route show default
```

Capture nela:

```bash
sudo tcpdump -i host0 -nn 'port 53'
```

Em outro terminal:

```bash
dig iana.org A
```

## 4. Instale o BIND

```bash
sudo apt update
sudo apt install -y bind9 bind9-utils dnsutils
```

No Ubuntu 26.04, o pacote é `bind9`, mas a unidade systemd utilizada pelo serviço é `named.service`.

## 5. Restrinja o serviço ao laboratório

Edite:

```bash
sudo nano /etc/bind/named.conf.options
```

Mantenha as opções existentes necessárias e garanta conceitualmente:

```conf
listen-on { 127.0.0.1; 192.168.50.10; };
listen-on-v6 { none; };
allow-query { localhost; 192.168.50.0/24; };
```

O objetivo é que o BIND responda ao cliente pela `lab0`.

## 6. Declare a zona direta

```bash
sudo nano /etc/bind/named.conf.local
```

Adicione:

```conf
zone "empresa.test" {
    type master;
    file "/etc/bind/db.empresa.test";
};
```

## 7. Crie a zona

```bash
sudo nano /etc/bind/db.empresa.test
```

Exemplo:

```dns
$TTL 300
@   IN  SOA ns1.empresa.test. admin.empresa.test. (
        2026102901
        3600
        900
        604800
        300
)

        IN  NS      ns1.empresa.test.
        IN  MX 10   mail.empresa.test.

ns1     IN  A       192.168.50.10
srv     IN  A       192.168.50.10
mail    IN  A       192.168.50.10
www     IN  CNAME   srv.empresa.test.
```

## 8. Valide antes de reiniciar

```bash
sudo named-checkconf
sudo named-checkzone empresa.test /etc/bind/db.empresa.test
```

Depois:

```bash
sudo systemctl restart named
systemctl is-active named
sudo ss -luntp | grep ':53'
```

## 9. Teste pelo cliente

```bash
dig @192.168.50.10 empresa.test NS
dig @192.168.50.10 srv.empresa.test A
dig @192.168.50.10 www.empresa.test
dig @192.168.50.10 empresa.test MX
```

Nesta etapa ainda usamos `@192.168.50.10` de propósito. O DHCP ainda não informou ao cliente qual DNS deve utilizar.

## Portfólio

Registre em `dns/aula-09/`:

- função de A, AAAA, NS, MX e CNAME;
- diferença entre resolver padrão e consulta com `@servidor`;
- `named.conf.local`;
- zona direta;
- evidências de porta 53 e consultas.
