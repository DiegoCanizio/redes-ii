# Avaliação Prática 1 — DHCP + DNS

## Objetivo

Implantar e demonstrar uma infraestrutura funcional de DHCP + DNS a partir de duas VMs Ubuntu Server limpas.

Você deverá configurar, testar e documentar a solução.

---

# Cenário

## Rede interna

```text
192.168.80.0/24
```

## Servidor

```text
192.168.80.10/24
```

## Cliente

O endereço da interface interna deverá ser obtido por DHCP.

A interface NAT continuará sendo utilizada para acesso externo.

---

# DHCP

Utilize **Kea DHCPv4**.

Pool:

```text
192.168.80.100–192.168.80.130
```

Crie uma reserva para a interface interna do cliente:

```text
192.168.80.50
```

O DHCP também deverá informar:

```text
Servidor DNS: 192.168.80.10
Domínio:       aurora.test
```

Não configure gateway fictício na rede interna.

---

# DNS

Utilize **BIND9**.

Domínio:

```text
aurora.test
```

O servidor deve ser autoritativo para a zona direta e para a zona reversa de:

```text
192.168.80.0/24
```

Crie registros que permitam demonstrar:

```text
NS
A
CNAME
MX
PTR
```

Nomes mínimos:

```text
ns1.aurora.test
srv.aurora.test
web.aurora.test
www.aurora.test
mail.aurora.test
```

---

# O que deve ser demonstrado

## Rede

- servidor com endereço correto;
- cliente alcançando servidor;
- acesso externo preservado pela NAT.

## DHCP

- serviço ativo;
- pool correto;
- cliente recebendo lease;
- reserva `192.168.80.50`;
- DNS/domínio recebidos pelo cliente.

## DNS

Demonstrar consultas equivalentes a:

```text
NS
A
CNAME
MX
PTR
```

Também demonstrar consulta do cliente **sem informar manualmente `@192.168.80.10`**, provando que o DNS foi recebido pela configuração de rede.

---

# Validação

Você deverá escolher comandos adequados para comprovar o funcionamento.

Exemplos de tipos de evidência estudados anteriormente:

```text
estado do serviço
porta em escuta
endereço
rota
lease
log
consulta DNS
```

A escolha dos comandos faz parte da avaliação.

---

# Incidente

Durante a avaliação, o professor introduzirá ou atribuirá **um incidente**.

Você deverá utilizar:

```text
Sintoma
→ Hipótese
→ Teste
→ Evidência
→ Causa
→ Correção
→ Validação
```

Não altere várias configurações simultaneamente sem produzir evidências.

---

# Entrega

No seu portfólio:

```text
avaliacoes/
└── avaliacao-01/
    ├── README.md
    ├── kea-dhcp4.conf
    ├── named.conf.local
    ├── db.aurora.test
    └── db.192.168.80
```

Os nomes dos arquivos podem variar apenas quando justificado pela configuração utilizada.

---

# README da avaliação

Registre no mínimo:

```markdown
# Avaliação Prática 1 — DHCP + DNS

## Rede
- servidor:
- cliente:
- rota externa:

## DHCP
- pool:
- reserva:
- lease:
- DNS entregue:
- domínio entregue:

## DNS
- zona:
- registros:
- reverse:

## Testes
- DHCP:
- A:
- CNAME:
- MX:
- PTR:
- consulta integrada:

## Incidente

### Sintoma

### Hipótese

### Teste

### Evidência

### Causa

### Correção

### Validação
```

---

# Critérios

| Critério | Pontos |
|---|---:|
| Rede e endereçamento | 10 |
| DHCP funcional e pool correto | 20 |
| Reserva DHCP | 10 |
| DNS direto / zona autoritativa | 20 |
| Reverse + registros adicionais | 10 |
| Testes e integração DHCP–DNS | 10 |
| Troubleshooting do incidente | 15 |
| Organização e documentação | 5 |
| **Total** | **100** |

---

# Importante

A avaliação não mede apenas se a configuração final funciona.

Também serão observados:

- validação antes de reiniciar serviços;
- escolha dos testes;
- interpretação das evidências;
- capacidade de diagnosticar;
- organização dos artefatos.

Ao concluir, faça o commit e o push de sua entrega conforme orientação do professor e encerre sua autenticação GitHub.
