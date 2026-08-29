# Aula 10 — Servidor DNS com BIND9 e integração com DHCP

## Objetivo

Hoje `srv-redes2` se tornará servidor DNS autoritativo para:

```text
empresa.test
```

Também integraremos o DHCP para informar aos clientes:

```text
DNS:    192.168.50.10
Domínio: empresa.test
```

---

# Bloco 0

Servidor:

```bash
sudo apt update
sudo apt install -y bind9 bind9-utils dnsutils kea-dhcp4-server
```

Cliente:

```bash
sudo apt update
sudo apt install -y dnsutils git gh
```

Reconstrua seu DHCP da Aula 8.

Prepare seu portfólio.

---

# Parte 1 — Declare as zonas

No servidor:

```bash
sudo nano /etc/bind/named.conf.local
```

Adicione:

```conf
zone "empresa.test" {
    type master;
    file "/etc/bind/db.empresa.test";
};

zone "50.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168.50";
};
```

---

# Parte 2 — Zona direta

Crie:

```bash
sudo nano /etc/bind/db.empresa.test
```

Use:

```dns
$TTL 300
@   IN  SOA ns1.empresa.test. admin.empresa.test. (
        2026082901
        3600
        900
        604800
        300
)

    IN  NS  ns1.empresa.test.
    IN  MX  10 mail.empresa.test.

ns1     IN  A       192.168.50.10
srv     IN  A       192.168.50.10
web     IN  A       192.168.50.10
mail    IN  A       192.168.50.10
www     IN  CNAME   web
```

---

# Parte 3 — Entenda os registros

Complete:

| Registro | Função |
|---|---|
| SOA | |
| NS | |
| A | |
| CNAME | |
| MX | |

---

# Parte 4 — Zona reversa

Crie:

```bash
sudo nano /etc/bind/db.192.168.50
```

Use:

```dns
$TTL 300
@   IN  SOA ns1.empresa.test. admin.empresa.test. (
        2026082901
        3600
        900
        604800
        300
)

    IN  NS  ns1.empresa.test.

10  IN  PTR srv.empresa.test.
50  IN  PTR cliente.empresa.test.
```

Se seu cliente não utiliza `.50`, ajuste conforme orientação do professor.

---

# Parte 5 — Valide

Configuração geral:

```bash
sudo named-checkconf
```

Zona direta:

```bash
sudo named-checkzone empresa.test /etc/bind/db.empresa.test
```

Zona reversa:

```bash
sudo named-checkzone 50.168.192.in-addr.arpa /etc/bind/db.192.168.50
```

Não reinicie BIND se houver erro.

---

# Parte 6 — Inicie/reinicie

```bash
sudo systemctl restart bind9
```

Verifique:

```bash
systemctl is-active bind9
```

Porta:

```bash
sudo ss -luntp | grep ':53'
```

---

# Parte 7 — Teste diretamente o servidor

No cliente:

```bash
dig @192.168.50.10 empresa.test NS
```

```bash
dig @192.168.50.10 srv.empresa.test A
```

```bash
dig @192.168.50.10 www.empresa.test
```

```bash
dig @192.168.50.10 empresa.test MX
```

```bash
dig @192.168.50.10 -x 192.168.50.10
```

Registre resultados relevantes.

---

# Parte 8 — Integre o DHCP

No `kea-dhcp4.conf`, dentro da subnet, adicione:

```json
"option-data": [
  {
    "name": "domain-name-servers",
    "data": "192.168.50.10"
  },
  {
    "name": "domain-name",
    "data": "empresa.test"
  }
]
```

Atenção à sintaxe JSON.

Valide:

```bash
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
```

Depois:

```bash
sudo systemctl restart kea-dhcp4-server
```

---

# Parte 9 — Renove o cliente

```bash
sudo networkctl renew <INTERFACE-REDES2>
```

Verifique:

```bash
resolvectl status
```

Procure:

```text
192.168.50.10
empresa.test
```

na interface interna.

---

# Parte 10 — Teste sem indicar o servidor

```bash
dig srv.empresa.test
```

```bash
dig www.empresa.test
```

```bash
dig empresa.test MX
```

Também:

```bash
getent hosts srv.empresa.test
```

---

# Parte 11 — Diagnóstico orientado

O professor introduzirá uma falha simples.

Use, conforme o caso:

```bash
sudo named-checkconf
sudo named-checkzone empresa.test /etc/bind/db.empresa.test
systemctl status bind9
sudo journalctl -u bind9 -n 30
dig @192.168.50.10 srv.empresa.test
```

Registre:

```text
Sintoma:
____________________________________________________________

Evidência:
____________________________________________________________

Causa:
____________________________________________________________

Correção:
____________________________________________________________

Validação:
____________________________________________________________
```

---

# Parte 12 — Portfólio

Crie:

```text
dns/aula-10/
├── README.md
├── named.conf.local
├── db.empresa.test
├── db.192.168.50
└── kea-dhcp4.conf
```

No README registre:

- registros criados;
- consultas diretas;
- reverse lookup;
- DNS recebido por DHCP;
- consulta integrada sem `@`;
- diagnóstico.

Versione:

```bash
git add dns/aula-10
git commit -m "Aula 10 - integra DHCP e DNS"
git push
gh auth logout
```

---

# Próxima aula

**Avaliação Prática 1 — DHCP + DNS.**
