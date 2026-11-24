# Aula 17 — FTP: modos ativo/passivo, canais de dados e troubleshooting

**Bloco de referência:** 100 minutos

## Objetivos

Ao final desta aula, você deverá conseguir:

- explicar por que FTP utiliza mais de uma conexão;
- diferenciar canal de controle e canal de dados;
- diferenciar modo ativo e modo passivo;
- observar a faixa de portas passivas;
- utilizar tcpdump para acompanhar uma transferência;
- relacionar falhas de upload/download a serviço, permissões ou canal de dados;
- diagnosticar um incidente FTP sem roteiro de correção.

Esta aula utiliza o servidor FTP construído na Aula 16.

## 1. Revise o estado inicial

Servidor:

~~~bash
systemctl is-active vsftpd
sudo ss -lntp | grep ':21'
~~~

Cliente:

~~~bash
lftp -u ftpuser ftp://192.168.50.10
~~~

Faça uma listagem e encerre.

## 2. Controle x dados

~~~text
TCP/21
  │
  └── canal de controle

outra conexão
  │
  └── canal de dados
~~~

A porta 21 estar acessível não garante que uma transferência de dados funcione.

## 3. Modo passivo

A configuração utiliza:

~~~conf
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40010
~~~

No cliente:

~~~bash
lftp -u ftpuser ftp://192.168.50.10
~~~

Dentro da sessão:

~~~text
set ftp:passive-mode true
debug 3
ls
get servidor.txt
~~~

## 4. Capture controle e dados

No servidor:

~~~bash
sudo tcpdump -ni lab0 -nn \
  'tcp port 21 or portrange 40000-40010'
~~~

No cliente, faça listagem, download e upload.

Identifique a conexão de controle e a conexão de dados.

## 5. Observe o canal de controle

~~~bash
sudo tcpdump -ni lab0 -nn -A 'tcp port 21'
~~~

Autentique utilizando somente a senha temporária.

Registre se usuário e senha aparecem em texto claro.

## 6. Modo ativo

No lftp:

~~~text
set ftp:passive-mode false
debug 3
ls
~~~

Depois retorne:

~~~text
set ftp:passive-mode true
bye
~~~

Compare quem inicia a conexão de dados.

## 7. Permissões e escrita

No servidor:

~~~bash
id ftpuser
ls -ld /home/ftpuser
sudo -u ftpuser mkdir -p /home/ftpuser/upload
ls -ld /home/ftpuser/upload
~~~

No cliente, teste upload para esse diretório.

Uma operação FTP depende de configuração do serviço, autenticação, permissões e canal de dados.

## 8. Ferramentas de diagnóstico e validação

~~~bash
systemctl status vsftpd --no-pager
sudo ss -lntp | grep ':21'
lftp -d -u ftpuser ftp://192.168.50.10
id ftpuser
namei -l /home/ftpuser/upload
sudo journalctl -u vsftpd -n 50 --no-pager
sudo tcpdump -ni lab0 -nn 'tcp port 21 or portrange 40000-40010'
~~~

## 9. Troubleshooting

Possíveis sintomas:

~~~text
login funciona, mas listagem trava
download funciona, mas upload falha
TCP/21 responde, mas a transferência não conclui
~~~

O professor não informará a causa.

Use o método da disciplina.

## 10. Portfólio

Organize:

~~~text
transferencia/aula-17/
└── README.md
~~~

Registre canal de controle, canal de dados, modo ativo/passivo, captura, evidências e troubleshooting.