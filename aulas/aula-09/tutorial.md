# Aula 09 — DNS: consultas e captura

## Objetivo

Hoje você utilizará DNS como cliente antes de configurar seu próprio servidor.

Ferramenta principal:

```text
dig
```

Registros:

```text
A
AAAA
CNAME
MX
NS
PTR
```

---

# Bloco 0

Nesta aula a rede interna pode permanecer estática:

```text
srv-redes2 → 192.168.50.10/24
cli-redes2 → 192.168.50.20/24
```

No cliente:

```bash
sudo apt update
sudo apt install -y dnsutils tcpdump git gh
```

Prepare seu portfólio.

---

# Parte 1 — Descubra o DNS do sistema

```bash
resolvectl status
```

Depois:

```bash
cat /etc/resolv.conf
```

Registre:

```text
Servidor/resolvedor observado:
____________________________________________________________
```

---

# Parte 2 — Registros A e AAAA

```bash
dig example.com A
```

Depois:

```bash
dig example.com AAAA
```

Complete:

```text
A representa:
____________________________________________________________

AAAA representa:
____________________________________________________________
```

---

# Parte 3 — NS

```bash
dig example.com NS
```

O registro NS indica:

____________________________________________________________________

---

# Parte 4 — MX

```bash
dig gmail.com MX
```

Observe os valores de preferência e os nomes dos servidores.

MX está relacionado a:

____________________________________________________________________

---

# Parte 5 — CNAME

O professor fornecerá um nome previamente validado que utilize CNAME.

Execute:

```bash
dig <NOME-FORNECIDO> CNAME
```

CNAME representa:

____________________________________________________________________

---

# Parte 6 — Seções da resposta

Em uma consulta `dig`, identifique:

```text
QUESTION
ANSWER
AUTHORITY
ADDITIONAL
```

Nem todas aparecerão com conteúdo em todas as consultas.

Localize também:

```text
status
TTL
```

O TTL está relacionado a:

____________________________________________________________________

---

# Parte 7 — Consulta a servidor específico

Use um servidor indicado pelo professor ou identificado no ambiente:

```bash
dig @<SERVIDOR-DNS> example.com A
```

Qual a diferença para:

```bash
dig example.com A
```

____________________________________________________________________

---

# Parte 8 — Resolução reversa

Escolha um endereço retornado anteriormente:

```bash
dig -x <ENDERECO-IP>
```

O tipo de registro utilizado é:

```text
____________________________________
```

---

# Parte 9 — Captura

Descubra a interface NAT:

```bash
ip route show default
```

Limpe o cache:

```bash
sudo resolvectl flush-caches
```

Capture:

```bash
sudo tcpdump -i <INTERFACE-NAT> -nn 'port 53'
```

Em outro terminal:

```bash
dig iana.org A
```

Observe requisição e resposta.

---

# Parte 10 — Salve uma captura

```bash
sudo tcpdump -i <INTERFACE-NAT> -nn -c 10 -w aula-09-dns.pcap 'port 53'
```

Gere novas consultas até a captura terminar.

Leia:

```bash
tcpdump -nn -r aula-09-dns.pcap
```

---

# Parte 11 — Investigação

Preencha com consultas reais.

| Item | Resultado resumido |
|---|---|
| A de `example.com` | |
| AAAA de `example.com` | |
| NS de `example.com` | |
| MX de `gmail.com` | |
| PTR de um IP consultado | |
| TTL de uma resposta | |

---

# Parte 12 — Portfólio

Crie:

```text
dns/aula-09/
├── README.md
└── aula-09-dns.pcap
```

README:

```markdown
# Aula 09 — Consultas DNS

## Resolvedor do sistema

## Registros consultados
### A
### AAAA
### NS
### MX
### CNAME
### PTR

## TTL

## Captura
- interface:
- porta:
- consulta observada:

## Síntese
Explique a diferença entre resolver um nome e acessar o serviço associado a ele.
```

Versione:

```bash
git add dns/aula-09
git commit -m "Aula 09 - registra consultas DNS"
git push
gh auth logout
```

---

# Próxima aula

Você configurará `srv-redes2` como servidor autoritativo de:

```text
empresa.test
```
