# Aula 16 — FTP com vsftpd

## Objetivos

Ao final desta aula, você deverá conseguir:

- explicar a diferença entre canal de controle e canal de dados no FTP;
- configurar um servidor FTP com autenticação local;
- realizar upload e download em modo passivo;
- reconhecer a diferença entre modo ativo e passivo;
- validar serviço, porta, autenticação, permissões e transferência;
- utilizar logs e captura de pacotes como evidência;
- diagnosticar um incidente sem receber um roteiro de correção.

A rede de laboratório continua sendo:

~~~text
servidor
lab0: 192.168.50.10/24
        │
        │ FTP
        ▼
cliente
lab0: endereço obtido por DHCP
~~~

> Use senhas temporárias de laboratório. Não reutilize credenciais pessoais, institucionais ou do GitHub.

---

## 1. Como o FTP funciona

O FTP utiliza mais de uma conexão.

~~~text
cliente
   │
   │ TCP/21
   ▼
servidor FTP
   │
   └── canal de controle

cliente ◄────────────► servidor
        canal de dados
~~~

O canal TCP/21 transporta comandos como autenticação, mudança de diretório e solicitação de transferência.

A transferência de dados utiliza outra conexão.

No modo passivo, o servidor informa uma porta de dados e o cliente inicia a conexão até ela.

No modo ativo, o cliente informa onde receberá a conexão de dados e o servidor inicia essa segunda conexão.

---

## 2. Instale as ferramentas

No servidor:

~~~bash
sudo apt update
sudo apt install -y vsftpd tcpdump
~~~

No cliente:

~~~bash
sudo apt update
sudo apt install -y lftp tcpdump
~~~

No servidor, observe inicialmente:

~~~bash
systemctl status vsftpd --no-pager
sudo ss -lntp | grep ':21'
~~~

---

## 3. Crie um usuário de laboratório

No servidor:

~~~bash
sudo adduser ftpuser
~~~

Defina uma senha temporária.

Crie um arquivo que será baixado posteriormente:

~~~bash
sudo -u ftpuser bash -c   'echo "Arquivo disponibilizado pelo servidor FTP" > /home/ftpuser/servidor.txt'
~~~

Confira:

~~~bash
sudo -u ftpuser ls -l /home/ftpuser
~~~

---

## 4. Configure o vsftpd

Faça backup:

~~~bash
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.original
~~~

Edite:

~~~bash
sudo nano /etc/vsftpd.conf
~~~

Utilize como configuração de laboratório:

~~~conf
listen=YES
listen_ipv6=NO

anonymous_enable=NO
local_enable=YES
write_enable=YES

chroot_local_user=YES
allow_writeable_chroot=YES

pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40010
~~~

Reinicie:

~~~bash
sudo systemctl restart vsftpd
~~~

Verifique:

~~~bash
systemctl is-active vsftpd
sudo ss -lntp | grep ':21'
sudo journalctl -u vsftpd -n 20 --no-pager
~~~

Diferentemente de Kea, BIND e Nginx, o vsftpd não fornece no nosso fluxo um validador prévio equivalente aos comandos usados anteriormente. Por isso, após a alteração, o estado do serviço e o journal tornam-se especialmente importantes.

---

## 5. Faça a primeira conexão

No cliente:

~~~bash
echo "Arquivo criado no cliente" > arquivo-cliente.txt
~~~

Conecte:

~~~bash
lftp -u ftpuser ftp://192.168.50.10
~~~

Informe a senha temporária.

Dentro do lftp:

~~~text
pwd
ls
get servidor.txt
put arquivo-cliente.txt
ls
bye
~~~

No cliente:

~~~bash
ls -l servidor.txt
cat servidor.txt
~~~

No servidor:

~~~bash
sudo -u ftpuser ls -l /home/ftpuser
~~~

Você deve conseguir demonstrar:

~~~text
autenticação
+
listagem
+
download
+
upload
~~~

---

## 6. Observe o modo passivo

Abra novamente o lftp:

~~~bash
lftp -u ftpuser ftp://192.168.50.10
~~~

Dentro da sessão:

~~~text
set ftp:passive-mode true
debug 3
ls
~~~

Observe que a sessão de controle permanece em TCP/21, enquanto uma segunda conexão é criada para os dados.

No servidor, em outro terminal:

~~~bash
sudo tcpdump -ni lab0   'tcp port 21 or portrange 40000-40010'
~~~

Faça uma transferência e associe os pacotes às duas funções.

---

## 7. Compare com o modo ativo

No lftp:

~~~text
set ftp:passive-mode false
ls
~~~

Depois retorne:

~~~text
set ftp:passive-mode true
~~~

Registre em seu portfólio a diferença observada.

Não é necessário decorar comandos internos de FTP. O importante é compreender quem inicia a conexão de dados em cada modo.

---

## 8. Observe o canal de controle

No servidor:

~~~bash
sudo tcpdump -ni lab0 -nn -A 'tcp port 21'
~~~

No cliente, faça uma nova autenticação usando somente a senha temporária.

Observe comandos do protocolo, inclusive USER e PASS.

Responda no portfólio:

- a autenticação FTP deste laboratório está protegida por criptografia?
- o conteúdo do canal de controle pode ser observado?
- por que não devemos reutilizar uma senha real neste experimento?

---

## 9. Ferramentas de diagnóstico e validação

### Serviço

~~~bash
systemctl status vsftpd --no-pager
systemctl is-active vsftpd
~~~

Pergunta respondida: o processo do serviço está ativo?

### Porta

~~~bash
sudo ss -lntp | grep ':21'
~~~

Pergunta respondida: existe processo escutando em TCP/21?

### Logs

~~~bash
sudo journalctl -u vsftpd -n 50 --no-pager
~~~

Pergunta respondida: o serviço registrou erro de inicialização, autenticação ou sessão?

### Cliente com depuração

~~~bash
lftp -d -u ftpuser ftp://192.168.50.10
~~~

Pergunta respondida: em qual etapa a sessão FTP está falhando?

### Sistema de arquivos

~~~bash
id ftpuser
ls -ld /home/ftpuser
ls -l /home/ftpuser
~~~

Pergunta respondida: o usuário possui permissões compatíveis com a operação solicitada?

### Tráfego

~~~bash
sudo tcpdump -ni lab0   'tcp port 21 or portrange 40000-40010'
~~~

Pergunta respondida: a conexão chegou ao servidor e houve tentativa de estabelecer o canal de dados?

---

## 10. Troubleshooting

O professor introduzirá uma falha no ambiente.

Você receberá apenas o sintoma e o estado final esperado.

Exemplo de sintoma possível:

~~~text
O usuário consegue autenticar.
A listagem funciona.
O download funciona.
O upload falha.
~~~

Não altere várias configurações ao mesmo tempo.

Utilize o método:

~~~text
Sintoma
→ Hipótese
→ Teste
→ Evidência
→ Causa
→ Correção
→ Validação
~~~

As ferramentas ensinadas nesta aula e nas aulas anteriores estão disponíveis, mas a escolha da sequência de testes faz parte do exercício.

---

## 11. Portfólio

Organize:

~~~text
transferencia/aula-16/
├── README.md
└── vsftpd.conf
~~~

Copie a configuração sem incluir senhas:

~~~bash
sudo cp /etc/vsftpd.conf ~/vsftpd-aula16.conf
~~~

Leve o arquivo ao seu portfólio conforme o fluxo já utilizado na disciplina.

O README deve conter:

~~~markdown
# Aula 16 — FTP

## Arquitetura
- canal de controle:
- canal de dados:
- modo passivo:
- modo ativo:

## Configuração
- endereço do servidor:
- porta de controle:
- faixa passiva:

## Validação
- serviço:
- porta:
- autenticação:
- upload:
- download:

## Captura
O que foi observado no canal de controle?

## Troubleshooting
### Sintoma
### Hipótese
### Testes e evidências
### Causa
### Correção
### Validação

## Síntese
Explique por que verificar apenas a porta 21 não é suficiente para validar completamente uma transferência FTP.
~~~

Versione somente arquivos apropriados. Não registre senhas.
