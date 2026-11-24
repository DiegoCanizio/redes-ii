# Aulas — Material dos Estudantes

Esta pasta contém os roteiros públicos da disciplina **Redes de Computadores II**.

## Primeiro bloco

~~~text
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
~~~

## Segundo bloco

~~~text
16  FTP: serviço, autenticação e transferência
17  FTP: modos ativo/passivo, canais de dados e troubleshooting
18  SMTP por dentro e primeira configuração do Postfix
19  Postfix, DNS e registros MX
20  POP3 e IMAP4 com Dovecot
21  Sistema de e-mail integrado
22  TLS aplicado ao correio eletrônico
23  Firewall com nftables
24  Firewall aplicado e troubleshooting
25  Proxy e filtragem de conteúdo com Squid
26  Análise de pacotes com tcpdump
27  Troubleshooting integrado de serviços
28  Integração e comissionamento da infraestrutura
29  Checkpoint e preparação para a Avaliação 2
30  Avaliação 2
~~~

## Organização dos tutoriais a partir da Aula 16

Os tutoriais do segundo bloco **não possuem datas fixas**.

A numeração representa a sequência didática, não necessariamente um encontro de calendário.

Cada tutorial foi planejado como um **bloco de referência de aproximadamente 100 minutos**. Em encontros de 150 minutos, o professor poderá utilizar o tempo adicional para aprofundamento, troubleshooting, validação, portfólio ou início do bloco seguinte.

A estrutura pedagógica adotada é:

~~~text
conceito e arquitetura
        ↓
implantação guiada
        ↓
validação funcional
        ↓
ferramentas de diagnóstico
        ↓
troubleshooting sem roteiro de correção
~~~

Os comandos de implantação, diagnóstico e validação continuam sendo apresentados explicitamente.

Nas atividades de troubleshooting, o aluno recebe o sintoma, os requisitos ou o estado esperado, mas deve selecionar ferramentas, interpretar evidências, localizar a causa, corrigir e validar.

Método da disciplina:

~~~text
Sintoma
→ Hipótese
→ Teste
→ Evidência
→ Causa
→ Correção
→ Validação
~~~

## Distribuição de carga do segundo bloco

As Aulas 16 a 30 representam **15 blocos de 100 minutos**, equivalentes a **30 horas-aula**.

Como após a Avaliação 1 restam 32 horas-aula da disciplina, permanecem **2 horas-aula de margem** para ajustes de calendário, extensão de encontros, recuperação, aprofundamento ou necessidades institucionais.

Essa margem não está vinculada a um tutorial específico.

## Infraestrutura persistente

Os roteiros utilizam:

~~~text
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
~~~

Todos os estudantes podem utilizar a mesma rede interna porque cada laboratório é isolado.

## Regras permanentes

- não alterar `host0` sem orientação;
- não criar gateway padrão pela `lab0` sem orientação;
- não alterar a porta interna 22 do SSH;
- não versionar senhas, tokens ou chaves privadas;
- validar uma configuração antes de reiniciar ou recarregar um serviço sempre que a ferramenta permitir;
- registrar evidências do funcionamento;
- durante troubleshooting, aplicar mudanças orientadas por evidências.

## Entregas

Os commits representam **marcos de competência**, não necessariamente uma entrega por aula.

Aqui não são publicados:

- soluções de avaliações;
- credenciais;
- senhas;
- chaves privadas;
- anotações exclusivas do professor.

## Calendário

Datas, alterações de horário e redistribuição entre encontros devem permanecer fora dos tutoriais sempre que possível.

Isso permite ajustar o calendário sem modificar materiais cujo conteúdo técnico continua válido.
