# Aula 16 — FTP: serviço, autenticação e transferência

**Bloco de referência:** 100 minutos

## Objetivos

Ao final desta aula, você deverá conseguir:

- explicar a função do FTP;
- identificar o canal de controle em TCP/21;
- instalar e configurar o `vsftpd`;
- restringir o serviço ao usuário de laboratório;
- autenticar com usuário local;
- realizar listagem, download e upload;
- validar serviço, porta, autenticação, permissões e transferência;
- utilizar logs e cliente FTP como ferramentas de diagnóstico.

A rede de laboratório permanece:

~~~text
srv-r2-sNN
├── host0 → gerenciamento
└── lab0: 192.168.50.10/24
          │
          │ FTP
          ▼
      cli-r2-sNN
      └── lab0: configuração recebida por DHCP
~~~

> O FTP será disponibilizado apenas pela `lab0`. Não utilize `host0` para o experimento.

> Utilize somente senha temporária de laboratório. Não reutilize credenciais pessoais, institucionais ou do GitHub.

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

O FTP utiliza uma conexão de controle e outra conexão para dados.

Nesta aula utilizaremos o modo passivo para realizar as transferências. A diferença entre modo ativo e passivo será aprofundada na Aula 17.

---

## 2. Confirme a rede antes de instalar o serviço

No servidor:

~~~bash
ip -4 -br addr show lab0
~~~

O endereço esperado é:

~~~text
192.168.50.10/24
~~~

No cliente:

~~~bash
ip -4 -br addr show lab0
ping -c 2 192.168.50.10
~~~

Não prossiga para o FTP se a comunicação básica entre cliente e servidor ainda não estiver funcionando.

---

## 3. Instale as ferramentas

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

Confira as ferramentas:

~~~bash
vsftpd -v
lftp --version
~~~

---

## 4. Crie o usuário de laboratório

No servidor:

~~~bash
sudo adduser ftpuser
~~~

Defina uma senha temporária.

O usuário será utilizado somente para o experimento de FTP.

---

## 5. Prepare uma raiz FTP controlada

Em vez de utilizar a própria home do usuário como raiz gravável do chroot, criaremos uma raiz controlada e um subdiretório específico para arquivos.

No servidor:

~~~bash
sudo mkdir -p /srv/ftp/ftpuser/arquivos
~~~

A raiz do FTP ficará sob controle de `root`:

~~~bash
sudo chown root:root /srv/ftp/ftpuser
sudo chmod 755 /srv/ftp/ftpuser
~~~

O subdiretório de arquivos pertence ao usuário:

~~~bash
sudo chown ftpuser:ftpuser /srv/ftp/ftpuser/arquivos
sudo chmod 750 /srv/ftp/ftpuser/arquivos
~~~

Crie um arquivo para download:

~~~bash
sudo -u ftpuser sh -c   'echo "Arquivo disponibilizado pelo servidor FTP" > /srv/ftp/ftpuser/arquivos/servidor.txt'
~~~

Confira:

~~~bash
ls -ld /srv/ftp/ftpuser
ls -ld /srv/ftp/ftpuser/arquivos
ls -l /srv/ftp/ftpuser/arquivos
~~~

Observe a diferença:

~~~text
/srv/ftp/ftpuser
→ raiz do chroot
→ não gravável pelo ftpuser

/srv/ftp/ftpuser/arquivos
→ área de trabalho
→ gravável pelo ftpuser
~~~

---

## 6. Restrinja o serviço ao usuário ftpuser

Crie a lista de usuários autorizados:

~~~bash
echo 'ftpuser' | sudo tee /etc/vsftpd.user_list
~~~

Somente os usuários presentes nessa lista poderão autenticar no FTP quando utilizarmos a configuração a seguir.

---

## 7. Configure o vsftpd

Primeiro faça backup do arquivo instalado pelo pacote:

~~~bash
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.original
~~~

Para evitar diretivas duplicadas do arquivo de exemplo, substitua o conteúdo por uma configuração mínima e conhecida:

~~~bash
sudo tee /etc/vsftpd.conf > /dev/null <<'EOF'
listen=YES
listen_ipv6=NO
listen_address=192.168.50.10

anonymous_enable=NO
local_enable=YES
write_enable=YES

chroot_local_user=YES
local_root=/srv/ftp/ftpuser

userlist_enable=YES
userlist_deny=NO
userlist_file=/etc/vsftpd.user_list

pasv_enable=YES
pasv_address=192.168.50.10
pasv_min_port=40000
pasv_max_port=40010

xferlog_enable=YES
xferlog_std_format=NO

pam_service_name=vsftpd
secure_chroot_dir=/var/run/vsftpd/empty

ssl_enable=NO
EOF
~~~

Pontos importantes:

~~~text
listen_address=192.168.50.10
→ impede que o serviço escute pela host0

chroot_local_user=YES
→ mantém o usuário dentro da raiz FTP

local_root=/srv/ftp/ftpuser
→ define a raiz apresentada ao usuário

userlist_deny=NO
→ somente usuários listados podem entrar

pasv_min_port / pasv_max_port
→ tornam as conexões de dados passivas previsíveis
~~~

A faixa passiva será estudada em detalhes na Aula 17.

---

## 8. Reinicie e valide o serviço

A configuração do `vsftpd` não possui, no nosso fluxo, um comando de validação prévia equivalente a `nginx -t`, `named-checkconf` ou `kea-dhcp4 -t`.

Por isso, após a alteração:

~~~bash
sudo systemctl restart vsftpd
~~~

Confira:

~~~bash
systemctl is-active vsftpd
systemctl status vsftpd --no-pager
~~~

Verifique onde a porta 21 está escutando:

~~~bash
sudo ss -lntp | grep ':21'
~~~

O resultado deve indicar:

~~~text
192.168.50.10:21
~~~

e não:

~~~text
0.0.0.0:21
~~~

Se o serviço falhar:

~~~bash
sudo journalctl -u vsftpd -n 50 --no-pager
~~~

---

## 9. Teste somente a conectividade da porta

No cliente:

~~~bash
nc -vz 192.168.50.10 21
~~~

Esse teste responde apenas:

> O cliente consegue estabelecer uma conexão TCP com a porta de controle?

Ele ainda não comprova autenticação, listagem ou transferência.

---

## 10. Faça a primeira sessão FTP

No cliente, crie um arquivo local:

~~~bash
echo "Arquivo criado no cliente" > arquivo-cliente.txt
~~~

Conecte:

~~~bash
lftp -u ftpuser ftp://192.168.50.10
~~~

O `lftp` solicitará a senha quando necessário. Não coloque a senha diretamente na linha de comando.

Dentro do `lftp`:

~~~text
pwd
ls
cd arquivos
ls
get servidor.txt
put arquivo-cliente.txt
ls
bye
~~~

---

## 11. Confirme download e upload fora do cliente FTP

No cliente:

~~~bash
cat servidor.txt
~~~

No servidor:

~~~bash
sudo -u ftpuser ls -l /srv/ftp/ftpuser/arquivos
~~~

O estado final esperado é:

~~~text
[ ] TCP/21 responde
[ ] autenticação funciona
[ ] listagem funciona
[ ] download funciona
[ ] upload funciona
~~~

---

## 12. Observe o log de transferências

Como habilitamos:

~~~conf
xferlog_enable=YES
xferlog_std_format=NO
~~~

observe:

~~~bash
sudo tail -n 30 /var/log/vsftpd.log
~~~

Associe as linhas do log ao download e ao upload realizados.

O `journalctl` continua útil para o estado do serviço:

~~~bash
sudo journalctl -u vsftpd -n 30 --no-pager
~~~

Mas o arquivo `/var/log/vsftpd.log` é mais útil para observar as transferências.

---

## 13. Ferramentas de diagnóstico e validação

### Rede

~~~bash
ip -4 -br addr show lab0
ping -c 2 192.168.50.10
~~~

Pergunta:

> Cliente e servidor conseguem se comunicar pela rede do laboratório?

### Serviço

~~~bash
systemctl is-active vsftpd
systemctl status vsftpd --no-pager
~~~

Pergunta:

> O processo do serviço está ativo?

### Porta

~~~bash
sudo ss -lntp | grep ':21'
~~~

Perguntas:

> Existe processo escutando em TCP/21?

> Ele está escutando somente em 192.168.50.10?

### Conectividade

~~~bash
nc -vz 192.168.50.10 21
~~~

Pergunta:

> O cliente consegue alcançar a porta de controle?

### Cliente detalhado

~~~bash
lftp -d -u ftpuser ftp://192.168.50.10
~~~

Pergunta:

> Em qual etapa da sessão FTP ocorre a falha?

### Usuário e permissões

~~~bash
id ftpuser
namei -l /srv/ftp/ftpuser/arquivos
~~~

Pergunta:

> O usuário possui permissão para chegar e escrever no diretório esperado?

### Transferências

~~~bash
sudo tail -n 30 /var/log/vsftpd.log
~~~

Pergunta:

> O servidor registrou o download ou upload?

### Serviço e inicialização

~~~bash
sudo journalctl -u vsftpd -n 50 --no-pager
~~~

Pergunta:

> O serviço registrou erro ao iniciar ou reiniciar?

---

## 14. Troubleshooting

O professor poderá introduzir uma falha simples.

Exemplo de sintoma:

~~~text
A conexão TCP/21 funciona.
O usuário autentica.
A listagem funciona.
O upload falha.
~~~

Você receberá:

~~~text
sintoma
+
estado esperado
~~~

Você não receberá:

~~~text
arquivo responsável
+
linha incorreta
+
comando de correção
~~~

Utilize:

~~~text
Sintoma
→ Hipótese
→ Teste
→ Evidência
→ Causa
→ Correção
→ Validação
~~~

As ferramentas necessárias foram apresentadas nesta aula.

---

## 15. Portfólio

Organize:

~~~text
transferencia/aula-16/
├── README.md
└── vsftpd.conf
~~~

Copie a configuração:

~~~bash
sudo cp /etc/vsftpd.conf ~/vsftpd-aula16.conf
~~~

Depois leve o arquivo ao seu portfólio conforme o fluxo já utilizado na disciplina.

O README deve registrar:

~~~markdown
# Aula 16 — FTP

## Arquitetura
- servidor:
- interface:
- porta de controle:
- raiz FTP:
- diretório gravável:

## Configuração
- autenticação local:
- restrição de usuários:
- chroot:
- modo passivo:

## Validação
- rede:
- serviço:
- porta:
- login:
- listagem:
- download:
- upload:

## Logs
Qual evidência foi registrada em /var/log/vsftpd.log?

## Ferramentas de diagnóstico
Explique o que cada ferramenta utilizada permite verificar.

## Troubleshooting
### Sintoma
### Hipótese
### Testes e evidências
### Causa
### Correção
### Validação
~~~

Não registre a senha temporária.
