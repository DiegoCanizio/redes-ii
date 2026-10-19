# Aula 07 — Troubleshooting e captura de tráfego

**Data:** 22/10/2026  
**Duração:** 150 minutos

---

## Objetivo

Hoje o foco não é instalar um novo serviço.

O objetivo é aprender a responder:

> **onde está a falha e qual evidência comprova isso?**

Utilizaremos a rede construída na Aula 06:

```text
srv-r2-sNN
192.168.50.10/24
      │
      │ lab0
      │
192.168.50.20/24
cli-r2-sNN
```

---

# Método de diagnóstico

Utilizaremos:

```text
Sintoma
   ↓
Hipótese
   ↓
Teste
   ↓
Evidência
   ↓
Causa
   ↓
Correção
   ↓
Validação
```

Evite alterar várias configurações ao mesmo tempo.

---

# 1. Verifique o estado conhecido

No servidor:

```bash
hostname
ip -br addr
ip route
ip neigh
```

Teste:

```bash
ping -c 3 192.168.50.20
```

No cliente:

```bash
hostname
ip -br addr
ip route
```

Teste:

```bash
ping -c 3 192.168.50.10
```

Antes de procurar uma falha, conheça o estado saudável.

---

# 2. Observe ICMP com `tcpdump`

No servidor:

```bash
sudo tcpdump -i lab0 -nn icmp
```

Mantenha a captura aberta.

No cliente:

```bash
ping -c 4 192.168.50.10
```

Na captura, identifique:

```text
echo request
echo reply
```

Pergunta:

### O `ping` é apenas uma mensagem?

```text
☐ Sim
☐ Não
```

Registre o que aparece na captura:

```text
____________________________________________________________
```

Interrompa com:

```text
Ctrl+C
```

---

# 3. Observe ARP

No servidor:

```bash
sudo tcpdump -i lab0 -nn arp
```

Em outro terminal, limpe apenas a entrada do cliente:

```bash
sudo ip neigh del 192.168.50.20 dev lab0 2>/dev/null || true
```

Depois:

```bash
ping -c 1 192.168.50.20
```

Observe a resolução:

```text
Who has ...?
... is at ...
```

Depois:

```bash
ip neigh show dev lab0
```

---

# 4. Serviço, porta e processo

No servidor:

```bash
systemctl status ssh
```

Depois:

```bash
sudo ss -lntp | grep ':22'
```

Esses comandos respondem perguntas diferentes:

```text
systemctl
→ estado do serviço

ss
→ porta/socket em escuta
```

Complete:

```text
O serviço SSH está:
____________________________________

A porta observada é:
____________________________________
```

---

# 5. Logs

Últimos eventos do SSH:

```bash
sudo journalctl -u ssh -n 20 --no-pager
```

Em outro terminal, faça uma conexão para o servidor e depois consulte novamente.

Pergunta:

### O log é uma evidência do que ocorreu no serviço?

```text
☐ Sim
☐ Não
```

---

# 6. Incidente de laboratório

O professor aplicará ou indicará um incidente no seu ambiente.

Você receberá apenas o **sintoma** ou o **estado esperado**.

Não comece alterando arquivos.

Primeiro colete:

```bash
ip -br addr
ip route
ip neigh
ping -c 3 DESTINO
ss -lntup
systemctl --failed
```

Quando houver um serviço envolvido:

```bash
systemctl status SERVICO
journalctl -u SERVICO -n 30 --no-pager
```

Quando houver dúvida sobre tráfego:

```bash
sudo tcpdump -i lab0 -nn
```

---

# 7. Registre o diagnóstico

No portfólio:

```bash
mkdir -p rede/aula-07
nano rede/aula-07/diagnostico.md
```

Utilize:

```markdown
# Aula 07 — Troubleshooting

## Sintoma
O que estava acontecendo?

## Hipótese
Qual foi a primeira hipótese?

## Teste
Qual comando ou procedimento foi utilizado?

## Evidência
Qual saída sustentou ou rejeitou a hipótese?

## Causa
Qual era a causa real?

## Correção
O que foi alterado?

## Validação
Como foi comprovado que o problema foi resolvido?
```

---

# 8. Marco de competência: rede + troubleshooting

Confira:

```bash
git status
```

Inclua:

```text
rede/aula-06/
rede/aula-07/
```

Depois:

```bash
git add rede/
git status
```

Commit sugerido:

```bash
git commit -m "Configura rede de laboratorio e documenta troubleshooting"
```

Envie:

```bash
git push
```

---

# Checklist

```text
[ ] validei o estado saudável antes do incidente.
[ ] capturei ICMP.
[ ] observei ARP.
[ ] diferenciei serviço e porta.
[ ] consultei logs.
[ ] diagnostiquei sem alterar tudo ao mesmo tempo.
[ ] registrei sintoma, hipótese, teste e evidência.
[ ] corrigi e validei.
[ ] concluí o marco rede + troubleshooting no portfólio.
```
