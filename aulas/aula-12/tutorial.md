# Aula 12 — Integração DHCP + DNS

**Data:** 10/11/2026  
**Duração:** 100 minutos

---

## Situação-problema

Até agora sabemos testar DNS explicitamente:

```bash
dig @192.168.50.10 www.empresa.test
```

Mas um usuário não deveria precisar informar manualmente o servidor DNS em cada comando.

Hoje a rede deverá funcionar assim:

```text
cliente
   │
   │ DHCP
   ▼
recebe:
- endereço IPv4
- servidor DNS = 192.168.50.10
- domínio = empresa.test
   │
   ▼
BIND9
   │
   ▼
www.empresa.test
```

---

# 1. Confirme os serviços

No servidor:

```bash
systemctl is-active kea-dhcp4-server
systemctl is-active bind9
```

Confira portas:

```bash
sudo ss -lunp | grep -E ':67|:53'
```

---

# 2. Revise as opções do DHCP

No arquivo:

```text
/etc/kea/kea-dhcp4.conf
```

confirme:

```json
{
  "name": "domain-name-servers",
  "data": "192.168.50.10"
}
```

e:

```json
{
  "name": "domain-name",
  "data": "empresa.test"
}
```

Valide:

```bash
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
```

---

# 3. Renove o cliente

No cliente:

```bash
sudo networkctl renew lab0
```

Se necessário:

```bash
sudo systemctl restart systemd-networkd
```

Depois:

```bash
ip -br addr show lab0
```

Quando disponível:

```bash
resolvectl status lab0
```

Também observe:

```bash
cat /etc/resolv.conf
```

---

# 4. Teste sem `@SERVIDOR`

No cliente:

```bash
getent hosts srv.empresa.test
```

Depois:

```bash
getent hosts www.empresa.test
```

Se `dig` estiver disponível:

```bash
dig www.empresa.test
```

Agora **não informe**:

```text
@192.168.50.10
```

O objetivo é provar que o cliente está utilizando sua configuração normal de resolução.

---

# 5. Teste o domínio de busca

Tente:

```bash
getent hosts srv
```

e:

```bash
getent hosts www
```

Dependendo da configuração do resolver, o domínio de busca recebido poderá permitir a expansão para:

```text
srv.empresa.test
www.empresa.test
```

Registre o comportamento observado.

---

# 6. Resolução reversa

No cliente, se `dig` estiver disponível:

```bash
dig -x 192.168.50.10
```

Ou consulte a partir do servidor DNS:

```bash
dig @192.168.50.10 -x 192.168.50.10
```

---

# 7. Teste integrado

No cliente:

```bash
ping -c 3 srv.empresa.test
```

Pergunta:

### O `ping` testa somente DNS?

```text
☐ Sim
☐ Não
```

Explique:

```text
____________________________________________________________
```

O nome precisa primeiro ser resolvido; depois ocorre o teste ICMP.

---

# 8. Incidente integrado

O professor indicará uma condição incorreta.

O sintoma poderá envolver:

```text
DHCP
DNS
ou a relação entre os dois
```

Não suponha a causa.

Utilize o método:

```text
Sintoma
→ Hipótese
→ Teste
→ Evidência
→ Causa
→ Correção
→ Validação
```

Perguntas úteis:

```text
O cliente tem endereço?
Qual endereço recebeu?
Qual DNS recebeu?
O BIND está ativo?
A porta 53 está aberta?
A zona é válida?
A consulta explícita funciona?
A consulta normal do sistema funciona?
```

---

# 9. Portfólio

Salve:

```bash
cd ~/SEU_REPOSITORIO
mkdir -p dns
```

```bash
sudo cat /etc/bind/named.conf.local > dns/named.conf.local
sudo cat /etc/bind/named.conf.options > dns/named.conf.options
sudo cat /etc/bind/db.empresa.test > dns/db.empresa.test
sudo cat /etc/bind/db.192.168.50 > dns/db.192.168.50
```

Crie:

```bash
nano dns/README.md
```

Inclua:

```markdown
# DNS e integração com DHCP

## Zona
- domínio:
- servidor DNS:

## Registros
- NS:
- A:
- CNAME:
- MX:
- PTR:

## Integração DHCP
- opção DNS:
- domínio:
- endereço do cliente:

## Testes
- consulta explícita:
- consulta normal do cliente:
- reversa:

## Troubleshooting
Sintoma:
Hipótese:
Teste:
Evidência:
Causa:
Correção:
Validação:
```

---

# 10. Marco DNS + integração

```bash
git status
git add dns/
git status
git commit -m "Implanta DNS e integra resolucao ao DHCP"
git push
```

---

# Checklist

```text
[ ] Kea está ativo.
[ ] BIND está ativo.
[ ] DHCP informa 192.168.50.10 como DNS.
[ ] empresa.test está configurada.
[ ] zona reversa funciona.
[ ] cliente resolve nomes sem informar @192.168.50.10.
[ ] documentei evidências.
[ ] concluí o marco DNS + integração.
```
