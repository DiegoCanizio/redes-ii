# Aula 06 — Rede individual cliente-servidor

**Data:** 20/10/2026  
**Duração:** 100 minutos

---

## Situação-problema

Até agora você acessou principalmente seu servidor por `host0`.

Hoje começa a rede experimental da disciplina:

```text
Windows
   │
   │ SSH
   ▼
srv-r2-sNN
   ├── host0 → gerenciamento
   └── lab0: 192.168.50.10/24
               │
               │
               ▼
          cli-r2-sNN
          lab0: 192.168.50.20/24
```

Ao final da aula, servidor e cliente deverão se comunicar pela `lab0`, sem alterar a interface de gerenciamento.

---

# Objetivos

Ao final, você deverá conseguir:

- distinguir `host0` e `lab0`;
- configurar IPv4 estático somente na rede de laboratório;
- validar uma configuração Netplan;
- testar comunicação entre servidor e cliente;
- interpretar `ip addr`, `ip route` e `ip neigh`;
- acessar o cliente a partir do servidor;
- preservar o acesso administrativo do servidor.

---

# 1. Entre no servidor

No Windows:

```powershell
ssh -p SUA_PORTA SEU_USUARIO@172.16.2.34
```

No servidor:

```bash
whoami
hostname
ip -br addr
ip route
```

Confirme:

```text
[ ] host0 existe
[ ] lab0 existe
[ ] a rota default não utiliza lab0
```

---

# 2. Regra da aula

A configuração experimental será feita **somente em `lab0`**.

Não modifique:

```text
host0
```

Não crie em `lab0`:

```text
gateway4
default route
rota default
```

---

# 3. Faça backup da configuração atual

Veja os arquivos existentes:

```bash
ls -l /etc/netplan/
```

Crie uma pasta de backup:

```bash
sudo mkdir -p /root/backup-netplan-aula06
```

Copie:

```bash
sudo cp -a /etc/netplan/. /root/backup-netplan-aula06/
```

---

# 4. Configure `lab0` no servidor

Crie:

```bash
sudo nano /etc/netplan/90-redes2-lab.yaml
```

Conteúdo:

```yaml
network:
  version: 2
  ethernets:
    lab0:
      dhcp4: false
      addresses:
        - 192.168.50.10/24
```

Valide a sintaxe:

```bash
sudo netplan generate
```

Se não houver erro:

```bash
sudo netplan apply
```

Verifique:

```bash
ip -br addr show lab0
```

Resultado esperado:

```text
lab0    UP    192.168.50.10/24
```

---

# 5. Observe as rotas novamente

```bash
ip route
```

Você deverá encontrar uma rota para:

```text
192.168.50.0/24
```

pela `lab0`.

A rota `default` deve continuar associada à interface de gerenciamento.

Responda:

```text
Rede conectada pela lab0:
____________________________________

Interface da rota default:
____________________________________
```

---

# 6. Acesso inicial ao cliente

O professor ativará seu cliente e disponibilizará o acesso inicial.

Do **servidor**, teste:

```bash
ping -c 3 192.168.50.20
```

Se houver resposta:

```bash
ssh SEU_USUARIO@192.168.50.20
```

Use a credencial indicada pelo professor para o cliente.

Depois confirme:

```bash
whoami
hostname
ip -br addr
```

O hostname deverá seguir o padrão:

```text
cli-r2-sNN
```

---

# 7. Configure `lab0` no cliente

No cliente:

```bash
sudo mkdir -p /root/backup-netplan-aula06
sudo cp -a /etc/netplan/. /root/backup-netplan-aula06/
```

Crie:

```bash
sudo nano /etc/netplan/90-redes2-lab.yaml
```

Conteúdo:

```yaml
network:
  version: 2
  ethernets:
    lab0:
      dhcp4: false
      addresses:
        - 192.168.50.20/24
```

Valide:

```bash
sudo netplan generate
```

Aplique:

```bash
sudo netplan apply
```

Confira:

```bash
ip -br addr show lab0
ip route
```

> O cliente não precisa de gateway na `lab0` para conversar com o servidor na mesma rede.

---

# 8. Teste nos dois sentidos

No cliente:

```bash
ping -c 3 192.168.50.10
```

No servidor:

```bash
ping -c 3 192.168.50.20
```

Agora observe a tabela de vizinhos:

```bash
ip neigh
```

Localize o endereço da outra máquina.

---

# 9. O que `ip neigh` mostrou?

Ethernet não utiliza somente endereços IPv4.

Depois da comunicação, o sistema pode armazenar uma associação entre:

```text
IPv4
  ↕
endereço MAC
```

Registre uma linha observada:

```text
____________________________________________________________
```

---

# 10. Teste SSH pela rede de laboratório

A partir do servidor:

```bash
ssh SEU_USUARIO@192.168.50.20
```

Pergunta:

### Esta conexão utiliza a porta externa `22NN` do host?

```text
☐ Sim
☐ Não
```

Explique:

```text
____________________________________________________________
```

---

# 11. Prepare a evidência da atividade

No servidor, entre no seu portfólio:

```bash
cd ~/SEU_REPOSITORIO
```

Crie:

```bash
mkdir -p rede/aula-06
```

Salve a configuração do servidor:

```bash
sudo cat /etc/netplan/90-redes2-lab.yaml \
  > rede/aula-06/netplan-servidor.yaml
```

A partir do cliente, copie ou registre a configuração utilizada nele.

Crie:

```bash
nano rede/aula-06/README.md
```

Inclua:

```markdown
# Aula 06 — Rede individual

## Topologia

Servidor:
Cliente:
Rede:

## Interfaces

### Servidor
- host0:
- lab0:

### Cliente
- lab0:

## Testes
- servidor → cliente:
- cliente → servidor:

## Rotas
- rota da rede de laboratório:
- rota default do servidor:

## Conclusão
Explique por que host0 e lab0 possuem funções diferentes.
```

---

# 12. Não faça o commit ainda

A Aula 06 e a Aula 07 formam um único marco:

```text
rede + troubleshooting
```

Por enquanto:

```bash
git status
```

Confira se os arquivos estão no local correto.

O commit será concluído após a atividade de diagnóstico da Aula 07.

---

# Checklist

```text
[ ] host0 foi preservada.
[ ] servidor possui 192.168.50.10/24 em lab0.
[ ] cliente possui 192.168.50.20/24 em lab0.
[ ] não existe gateway padrão pela lab0.
[ ] servidor pinga cliente.
[ ] cliente pinga servidor.
[ ] observei ip neigh.
[ ] acessei o cliente via SSH pela rede interna.
[ ] documentei a topologia no portfólio.
```
