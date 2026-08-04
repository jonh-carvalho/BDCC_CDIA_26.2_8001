### **Linux para Iniciantes** — Do Zero ao Controle do Sistema**

**Objetivo:** Ao final deste roteiro, o aluno deve ser capaz de navegar e operar um sistema Linux pela linha de comando (Bash), realizando tarefas essenciais de administração: gerenciar serviços, monitorar recursos, manipular arquivos e disco, instalar pacotes e aplicar configurações básicas de rede e segurança.

**Pré-requisitos:**

- Uma instância EC2 Amazon Linux 2023 (kernel 6.1) em execução (ou qualquer distribuição Linux com `systemd`, como Ubuntu 22.04).
- Acesso ao terminal via SSH (conforme o roteiro anterior — EC2).
- Sem experiência prévia em linha de comando necessária.

!!! tip "Dica"
    Todos os comandos deste roteiro devem ser executados no terminal Linux da sua instância EC2. Cada seção pode ser praticada de forma independente.

### **Parte 1 —** Gerenciamento de Sistema e Serviços

Os sistemas Linux modernos utilizam o `systemd` para controlar todos os serviços em execução (servidores web, banco de dados, SSH, etc.). O comando central é o `systemctl`.

#### 1.1 Conceitos fundamentais

| Conceito | Descrição |
|---|---|
| **Serviço (daemon)** | Programa que roda em segundo plano (ex.: servidor SSH, servidor web). |
| **Unit file** | Arquivo de configuração que descreve um serviço para o `systemd`. |
| **Status** | Estado atual do serviço: `active (running)`, `inactive`, `failed`. |

#### 1.2 Verificando o sistema

```bash
# Exibe informações da distribuição Linux instalada
cat /etc/os-release

# Exibe o nome do host (nome da máquina)
hostname

# Exibe há quanto tempo o sistema está ligado
uptime

# Exibe data e hora atual do sistema
date

# Exibe o usuário que está logado atualmente
whoami
```

### 1.3 Gerenciando serviços com `systemctl`

```bash
# Lista todos os serviços e seus status
systemctl list-units --type=service

# Verifica o status de um serviço específico (ex.: SSH)
systemctl status sshd

# Inicia um serviço
sudo systemctl start sshd

# Para um serviço
sudo systemctl stop sshd

# Reinicia um serviço (para e inicia novamente)
sudo systemctl restart sshd

# Recarrega as configurações sem reiniciar o processo
sudo systemctl reload sshd

# Habilita o serviço para iniciar automaticamente no boot
sudo systemctl enable sshd

# Desabilita o serviço no boot
sudo systemctl disable sshd
```

#### 1.4 **Exercício prático** — Instalar e gerenciar o servidor web Nginx

```bash
# 1. Instala o Nginx (Amazon Linux 2023)
sudo dnf install nginx -y

# 2. Inicia o serviço
sudo systemctl start nginx

# 3. Verifica se está ativo
systemctl status nginx

# 4. Habilita para iniciar no boot
sudo systemctl enable nginx

# 5. Testa a resposta local do servidor web
curl http://localhost
```

!!! success "Resultado esperado"
    A saída do `curl` deve exibir o HTML da página de boas-vindas do Nginx, confirmando que o servidor está ativo e respondendo.

---

### Parte 2 — Monitoramento de Recursos

Saber o que está consumindo CPU, memória e disco é essencial para diagnosticar lentidão e planejar capacidade.

#### 2.1 Monitoramento de CPU e memória

```bash
# Exibe processos em tempo real (pressione 'q' para sair)
top

# Versão mais visual do top (pode precisar instalar: sudo dnf install htop)
htop

# Exibe uso de memória RAM e swap de forma resumida
free -h

# Exibe informações da CPU (modelo, núcleos, etc.)
lscpu

# Exibe processos que mais consomem CPU (os 10 primeiros)
ps aux --sort=-%cpu | head -11

# Exibe processos que mais consomem memória (os 10 primeiros)
ps aux --sort=-%mem | head -11
```

#### 2.2 Monitoramento de disco e I/O

```bash
# Exibe uso de disco por partição (human-readable)
df -h

# Exibe o tamanho de um diretório específico
du -sh /var/log

# Exibe os 10 maiores itens dentro de um diretório
du -sh /var/log/* | sort -rh | head -10

# Monitora atividade de leitura/escrita no disco (pressione 'q' para sair)
# Pode precisar instalar: sudo dnf install sysstat
iostat -x 1 5
```

#### 2.3 Monitoramento em tempo real com `watch`

O comando `watch` executa qualquer outro comando repetidamente em intervalos fixos.

```bash
# Atualiza o uso de disco a cada 2 segundos
watch -n 2 df -h

# Atualiza a contagem de processos a cada 5 segundos
watch -n 5 'ps aux | wc -l'
```

#### 2.4 Verificando logs do sistema

```bash
# Exibe os logs do sistema em tempo real (pressione Ctrl+C para sair)
sudo journalctl -f

# Exibe os logs de um serviço específico
sudo journalctl -u nginx

# Exibe os logs desde o último boot
sudo journalctl -b

# Exibe as últimas 50 linhas de autenticação (sshd)
sudo journalctl -u sshd -n 50
```

!!! info "Dica de diagnóstico"
    Quando um serviço falha, o primeiro passo é sempre verificar seu log com `journalctl -u nome-do-servico --since "10 minutes ago"`.

### **Parte 3** — Gerenciamento de Arquivos e Disco

#### 3.1 Navegação no sistema de arquivos

```bash
# Exibe o diretório atual
pwd

# Lista arquivos (human-readable, com detalhes, incluindo ocultos)
ls -lah

# Muda para o diretório raiz
cd /

# Volta para o diretório home do usuário
cd ~

# Sobe um nível
cd ..

# Exibe a estrutura de diretórios em árvore (instalar: sudo dnf install tree)
tree /etc -L 2
```

#### 3.2 Operações com arquivos e diretórios

```bash
# Cria um diretório
mkdir ~/projetos

# Cria diretórios aninhados de uma vez
mkdir -p ~/projetos/app/logs

# Cria um arquivo vazio
touch ~/projetos/app/inicio.txt

# Escreve conteúdo em um arquivo
echo "meu primeiro arquivo" > ~/projetos/app/inicio.txt

# Exibe o conteúdo de um arquivo
cat ~/projetos/app/inicio.txt

# Adiciona conteúdo sem apagar o existente (append)
echo "segunda linha" >> ~/projetos/app/inicio.txt

# Copia um arquivo
cp ~/projetos/app/inicio.txt ~/projetos/app/backup.txt

# Move ou renomeia um arquivo
mv ~/projetos/app/backup.txt ~/projetos/app/copia.txt

# Remove um arquivo
rm ~/projetos/app/copia.txt

# Remove um diretório e todo seu conteúdo (⚠️ cuidado!)
rm -rf ~/projetos/app/logs
```

!!! warning "Atenção"
    O comando `rm -rf` é irreversível. Não há lixeira no terminal Linux. Sempre confirme o caminho antes de executar.

#### 3.3 Busca de arquivos

```bash
# Encontra arquivos por nome (busca a partir da raiz)
find / -name "nginx.conf" 2>/dev/null

# Encontra arquivos maiores que 100MB
find / -size +100M -type f 2>/dev/null

# Encontra arquivos modificados nas últimas 24 horas
find /var/log -mtime -1 -type f

# Busca um texto dentro de arquivos (grep)
grep -r "error" /var/log/nginx/

# Busca eventos de falha de autenticação do SSH via journal
sudo journalctl -u sshd | grep -i "failed"
```

#### 3.4 Gerenciamento de partições e disco

```bash
# Lista todos os discos e partições do sistema
lsblk

# Exibe informações detalhadas das partições
sudo fdisk -l

# Exibe o uso de inodes (útil quando o disco "cheia" sem arquivos visíveis)
df -i
```

### Parte 4 — Gerenciamento de Pacotes

Gerenciar pacotes significa instalar, atualizar e remover programas no Linux. O gerenciador varia conforme a distribuição.

| Distribuição | Gerenciador | Comando base |
|---|---|---|
| Amazon Linux 2, CentOS, RHEL | `yum` | `sudo yum install <pacote>` |
| Amazon Linux 2023 | `dnf` | `sudo dnf install <pacote>` |
| Ubuntu, Debian | `apt` | `sudo apt install <pacote>` |

#### 4.1 Operações essenciais com `dnf` (Amazon Linux 2023)

```bash
# Atualiza a lista de pacotes disponíveis
sudo dnf check-update

# Atualiza todos os pacotes instalados
sudo dnf upgrade -y

# Instala um pacote
sudo dnf install git -y

# Remove um pacote
sudo dnf remove git -y

# Pesquisa um pacote disponível
dnf search htop

# Exibe informações sobre um pacote
dnf info nginx

# Lista todos os pacotes instalados
dnf list installed

# Limpa o cache local de pacotes
sudo dnf clean all
```

#### 4.2 Repositórios no Amazon Linux 2023

No Amazon Linux 2023, o fluxo principal de instalação usa `dnf` diretamente (não há `amazon-linux-extras` como no AL2):

```bash
# Lista os repositórios habilitados
dnf repolist

# Exibe os módulos disponíveis (quando aplicável)
dnf module list
```

#### 4.3 Exercício prático — Instalar e verificar o Git

```bash
# Instala o Git
sudo dnf install git -y

# Verifica a versão instalada
git --version

# Exibe onde o binário foi instalado
which git

# Exibe informações completas do pacote git
rpm -qi git
```

### **Parte 5** — Redes e Segurança

#### 5.1 Diagnóstico de rede

```bash
# Exibe as interfaces de rede e seus endereços IP
ip addr show

# Forma mais antiga, equivalente ao ip addr
ifconfig
# (instalar: sudo dnf install net-tools)

# Exibe a tabela de roteamento
ip route show

# Testa conectividade com um host (Ctrl+C para parar)
ping -c 4 google.com

# Rastreia o caminho dos pacotes até um destino
traceroute google.com
# (instalar: sudo dnf install traceroute)

# Verifica se uma porta está aberta em um host remoto
nc -zv google.com 443

# Faz resolução DNS de um nome de domínio
nslookup google.com

# Alternativa moderna ao nslookup
dig google.com
# (instalar: sudo dnf install bind-utils)
```

#### 5.2 Monitoramento de conexões de rede

```bash
# Lista todas as conexões de rede ativas
ss -tulnp

# Alternativa mais antiga
netstat -tulnp
# (instalar: sudo dnf install net-tools)

# Exibe conexões estabelecidas
ss -tnp state established

# Verifica qual processo está usando uma porta específica (ex.: porta 80)
sudo ss -tulnp | grep :80
```

#### 5.3 Firewall com `firewalld`

O `firewalld` e o `nftables` podem ser usados no Amazon Linux 2023. Neste roteiro, usaremos `firewalld` por ser mais didático para iniciantes.

```bash
# Instala e inicia o firewalld
sudo dnf install firewalld -y
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Verifica o status do firewall
sudo firewall-cmd --state

# Lista as regras ativas na zona padrão
sudo firewall-cmd --list-all

# Libera acesso permanente à porta 80 (HTTP)
sudo firewall-cmd --permanent --add-port=80/tcp

# Libera um serviço pelo nome
sudo firewall-cmd --permanent --add-service=https

# Aplica as mudanças permanentes
sudo firewall-cmd --reload

# Bloqueia uma porta
sudo firewall-cmd --permanent --remove-port=80/tcp
sudo firewall-cmd --reload
```

!!! note "EC2 e Firewall"
    Em instâncias EC2, o tráfego é controlado primeiro pelo **Security Group** da AWS (no nível de VPC) e depois pelo firewall do sistema operacional. Ambos precisam permitir o tráfego para que uma conexão funcione.

#### 5.4 Gerenciamento de usuários e permissões

```bash
# Cria um novo usuário
sudo useradd -m estudante

# Define uma senha para o usuário
sudo passwd estudante

# Adiciona o usuário ao grupo sudo (para ter permissões de administrador)
sudo usermod -aG wheel estudante

# Lista os grupos do usuário atual
groups

# Exibe as permissões de um arquivo ou diretório
ls -l ~/projetos

# Altera o dono de um arquivo
sudo chown estudante:estudante ~/projetos/app/inicio.txt

# Altera as permissões (chmod)
# Formato octal: dono | grupo | outros
# 7 = rwx, 6 = rw-, 5 = r-x, 4 = r--
chmod 644 ~/projetos/app/inicio.txt   # dono: rw-, grupo: r--, outros: r--
chmod 755 ~/projetos/app/             # dono: rwx, grupo: r-x, outros: r-x

# Exibe o arquivo de usuários do sistema
cat /etc/passwd | grep estudante

# Remove um usuário (mantendo o diretório home)
sudo userdel estudante

# Remove um usuário e apaga o diretório home
sudo userdel -r estudante
```

#### 5.5 Hardening básico de SSH

O arquivo de configuração do SSH fica em `/etc/ssh/sshd_config`. Algumas práticas recomendadas:

```bash
# Faz um backup do arquivo antes de editar
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Abre o arquivo para edição
sudo nano /etc/ssh/sshd_config
```

Dentro do arquivo, localize e ajuste (ou adicione) as seguintes linhas:

```
# Desabilita login como root via SSH
PermitRootLogin no

# Desabilita autenticação por senha (use apenas chaves)
PasswordAuthentication no

# Define tempo limite de inatividade: 5 minutos
ClientAliveInterval 300
ClientAliveCountMax 0
```

```bash
# Após salvar as alterações, verifica se a configuração é válida
sudo sshd -t

# Reinicia o SSH para aplicar as mudanças
sudo systemctl restart sshd
```

!!! danger "Atenção crítica"
    Antes de desabilitar a autenticação por senha (`PasswordAuthentication no`), certifique-se de que a autenticação por chave SSH está funcionando corretamente. Caso contrário, você pode perder o acesso à instância permanentemente.

---

### Resumo dos Comandos Essenciais

| Categoria | Comando | Função |
|---|---|---|
| **Sistema** | `systemctl status sshd` | Verifica status de um serviço |
| **Sistema** | `sudo systemctl restart nginx` | Reinicia um serviço |
| **Recursos** | `top` / `htop` | Monitor de processos em tempo real |
| **Recursos** | `free -h` | Uso de memória RAM |
| **Recursos** | `df -h` | Uso de disco por partição |
| **Arquivos** | `find / -name "*.conf"` | Busca arquivos por nome |
| **Arquivos** | `grep -r "error" /var/log/` | Busca texto dentro de arquivos |
| **Pacotes** | `sudo dnf install git -y` | Instala um pacote |
| **Pacotes** | `dnf list installed` | Lista pacotes instalados |
| **Rede** | `ss -tulnp` | Lista portas abertas e processos |
| **Rede** | `ping -c 4 google.com` | Testa conectividade |
| **Segurança** | `sudo firewall-cmd --list-all` | Lista regras do firewall |
| **Segurança** | `chmod 644 arquivo.txt` | Ajusta permissões de arquivo |

---

### Desafio Final

Coloque tudo em prática com este desafio integrado:

1. **Serviços:** Instale o Nginx, inicie-o, habilite no boot e confirme com `systemctl status`.
2. **Monitoramento:** Use `top` por 30 segundos e identifique qual processo consome mais CPU. Use `df -h` para ver o uso de disco.
3. **Arquivos:** Crie a estrutura `~/desafio/logs/` e `~/desafio/config/`. Crie um arquivo `config.txt` com o conteúdo `"ambiente=producao"`. Faça uma cópia de segurança com o nome `config.bak`.
4. **Pacotes:** Instale o `git`, verifique a versão e pesquise o pacote `tree` com `dnf search`.
5. **Rede:** Execute `ss -tulnp` e identifique em qual porta o Nginx está escutando. Use `curl http://localhost` para confirmar o acesso.
6. **Segurança:** Crie um usuário chamado `devuser`, defina uma senha e verifique suas permissões na pasta `~/desafio/` com `ls -lah`.

!!! success "Critério de conclusão"
    Ao final do desafio, você deverá ser capaz de responder: qual processo usa mais CPU, qual a porta do Nginx, qual o uso de disco da partição raiz e qual permissão (octal) o arquivo `config.txt` possui após um `chmod 640`.
