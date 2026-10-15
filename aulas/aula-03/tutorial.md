# Aula 03 — Interfaces, endereçamento, rotas e Netplan

**Data:** 08/10/2026  
**Duração realizada:** 150 minutos  
**Situação:** aula realizada — roteiro consolidado posteriormente.

> Esta aula utilizou o ambiente virtual disponível naquele momento. O roteiro registra os conceitos trabalhados e não exige uma nova entrega retroativa.

---

## Objetivos trabalhados

Neste encontro foram abordados:

- identificação de interfaces;
- observação do endereço IPv4;
- testes de conectividade;
- tabela de rotas;
- diferença entre endereço e rota;
- alteração de endereço IPv4;
- configuração de rede com Netplan;
- validação da configuração.

---

# 1. Observando a rede

Foram utilizados comandos como:

```bash
ifconfig
ip addr
ip -br addr
route
ip route
ping -c 3 1.1.1.1
```

A leitura das informações passou a responder perguntas como:

```text
Qual interface está ativa?
Qual endereço ela possui?
Qual é a rota padrão?
Por qual interface o tráfego sai?
Existe conectividade?
```

---

# 2. Endereçamento IPv4

Trabalhamos a associação entre interface e endereço.

Exemplo:

```text
192.168.50.10/24
```

O prefixo `/24` corresponde à máscara:

```text
255.255.255.0
```

Dois endereços como:

```text
192.168.50.10/24
192.168.50.20/24
```

pertencem à mesma rede:

```text
192.168.50.0/24
```

---

# 3. Rotas

A tabela de rotas foi observada com:

```bash
ip route
```

ou, no comando utilizado inicialmente:

```bash
route
```

A rota padrão indica para onde o sistema envia pacotes quando não existe uma rota mais específica.

Exemplo conceitual:

```text
default via <GATEWAY> dev <INTERFACE>
```

---

# 4. Netplan

A configuração persistente de rede foi realizada com Netplan.

Antes de alterar um arquivo de configuração, é recomendável criar uma cópia:

```bash
sudo cp /etc/netplan/ARQUIVO.yaml /etc/netplan/ARQUIVO.yaml.bak
```

A edição pode ser realizada com:

```bash
sudo nano /etc/netplan/ARQUIVO.yaml
```

Exemplo conceitual:

```yaml
network:
  version: 2
  ethernets:
    INTERFACE:
      dhcp4: false
      addresses:
        - 192.168.50.10/24
```

> O nome da interface deve ser o nome real identificado no sistema.

---

# 5. Validação

Antes de aplicar:

```bash
sudo netplan generate
```

Quando disponível e apropriado:

```bash
sudo netplan try
```

Depois da aplicação, a configuração deve ser verificada novamente:

```bash
ip -br addr
ip route
```

E testada:

```bash
ping -c 3 <DESTINO>
```

---

# 6. Aprendizado importante

Uma alteração de rede deve seguir:

```text
observar estado atual
        ↓
alterar configuração
        ↓
validar sintaxe
        ↓
aplicar
        ↓
observar novamente
        ↓
testar conectividade
```

Evite alterar endereços, gateways e rotas aleatoriamente para "ver se funciona".

---

## Relação com o novo laboratório

A partir da Aula 05, esses conhecimentos serão reutilizados no servidor individual.

A principal diferença será:

```text
host0
→ gerenciamento
→ não será alterada pelos experimentos

lab0
→ rede de laboratório
→ será configurada nas práticas
```

A experiência adquirida com Netplan continua válida, mas agora teremos uma interface explicitamente reservada para os experimentos.
