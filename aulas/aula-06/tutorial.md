# Aula 06 — Rede individual cliente-servidor com systemd-networkd

**Duração:** 100 minutos

## Contexto

Nesta aula ocorreu um problema real de infraestrutura. O diretório `/etc/netplan/` estava vazio nos containers e, mesmo após a criação de arquivos YAML, o Netplan apresentou erros, incluindo permissões e `Failed to send request`, embora `systemd-networkd` estivesse ativo.

Isso permitiu observar uma relação importante:

```text
Netplan
   ↓ gera configuração
systemd-networkd
   ↓ configura
interfaces
```

No ambiente `systemd-nspawn` da disciplina, passaremos a configurar a interface experimental diretamente com `systemd-networkd`.

O conhecimento de Netplan permanece válido para outros ambientes Ubuntu e não é descartado.

---

## Objetivos

- distinguir `host0` e `lab0`;
- compreender a relação entre Netplan e `systemd-networkd`;
- configurar IPv4 persistente na `lab0`;
- testar comunicação cliente-servidor;
- acessar o cliente pela rede interna;
- preservar a interface administrativa.

---

## 1. Topologia

```text
PC Windows
   │ SSH :22NN
   ▼
srv-r2-sNN
├── host0 → gerenciamento/Internet
└── lab0  → 192.168.50.10/24
              │
              ▼
           lab0
       cli-r2-sNN
       192.168.50.20/24
```

Todos os estudantes podem utilizar `192.168.50.0/24` porque cada laboratório é isolado.

---

## 2. Regra principal

Não altere:

```text
host0
rota default da host0
SSH administrativo
porta interna 22
```

A interface de experimentação é:

```text
lab0
```

---

## 3. Observe o ambiente

```bash
whoami
hostname
ip -br addr
ip route
systemctl is-active systemd-networkd
ls -l /etc/systemd/network/
ls -l /etc/netplan/
```

Resultado esperado para o serviço:

```text
active
```

O diretório `/etc/netplan/` pode estar vazio neste laboratório.

---

## 4. Configure a `lab0` do servidor

Crie:

```bash
sudo nano /etc/systemd/network/80-lab0.network
```

Conteúdo:

```ini
[Match]
Name=lab0

[Network]
Address=192.168.50.10/24
LinkLocalAddressing=no
IPv6AcceptRA=no
```

---

## 5. Recarregue

```bash
sudo networkctl reload
sudo networkctl reconfigure lab0
```

Confira:

```bash
ip -br addr show lab0
```

Esperado:

```text
lab0    UP    192.168.50.10/24
```

### Se a interface não for reaplicada imediatamente

A configuração persistente continua no arquivo `.network`. O estado atual pode ser ajustado com:

```bash
sudo ip link set lab0 up
sudo ip -4 addr flush dev lab0
sudo ip addr add 192.168.50.10/24 dev lab0
```

Distinção:

```text
/etc/systemd/network/80-lab0.network
→ configuração persistente

ip addr add
→ estado atual da interface
```

---

## 6. Verifique as rotas

```bash
ip route
```

Deve existir:

```text
192.168.50.0/24 dev lab0
```

A rota `default` deve continuar pela interface de gerenciamento.

Não configure gateway na `lab0`.

---

## 7. Cliente

O cliente foi preparado com:

```text
cli-r2-sNN
lab0 = 192.168.50.20/24
```

Arquivo:

```text
/etc/systemd/network/80-lab0.network
```

Conteúdo:

```ini
[Match]
Name=lab0

[Network]
Address=192.168.50.20/24
LinkLocalAddressing=no
IPv6AcceptRA=no
```

---

## 8. Teste a comunicação

No servidor:

```bash
ping -c 3 192.168.50.20
```

Depois:

```bash
ssh SEU_USUARIO@192.168.50.20
```

O cliente utiliza o mesmo usuário do servidor e a senha inicial fornecida pela disciplina. Não é necessário trocar a senha do cliente.

No cliente:

```bash
whoami
hostname
ip -br addr
ip route
ping -c 3 192.168.50.10
```

---

## 9. Observe a vizinhança

```bash
ip neigh
```

Relacione o IPv4 da outra máquina ao respectivo endereço MAC.

---

## 10. O incidente do Netplan

Registre:

```text
Por que não continuamos usando Netplan neste laboratório?

Qual serviço gerencia diretamente as interfaces?

Qual a diferença entre configuração persistente e alteração feita com `ip addr`?
```

---

## 11. Portfólio

```bash
mkdir -p rede/aula-06
```

Salve a configuração:

```bash
sudo cat /etc/systemd/network/80-lab0.network   > rede/aula-06/80-lab0-servidor.network
```

Crie `rede/aula-06/README.md` contendo:

```markdown
# Aula 06 — Rede individual

## Topologia
Servidor:
Cliente:
Rede:

## Interfaces
Servidor host0:
Servidor lab0:
Cliente lab0:

## Persistência
Ferramenta:
Arquivo:

## Testes
Servidor → cliente:
Cliente → servidor:
SSH pela lab0:

## Netplan e systemd-networkd
Explique o problema encontrado e a solução adotada.

## Conclusão
Explique a diferença entre host0 e lab0.
```

---

## 12. Commit

```bash
git status
git add rede/aula-06/
git commit -m "Configura rede de laboratorio com systemd-networkd"
git push
```

---

## Checklist

```text
[ ] preservei host0.
[ ] servidor possui 192.168.50.10/24.
[ ] cliente possui 192.168.50.20/24.
[ ] servidor e cliente se comunicam.
[ ] acessei o cliente via SSH.
[ ] observei rotas e vizinhança.
[ ] compreendi Netplan x systemd-networkd.
[ ] documentei a solução.
[ ] concluí o commit da Aula 06.
```
