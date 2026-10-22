# Aula 10 — BIND: zona reversa, validação e diagnóstico

**Data:** 03/11/2026  
**Duração:** 100 minutos

## Objetivo

Completar o DNS autoritativo iniciado na Aula 09, acrescentando resolução reversa e uma rotina de validação operacional.

## 1. Confirme a zona direta

```bash
sudo named-checkconf
sudo named-checkzone empresa.test /etc/bind/db.empresa.test
dig @192.168.50.10 srv.empresa.test A
```

## 2. Declare a zona reversa

Em `/etc/bind/named.conf.local`:

```conf
zone "50.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168.50";
};
```

## 3. Crie a zona reversa

```bash
sudo nano /etc/bind/db.192.168.50
```

Conteúdo:

```dns
$TTL 300
@   IN  SOA ns1.empresa.test. admin.empresa.test. (
        2026110301
        3600
        900
        604800
        300
)

    IN  NS  ns1.empresa.test.

10  IN  PTR srv.empresa.test.
50  IN  PTR cliente.empresa.test.
```

## 4. Valide

```bash
sudo named-checkconf
sudo named-checkzone 50.168.192.in-addr.arpa /etc/bind/db.192.168.50
```

Depois:

```bash
sudo systemctl reload named
```

## 5. Teste direta e reversa

```bash
dig @192.168.50.10 srv.empresa.test A
dig @192.168.50.10 www.empresa.test
dig @192.168.50.10 empresa.test MX
dig @192.168.50.10 -x 192.168.50.10
```

## 6. Diagnóstico em camadas

Uma configuração DNS deve passar por diferentes verificações:

```text
arquivo sintaticamente válido
        ↓
serviço ativo
        ↓
porta 53 em escuta
        ↓
cliente alcança o servidor
        ↓
consulta retorna resposta correta
```

Use, conforme o sintoma:

```bash
sudo named-checkconf
sudo named-checkzone ...
systemctl status named --no-pager
sudo ss -luntp | grep ':53'
sudo journalctl -u named -n 30 --no-pager
dig @192.168.50.10 ...
sudo tcpdump -i lab0 -nn 'port 53'
```

## 7. Incidente curto

O professor introduzirá uma inconsistência na configuração DNS. Não altere nada até produzir uma hipótese e pelo menos uma evidência.

## Portfólio

Registre em `dns/aula-10/`:

- zona reversa;
- diferença entre A e PTR;
- serial utilizado;
- comandos de validação;
- incidente e evidências.
