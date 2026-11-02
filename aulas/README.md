# Aulas — Material dos Estudantes

Esta pasta contém os roteiros públicos da disciplina **Redes de Computadores II**.

## Primeiro bloco

```text
01  Git, GitHub e início do portfólio
02  Linux básico, comandos de rede e primeiro script Bash
03  Interfaces, endereçamento, rotas e Netplan
04  SSH: serviço, porta, configuração e acesso remoto
05  Meu Servidor de Redes II: ambiente persistente e consolidação do SSH
06  Rede individual cliente-servidor com systemd-networkd
07  Troubleshooting e DHCP inicial
08  DHCP: leases, reserva e diagnóstico
09  DNS por dentro, BIND e primeira zona direta
10  DNS reverso, validação e diagnóstico
11  Integração DHCP + DNS e troubleshooting integrado
12  HTTP por dentro
13  Nginx, virtual host, DNS e logs
14  Laboratório integrado e checkpoint
15  Avaliação 1
```

## Calendário atualizado — novembro de 2026

| Data | Atividade |
|---|---|
| 27/10 | Aula 8 — realizada e validada |
| 29/10 | Aula 9 — realizada e validada |
| 03/11 | Aula 10 — DNS reverso e consultas |
| 05/11 | Conferência da integração DHCP/DNS, HTTP básico e introdução ao Nginx — aulas 11, 12 e início da 13 |
| 10 e 12/11 | Eventos prováveis; sem conteúdo novo previsto |
| 17/11 | Continuação da aula 13 — virtual host, acesso por nome, logs e diagnóstico |
| 19/11 | Sem aula |
| 24/11 | Aula 14 — laboratório integrado e revisão |
| 26/11 | Aula 15 — Avaliação 1 |

Os números identificam os blocos de conteúdo. Dois tutoriais podem ser utilizados no mesmo encontro. Os eventos são contabilizados como encontros, sem acrescentar conteúdo aos tutoriais. As aulas 1 a 9 já foram utilizadas e testadas. A aula 8 ocorreu em 27/10/2026 e a aula 9 em 29/10/2026; até a aula 9, tudo funcionou conforme relato do professor.

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
