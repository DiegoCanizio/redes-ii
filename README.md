# Redes de Computadores II

Repositório oficial de materiais da disciplina **Redes de Computadores II**, do curso de **Tecnologia em Sistemas para Internet** do Instituto Federal do Acre (IFAC).

Este repositório reúne os roteiros de aula, arquivos de apoio e materiais necessários às atividades práticas da disciplina.

> **A proposta da disciplina é aprender redes construindo, testando, diagnosticando e reconstruindo serviços reais.**

---

## Professor

**Diego Canizio Lopes**  
Professor EBTT — Instituto Federal do Acre (IFAC)

Área de atuação e pesquisa: Redes de Computadores, Sistemas de Comunicação, 5G/NR e aplicação de Inteligência Artificial ao gerenciamento e à alocação de recursos em redes.

---

## Sobre a disciplina

Redes de Computadores II dá continuidade aos conhecimentos desenvolvidos em Redes de Computadores I, com maior ênfase na **implantação, configuração, operação e diagnóstico de serviços de rede**.

Ao longo da disciplina, serão trabalhados serviços e tecnologias relacionados a:

- configuração de rede no Linux;
- SSH e administração remota;
- captura e análise de tráfego;
- DHCP;
- DNS;
- HTTP e HTTPS;
- FTP, SFTP e SCP;
- SMTP, POP3 e IMAP;
- TLS e certificados;
- firewall com `nftables`;
- proxy e filtragem de conteúdo;
- monitoramento e gerenciamento de redes;
- SNMP;
- Docker e Docker Compose;
- integração e reconstrução de serviços.

A disciplina possui forte componente prático. O objetivo não é apenas executar comandos, mas compreender **o que está acontecendo, como verificar se funcionou e como diagnosticar quando não funcionar**.

---

## Como os roteiros estão organizados

Os roteiros das aulas ficam em:

```text
aulas/
├── aula-01/
│   └── tutorial.md
├── aula-02/
│   └── tutorial.md
├── aula-03/
│   └── tutorial.md
└── ...
```

Cada tutorial pode conter:

- objetivos da aula;
- preparação do ambiente;
- instalação das ferramentas necessárias;
- conceitos essenciais;
- comandos e configurações;
- testes de validação;
- problemas propositais para diagnóstico;
- evidências a serem produzidas;
- atividades de consolidação.

Nas primeiras aulas, os roteiros serão mais detalhados e guiados. Ao longo do semestre, a quantidade de instruções será reduzida progressivamente, exigindo maior autonomia na configuração e no diagnóstico.

---

## Ambiente de laboratório

As atividades utilizam **máquinas virtuais Ubuntu Server**.

Como os computadores do laboratório podem ser restaurados entre os encontros, as VMs devem ser tratadas como ambientes **descartáveis**.

A filosofia de trabalho da disciplina é:

```text
manual
  ↓
documentado
  ↓
versionado
  ↓
scriptado
  ↓
automatizado
  ↓
containerizado
```

Ou, de forma mais direta:

> **Não precisamos preservar a máquina. Precisamos ser capazes de reconstruí-la.**

A topologia básica utilizada ao longo da disciplina será composta por duas VMs:

```text
                         INTERNET
                            │
                           NAT
                    ┌───────┴───────┐
                    │               │
             ┌──────┴──────┐ ┌──────┴──────┐
             │  cli-redes2 │ │ srv-redes2  │
             │   Cliente   │ │  Servidor   │
             └──────┬──────┘ └──────┬──────┘
                    │               │
                    └──── REDES2 ───┘
                       rede interna
```

A interface NAT será utilizada principalmente para acesso externo e instalação de pacotes. A rede interna `REDES2` será utilizada nos experimentos da disciplina.

---

## Git e GitHub na disciplina

O GitHub será utilizado para separar **material didático** de **trabalho produzido pelo estudante**.

### Este repositório

```text
https://github.com/DiegoCanizio/redes-ii
```

É o **repositório oficial da disciplina**.

Ele é utilizado para disponibilizar:

- tutoriais;
- arquivos iniciais;
- exemplos autorizados;
- materiais de apoio;
- templates.

Os estudantes devem utilizá-lo como fonte de consulta.

> **Os trabalhos dos estudantes não devem ser enviados para este repositório.**

---

## Portfólio individual do estudante

Cada estudante terá um **repositório individual de portfólio**, disponibilizado por meio da infraestrutura de turma adotada pelo professor.

Esse repositório será utilizado durante todo o semestre para armazenar:

```text
configurações
documentação
scripts
relatórios
evidências
testes
artefatos das práticas
```

O fluxo esperado em uma VM restaurada será:

```text
VM limpa
   ↓
instalar Git/GitHub CLI
   ↓
autenticar
   ↓
clonar o repositório individual
   ↓
recuperar o histórico anterior
   ↓
realizar a prática
   ↓
commit
   ↓
push
   ↓
logout
```

Quando a infraestrutura do **Classroom 50** estiver habilitada para a turma, o link de acesso ao portfólio individual será fornecido pelo professor.

---

## Fluxo de autenticação

Nas VMs Ubuntu Server, o método padrão será o GitHub CLI:

```bash
sudo apt update
sudo apt install -y git gh
```

Autenticação:

```bash
gh auth login --web --git-protocol https
gh auth setup-git
```

Ao final da aula:

```bash
gh auth logout
```

A autenticação é temporária e deverá ser encerrada explicitamente em computadores compartilhados.

---

## Diagnóstico antes da correção

Um dos princípios da disciplina é evitar alterações aleatórias quando algo não funciona.

O procedimento básico será:

```text
Sintoma
   ↓
Hipótese
   ↓
Teste
   ↓
Evidência
   ↓
Causa
   ↓
Correção
   ↓
Validação
```

A pergunta não será apenas:

> “Funcionou?”

Mas também:

> “Como você sabe que funcionou?”

E, quando houver falha:

> “Que evidência aponta para a causa?”

---

## Estrutura prevista do repositório

```text
.
├── README.md
├── aulas/
│   ├── aula-01/
│   ├── aula-02/
│   ├── aula-03/
│   └── ...
├── materiais/
├── arquivos/
└── templates/
```

Nem todas as pastas precisam existir desde o início. O repositório será ampliado conforme o avanço da disciplina.

---

## Avaliações

As avaliações terão forte caráter prático.

Entre as habilidades avaliadas estarão:

- implantação de serviços;
- configuração correta;
- integração entre serviços;
- testes;
- interpretação de resultados;
- diagnóstico de falhas;
- correção fundamentada;
- documentação;
- capacidade de reconstruir um ambiente a partir dos artefatos versionados.

Em algumas avaliações, o ambiente poderá ser entregue parcialmente configurado ou propositalmente com falhas.

O objetivo será identificar:

```text
sintoma → causa → correção → validação
```

e não apenas produzir um conjunto de comandos.

---

## Uso de Inteligência Artificial

Ferramentas de IA generativa podem ser utilizadas como apoio ao estudo e à resolução de problemas, conforme orientação do professor.

Entretanto, o estudante deverá ser capaz de:

- explicar as decisões tomadas;
- interpretar os comandos utilizados;
- validar o resultado;
- apresentar evidências;
- diagnosticar falhas;
- realizar alterações solicitadas durante as atividades e avaliações.

A existência de uma configuração pronta não substitui a compreensão de seu funcionamento.

---

## Segurança

Nunca publique em um repositório:

- senhas;
- tokens;
- Personal Access Tokens (PAT);
- chaves privadas;
- arquivos `.env` com credenciais;
- certificados contendo chave privada;
- credenciais de serviços;
- outros segredos.

Arquivos de configuração devem utilizar valores de laboratório ou placeholders quando necessário.

Também é proibido conectar serviços experimentais, especialmente servidores DHCP, diretamente à rede institucional sem orientação do professor.

---

## Materiais da disciplina

Os materiais serão disponibilizados progressivamente.

Consulte a pasta:

```text
aulas/
```

para acessar os roteiros já publicados.

---

## Licença e uso dos materiais

Os materiais deste repositório são destinados ao uso didático na disciplina Redes de Computadores II.

Caso uma licença aberta específica seja adotada posteriormente, ela será indicada neste repositório.
