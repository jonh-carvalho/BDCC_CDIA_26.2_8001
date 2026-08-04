--- 
id: nginx
title: Nginx
---  

### Site com nginx na EC2 

Roteiro para sair de uma instância EC2 limpa até o site HTML/CSS/JS no ar com Nginx, incluindo segurança mínima e comando de publicação.

#### 1. Criar/usar a instância EC2

- AMI: Amazon Linux (2 ou 2023).
- Tipo: t2.micro/t3.micro (se couber no Free Tier).
- Security Group:
    - SSH 22: apenas seu IP.
    - HTTP 80: 0.0.0.0/0.
    - HTTPS 443: 0.0.0.0/0 (se for usar TLS).
- Conecte via SSH:

```bash
ssh -i sua-chave.pem ec2-user@SEU_IP_PUBLICO
```

#### 2. Instalar e iniciar Nginx

- Amazon Linux 2:

```bash
sudo yum update -y
sudo yum install nginx -y
```
- Amazon Linux 2023:

```bash
sudo dnf update -y
sudo dnf install nginx -y
```
- Iniciar e habilitar no boot:

```bash
sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl status nginx
```

#### 3. Criar pasta do site e permissões

```bash
sudo mkdir -p /var/www/meusite
sudo chown -R ec2-user:ec2-user /var/www/meusite
```

#### 4. Subir seus arquivos HTML/CSS/JS

- Do seu computador para a EC2 (exemplo com scp):

```bash
scp -i sua-chave.pem -r ./seu-projeto/* ec2-user@SEU_IP_PUBLICO:/var/www/meusite/
```

#### 5. Configurar virtual host no Nginx
- Criar arquivo de configuração:

```bash
sudo tee /etc/nginx/conf.d/meusite.conf > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;

    root /var/www/meusite;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(css|js|png|jpg|jpeg|gif|svg|ico|webp)$ {
        expires 7d;
        add_header Cache-Control "public, immutable";
    }
}
EOF
```

- Validar e recarregar:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

#### 6. Testar no navegador

- Acesse:

```text
http://SEU_IP_PUBLICO
```
- Se não abrir, revise Security Group (porta 80) e status do Nginx.

#### 7. (Opcional, recomendado) Domínio + HTTPS

- Aponte DNS (A record) para o IP da EC2.
- Instale Certbot e emita certificado LetsEncrypt.
- Com SSL ativo, redirecione HTTP para HTTPS.

**Checklist rápido**

- Nginx rodando: `systemctl status nginx`
- Porta 80 liberada no Security Group
- Arquivos em `/var/www/meusite`
- `nginx -t` sem erros
- Site abrindo por IP (e depois por domínio)

