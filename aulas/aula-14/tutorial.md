# Aula 14 — Laboratório integrado e checkpoint

**Data:** 17/11/2026  
**Duração:** 100 minutos

---

## Objetivo

Hoje não será apresentado um novo serviço.

O objetivo é verificar se você consegue operar a infraestrutura construída nas aulas anteriores **sem um roteiro de configuração passo a passo**.

Estado esperado:

```text
cli-r2-sNN
      │
      │ DHCP
      ▼
recebe configuração de rede
      │
      │ DNS
      ▼
www.empresa.test → 192.168.50.10
      │
      │ HTTP
      ▼
Nginx responde
```

---

# Regras

Você pode consultar:

- seus próprios arquivos;
- seu portfólio;
- materiais desta disciplina;
- `man`;
- `--help`.

O professor não indicará imediatamente qual arquivo deve ser alterado.

Utilize evidências.

---

# 1. Verificação inicial

Sem modificar nada, registre o estado atual.

## Servidor

```bash
hostname
ip -br addr
ip route
systemctl --failed
```

Serviços:

```bash
systemctl is-active kea-dhcp4-server
systemctl is-active bind9
systemctl is-active nginx
```

Portas:

```bash
sudo ss -lntup
```

## Cliente

```bash
hostname
ip -br addr
ip route
```

Teste:

```bash
getent hosts www.empresa.test
curl -I http://www.empresa.test/
```

---

# 2. O professor aplicará um incidente

Seu ambiente poderá conter uma falha relacionada a conteúdo já trabalhado.

Possíveis áreas:

```text
endereçamento
DHCP
DNS
HTTP
serviço
porta
arquivo de configuração
```

Não será informado antecipadamente onde está a falha.

---

# 3. Diagnostique

Utilize:

```text
Sintoma
→ Hipótese
→ Teste
→ Evidência
→ Causa
→ Correção
→ Validação
```

Ferramentas disponíveis incluem:

```bash
ip -br addr
ip route
ip neigh
ping
getent
dig
ss
systemctl
journalctl
tcpdump
kea-dhcp4 -t
named-checkconf
named-checkzone
nginx -t
curl
```

Nem todas são necessárias em todos os incidentes.

---

# 4. Regra de ouro

Antes de reiniciar um serviço, pergunte:

```text
Existe uma forma de validar a configuração primeiro?
```

Exemplos:

```bash
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
sudo named-checkconf
sudo named-checkzone ...
sudo nginx -t
```

---

# 5. Estado final obrigatório

Ao terminar:

## Rede

O servidor deve manter:

```text
lab0: 192.168.50.10/24
```

O cliente deverá obter sua configuração conforme o DHCP vigente.

## DHCP

```text
kea-dhcp4-server → active
```

O cliente deve possuir lease válido.

## DNS

Devem funcionar:

```text
srv.empresa.test
www.empresa.test
```

## HTTP

Do cliente:

```bash
curl http://www.empresa.test/
```

deve retornar a página configurada na Aula 13.

---

# 6. Documente o incidente

No portfólio:

```bash
mkdir -p checkpoint
nano checkpoint/primeira-unidade.md
```

Use:

```markdown
# Checkpoint — primeira unidade

## Estado inicial
O que funcionava antes do incidente?

## Sintoma
O que deixou de funcionar?

## Hipótese inicial

## Testes realizados

### Teste 1
Comando:
Resultado:
Interpretação:

### Teste 2
Comando:
Resultado:
Interpretação:

## Causa

## Correção

## Validação final

### DHCP

### DNS

### HTTP

## O que eu faria diferente
```

---

# 7. Atualize o portfólio

Este checkpoint pode atualizar as evidências dos marcos anteriores.

Confira:

```bash
git status
```

Depois:

```bash
git add checkpoint/
git status
git commit -m "Registra checkpoint integrado da primeira unidade"
git push
```

---

# 8. Autoavaliação

Marque:

```text
[ ] Consigo diferenciar falha de rede e falha de serviço.
[ ] Sei verificar se um serviço está ativo.
[ ] Sei verificar se uma porta está aberta.
[ ] Sei validar Kea antes de reiniciar.
[ ] Sei validar BIND antes de reiniciar.
[ ] Sei validar Nginx antes de recarregar.
[ ] Sei testar DNS de forma explícita.
[ ] Sei testar a resolução normal do cliente.
[ ] Sei consultar logs.
[ ] Sei usar tcpdump quando preciso observar tráfego.
[ ] Consigo documentar causa, correção e validação.
```

Se algum item ainda estiver inseguro, utilize este encontro para revisar seu próprio ambiente e suas evidências.

---

# Próximo encontro

A próxima etapa será a **Avaliação 1**.

O detalhamento da avaliação será disponibilizado separadamente.
