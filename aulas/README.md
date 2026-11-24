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
16  FTP com vsftpd
17  SMTP e Postfix
18  SMTP, DNS e registros MX
19  POP3 e IMAP4 com Dovecot
20  Sistema de e-mail integrado
21  TLS aplicado ao correio eletrônico
22  Firewall com nftables
23  Firewall aplicado e troubleshooting
24  Proxy e filtragem de conteúdo com Squid
25  Análise de pacotes com tcpdump
26  Laboratório integrado
27  Avaliação 2
~~~

## Organização dos tutoriais a partir da Aula 16

Os tutoriais do segundo bloco não possuem datas fixas.

A numeração representa a **sequência de conteúdo**, não necessariamente um encontro de calendário.

Isso permite utilizar um tutorial inteiro em uma aula de 100 minutos, combinar partes em encontros de 150 minutos ou redistribuir conteúdos sem modificar o material didático.

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

Nas atividades de troubleshooting, o aluno recebe o sintoma e o estado esperado, mas deve selecionar as ferramentas, interpretar evidências, localizar a causa, corrigir e validar.

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

## Infraestrutura persistente

Os roteiros utilizam a infraestrutura:

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
- utilizar mudanças orientadas por evidências durante troubleshooting.

## Entregas

Os commits representam **marcos de competência**, não necessariamente uma entrega por aula.

Aqui não são publicados:

- soluções de avaliações;
- credenciais;
- senhas;
- chaves privadas;
- anotações exclusivas do professor.

## Observação sobre calendário

Datas, alterações de horário e redistribuição entre encontros devem ser mantidas fora dos tutoriais sempre que possível.

Isso evita que um ajuste de calendário obrigue a modificar materiais cujo conteúdo técnico continua válido.
