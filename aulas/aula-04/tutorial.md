# Aula 04 — SSH: serviço, porta, configuração e acesso remoto

**Data:** 13/10/2026  
**Duração realizada:** 100 minutos  
**Situação:** aula realizada — registro do SSH será concluído na Aula 05.

---

## Situação-problema

Responder a um `ping` não significa que um serviço de aplicação está disponível.

Nesta aula o SSH foi utilizado para relacionar:

```text
conectividade
serviço
processo
porta
configuração
cliente
servidor
```

Também foi utilizado o **Prompt/terminal do Windows como cliente SSH**.

---

## Objetivos trabalhados

- compreender a função do SSH;
- identificar cliente e servidor SSH;
- consultar o estado do serviço;
- observar a porta em escuta;
- conectar remotamente;
- observar e alterar a configuração do `sshd`;
- validar alterações;
- utilizar o Windows como cliente.

---

# 1. Cliente e servidor

De forma simplificada:

```text
cliente → ssh
servidor → sshd
```

No Linux, o serviço pode ser consultado com:

```bash
systemctl status ssh
```

---

# 2. Porta em escuta

Para verificar portas TCP:

```bash
ss -lnt
```

Para relacionar porta e processo:

```bash
sudo ss -lntp
```

No SSH, a porta padrão é:

```text
TCP/22
```

---

# 3. Acesso remoto

O formato básico utilizado foi:

```bash
ssh USUARIO@ENDERECO
```

No Windows, o mesmo cliente pode ser utilizado pelo Prompt de Comando, PowerShell ou Windows Terminal:

```powershell
ssh USUARIO@ENDERECO
```

Isso permitiu tratar o Windows como **cliente** e o Linux como **servidor SSH**.

---

# 4. Configuração do servidor SSH

O arquivo principal estudado foi:

```text
/etc/ssh/sshd_config
```

Antes de modificar uma configuração importante:

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

Edição:

```bash
sudo nano /etc/ssh/sshd_config
```

Após uma alteração, a configuração deve ser validada:

```bash
sudo sshd -t
```

Se o comando não produzir erro, o serviço pode ser reiniciado:

```bash
sudo systemctl restart ssh
```

E conferido:

```bash
systemctl status ssh
```

---

# 5. Logs

Uma fonte importante de evidências é:

```bash
sudo journalctl -u ssh
```

Últimas linhas:

```bash
sudo journalctl -u ssh -n 30
```

---

# 6. Validação de ponta a ponta

A validação completa exige verificar mais de uma camada:

```text
rede responde?
        ↓
serviço está ativo?
        ↓
porta está em LISTEN?
        ↓
configuração é válida?
        ↓
cliente consegue autenticar?
```

---

# 7. Entrega pendente

A turma realizou alterações relacionadas à configuração do SSH, mas o arquivo configurado ainda não havia sido versionado no portfólio.

Essa pendência será encerrada na **Aula 05**, já no servidor persistente individual.

Não é necessário criar um commit retroativo antes do próximo encontro.
