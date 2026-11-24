# Aula 16 — FTP: serviço, autenticação e transferência

**Bloco de referência:** 100 minutos

## Objetivos

Ao final desta aula, você deverá conseguir:

- explicar a função do FTP;
- identificar o canal de controle em TCP/21;
- instalar e configurar o vsftpd;
- autenticar com usuário local;
- realizar listagem, download e upload;
- validar serviço, porta, autenticação e permissões;
- utilizar logs e cliente FTP como ferramentas de diagnóstico.

A rede de laboratório permanece:

~~~text
srv-r2-sNN
lab0: 192.168.50.10/24
        │
        │ FTP
        ▼
cli-r2-sNN
lab0: configuração recebida por DHCP
~~~

> Utilize somente senhas temporárias de laboratório. Não reutilize credenciais pessoais, institucionais ou do GitHub.

---

## 1. O que o FTP resolve

O FTP é um protocolo de transferência de arquivos.

Nesta primeira aula, observe principalmente:

~~~text
cliente
   │
   │ TCP/21
   ▼
servidor FTP
   │
   ├── autenticação
   ├── listagem
   ├── download
   └── upload
~~~

O FTP utiliza uma conexão de controle e outra conexão para dados. A diferença entre modo ativo e passivo será aprofundada na Aula 17.

## 2. Instale as ferramentas

No servidor:

~~~bash
sudo apt update
sudo apt install -y vsftpd
~~~

No cliente:

~~~bash
sudo apt update
sudo apt install -y lftp netcat-openbsd
~~~

No servidor:

~~~bash
systemctl status vsftpd --no-pager
sudo ss -lntp | grep ':21'
~~~

## 3. Crie um usuário de laboratório

~~~bash
sudo adduser ftpuser
~~~

Defina uma senha temporária.

Crie um arquivo para download:

~~~bash
sudo -u ftpuser bash -c \
  'echo "Arquivo disponibilizado pelo servidor FTP" > /home/ftpuser/servidor.txt'
~~~

## 4. Configure o vsftpd

Faça backup:

~~~bash
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.original
~~~

Edite:

~~~bash
sudo nano /etc/vsftpd.conf
~~~

Utilize:

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

Valide:

~~~bash
systemctl is-active vsftpd
sudo ss -lntp | grep ':21'
sudo journalctl -u vsftpd -n 20 --no-pager
~~~

## 5. Faça a primeira transferência

No cliente:

~~~bash
echo "Arquivo criado no cliente" > arquivo-cliente.txt
lftp -u ftpuser ftp://192.168.50.10
~~~

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
cat servidor.txt
~~~

No servidor:

~~~bash
sudo -u ftpuser ls -l /home/ftpuser
~~~

Estado final esperado:

~~~text
[ ] autenticação funciona
[ ] listagem funciona
[ ] download funciona
[ ] upload funciona
~~~

## 6. Ferramentas de diagnóstico e validação

Serviço:

~~~bash
systemctl is-active vsftpd
~~~

Porta:

~~~bash
sudo ss -lntp | grep ':21'
~~~

Conectividade:

~~~bash
nc -vz 192.168.50.10 21
~~~

Cliente detalhado:

~~~bash
lftp -d -u ftpuser ftp://192.168.50.10
~~~

Permissões:

~~~bash
id ftpuser
ls -ld /home/ftpuser
ls -l /home/ftpuser
~~~

Logs:

~~~bash
sudo journalctl -u vsftpd -n 50 --no-pager
~~~

Cada ferramenta responde a uma pergunta diferente. Não trate toda falha FTP como problema de rede.

## 7. Troubleshooting

O professor poderá introduzir uma falha simples.

Exemplo:

~~~text
A conexão TCP/21 funciona.
O usuário autentica.
O upload falha.
~~~

Você receberá o sintoma e o estado esperado, não a sequência de correção.

Use:

~~~text
Sintoma
→ Hipótese
→ Teste
→ Evidência
→ Causa
→ Correção
→ Validação
~~~

## 8. Portfólio

Organize:

~~~text
transferencia/aula-16/
├── README.md
└── vsftpd.conf
~~~

Registre configuração, validações, ferramentas utilizadas e troubleshooting. Não registre a senha temporária.