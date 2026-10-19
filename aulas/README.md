# Aulas — Material dos Estudantes

Esta pasta contém os roteiros públicos da disciplina **Redes de Computadores II**.

## Primeiro bloco

```text
01  Git/GitHub e portfólio
02  Linux + Bash + comandos de rede
03  IPv4 + rotas + Netplan
04  SSH
05  servidor persistente
06  rede cliente-servidor
07  troubleshooting + tcpdump
08  DHCP: protocolo e implantação
09  DHCP: leases + reservas
10  DNS: resolução + dig
11  BIND9
12  integração DHCP + DNS
13  HTTP + Nginx
14  laboratório integrado
15  Avaliação 1
```

## Sobre as Aulas 01 a 04

Esses roteiros foram consolidados após os encontros para refletir o percurso efetivamente realizado pela turma. Eles não devem ser interpretados como novas tarefas retroativas.

## A partir da Aula 05

Os roteiros utilizam a infraestrutura persistente:

```text
PC Windows
    │
    │ SSH
    ▼
srv-r2-sNN
    ├── host0 → gerenciamento
    └── lab0
          │
          ▼
      cli-r2-sNN
```

## Regras permanentes

- não alterar `host0` sem orientação;
- não criar gateway padrão pela `lab0` sem orientação;
- não alterar a porta interna 22 do SSH;
- não versionar senhas, tokens ou chaves privadas;
- validar uma configuração antes de reiniciar um serviço sempre que a ferramenta permitir;
- registrar evidências do funcionamento.

## Entregas

Os commits representam **marcos de competência**, não necessariamente uma entrega por aula.

Aqui não são publicados:

- soluções de avaliações;
- credenciais;
- senhas;
- chaves privadas;
- anotações exclusivas do professor.
