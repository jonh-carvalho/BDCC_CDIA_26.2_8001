Para instalar o MinIO usando Docker em uma instância EC2 da AWS, você precisa configurar as portas necessárias na AWS, preparar o diretório de dados para persistência e rodar o container Docker com as credenciais administrativas.

### Pré-requisito: Liberar Portas no Security Group da EC2

No painel da AWS EC2, vá em **Security Groups** > edite as **Inbound Rules** (Regras de Entrada) e adicione:

* **Custom TCP** | Porta `9000` | Origem: Seu IP ou CIDR da sua rede.
* **Custom TCP** | Porta `9001` | Origem: Seu IP ou CIDR da sua rede.

---

### Passo a Passo de Instalação e Execução

1. **Criar o diretório para persistência de dados:** No terminal da EC2.
Crie uma pasta no sistema de arquivos do host para garantir que os arquivos salvos no MinIO não sejam perdidos caso o container reinicie.

Execute: `mkdir -p ~/minio/data`

*Verification:* Rode `ls -la ~/minio` e confirme que a pasta `data` foi criada.


2. **Iniciar o container do MinIO:** Docker Command.
Execute o comando Docker abaixo ajustando as variáveis de usuário e senha (`MINIO_ROOT_USER` e `MINIO_ROOT_PASSWORD`):

```bash
docker run -d --name minio
  --restart always 
  -p 9000:9000 
  -p 9001:9001 
  -v ~/minio/data:/data 
  -e "MINIO_ROOT_USER=admin" 
  -e "MINIO_ROOT_PASSWORD=SuaSenhaSegura123" 
  quay.io/minio/minio server /data --console-address ":9001"

```

*Verification:* Rode `docker ps` e verifique se o container `minio` está com o status *Up*.


3. **Acessar o Console Web:** Navegador.
Abra o seu navegador e acesse: `http://<IP-PUBLICO-DA-EC2>:9001`

Insira o usuário (`admin`) e a senha configurada no passo anterior para entrar no painel de controle do MinIO.

*Verification:* A interface do dashboard do MinIO deve carregar solicitando o login com sucesso.

Após instalar o MinIO no Docker, o próximo passo é criar um **Bucket** (reservatório de arquivos) e gerar as **Access Keys** (chaves de acesso) para conectar suas aplicações via SDK, CLI ou Laravel/Node.js/Python.

---

## 1. Criar um Bucket

1. Acesse o painel web no seu navegador: `http://<IP-PUBLICO-EC2>:9001`
2. Faça login com o **Usuário** e **Senha** definidos na instalação (`MINIO_ROOT_USER` e `MINIO_ROOT_PASSWORD`).
3. No menu lateral esquerdo, clique em **Buckets**.
4. Clique no botão **Create Bucket**.
5. Digite o nome do seu bucket (exemplo: `meu-bucket-app`) e clique em **Create Bucket**.

> **Dica:** Mantenha as configurações padrão (Versioning, Object Lock) desativadas caso seja um projeto simples.

---

## 2. Alterar a Política de Acesso (Opcional - Arquivos Públicos)

Por padrão, todos os arquivos enviados ao MinIO são privados. Se o seu sistema precisa exibir imagens ou downloads diretamente na web via URL:

1. No menu **Buckets**, clique sobre o bucket criado (`meu-bucket-app`).
2. Clique na aba ou opção **Summary** / **Anonymous** (Dependendo da versão da interface).
3. Em **Access Policy**, mude de `Private` para `Public` (ou crie regras customizadas de `read-only`).
4. Clique em **Set** / **Save**.

---

## 3. Criar Access Key e Secret Key para sua Aplicação

Nunca use a senha mestre (`MINIO_ROOT_USER`) no código do seu sistema. Crie chaves de API dedicadas:

1. No menu lateral esquerdo, clique em **Access Keys** (ou **User Management** > **Access Keys**).
2. Clique em **Create Access Key**.
3. O MinIO vai gerar automaticamente uma **Access Key** e uma **Secret Key**.
4. Copie e salve a **Secret Key** em um local seguro (ela só será exibida uma única vez).
5. Clique em **Create**.

---

## 4. Testar a Conexão no seu Projeto (Exemplo `.env`)

No `.env` do seu projeto (Node.js, Laravel, Python, etc.), utilize o driver compatível com AWS S3 apontando para a sua EC2:

```ini
AWS_ACCESS_KEY_ID=sua_access_key_gerada
AWS_SECRET_ACCESS_KEY=sua_secret_key_gerada
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=meu-bucket-app
AWS_ENDPOINT=http://<IP-PUBLICO-EC2>:9000
AWS_USE_PATH_STYLE_ENDPOINT=true

```

> **Importante:** A porta para a API da aplicação é a **9000** (a porta **9001** é apenas para o painel web visual).