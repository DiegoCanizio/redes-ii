# Aula 29 — Projeto integrado e comissionamento

## Missão

Sua equipe deverá montar e preparar para reconstrução uma pequena infraestrutura de rede.

Nesta aula você **não receberá um passo a passo**.

Use:

- roteiros anteriores;
- seu portfólio;
- documentação;
- configurações versionadas;
- evidências.

---

# Infraestrutura

```text
Rede:       192.168.50.0/24
Servidor:   192.168.50.10/24
Cliente:    DHCP
Domínio:    empresa.test
```

---

# Serviços obrigatórios

Sua solução deve possuir:

```text
DHCP
DNS direto e reverso
HTTP
HTTPS/TLS
SSH
SFTP
nftables
SNMP
Docker Compose
```

O componente Web deverá possuir pelo menos uma parte reconstruível com Compose.

---

# Serviço adicional

O professor indicará:

```text
FTP
```

ou:

```text
SMTP + IMAP
```

---

# Requisitos

## DHCP

```text
[ ] pool
[ ] reserva
[ ] DNS informado ao cliente
```

## DNS

```text
[ ] zona empresa.test
[ ] zona reversa
[ ] registros necessários
```

## Web

```text
[ ] HTTP
[ ] HTTPS
[ ] certificado de laboratório
```

## Administração

```text
[ ] SSH
[ ] SFTP
```

## Firewall

```text
[ ] política explícita
[ ] somente serviços necessários acessíveis
```

## Monitoramento

```text
[ ] SNMP read-only
[ ] restrito à REDES2
[ ] consulta demonstrável
```

## Docker

```text
[ ] compose.yaml
[ ] serviço reconstruível
[ ] acesso testado
```

---

# Segurança

Não coloque no Git:

```text
senhas
tokens
PATs
chaves privadas
.env com credenciais
```

Certificados públicos podem ser armazenados quando necessário.

Chaves privadas não.

---

# Reconstrução

Sua documentação deve permitir:

```text
VM limpa
  ↓
rede
  ↓
dependências
  ↓
clone
  ↓
configurações
  ↓
validações
  ↓
serviços
  ↓
firewall
  ↓
containers
  ↓
testes
```

---

# Estrutura sugerida

```text
projeto-final/
├── README.md
├── rede/
├── dhcp/
├── dns/
├── web/
├── firewall/
├── monitoramento/
├── containers/
├── scripts/
└── evidencias/
```

Você pode organizar de outra forma se permanecer clara.

---

# Checklist de comissionamento

## Rede

```text
[ ] servidor .10
[ ] cliente recebe endereço
[ ] rota externa preservada
```

## DHCP/DNS

```text
[ ] lease
[ ] reserva
[ ] resolução direta
[ ] resolução reversa
```

## Web

```text
[ ] HTTP
[ ] HTTPS
```

## SSH/SFTP

```text
[ ] SSH
[ ] SFTP
```

## Firewall

```text
[ ] portas necessárias
[ ] porta não autorizada bloqueada
```

## SNMP

```text
[ ] agente
[ ] consulta
```

## Compose

```text
[ ] up
[ ] serviço responde
[ ] down
[ ] up novamente
```

---

# README do projeto

Inclua:

```markdown
# Projeto Final — Redes II

## Arquitetura

## Endereçamento

## Serviços e portas

## Ordem de reconstrução

## Validações

## Firewall

## Monitoramento

## Containers

## Serviço adicional

## Segurança

## Limitações conhecidas
```

---

# Final da aula

Faça commit/push de tudo que será necessário para reconstrução.

> Na próxima aula as VMs serão limpas. A infraestrutura da Aula 29 não será mantida.

---

# Próxima aula

Avaliação prática final.
