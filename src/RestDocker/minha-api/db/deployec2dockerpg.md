# Deploy Django + PostgreSQL (Docker) em EC2 com CI/CD (GitHub Actions)

## Objetivo

Publicar uma aplicação Django com PostgreSQL em uma única EC2, tudo via Docker Compose, com deploy automático a cada `git push` na branch `main`.

## Arquitetura

```
GitHub (push main)
   └─ GitHub Actions
        ├─ 1. Testes
        ├─ 2. Build da imagem Django → GHCR (registry)
        └─ 3. SSH na EC2 → docker compose pull && up -d
EC2 (Amazon Linux 2023)
   └─ Docker Compose
        ├─ web  (Django + gunicorn, porta 8000)
        ├─ nginx (porta 80)  [opcional, recomendado]
        └─ db   (postgres:16, volume pgdata, sem porta pública)
```

Pontos-chave: o banco **não** expõe a porta 5432 ao exterior; os dados ficam em um volume nomeado; segredos ficam no `.env` da EC2 e no GitHub Secrets.

---

## Parte 1 - Preparar a EC2 (uma única vez)

1. Crie uma EC2 `t3.small` (Amazon Linux 2023) com Security Group:
   - 22 (SSH) → apenas seu IP
   - 80/443 (HTTP/HTTPS) → 0.0.0.0/0
   - **Não** abra a 5432.
2. (Recomendado) associe um Elastic IP.
3. Instale Docker e o plugin Compose:

```bash
sudo yum update -y
sudo yum install docker git -y
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user

sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
# saia e entre novamente no SSH
docker compose version
```

4. Crie a pasta da aplicação:

```bash
mkdir -p ~/app && cd ~/app
```

5. Crie `~/app/.env` (nunca vai para o Git):

```env
DJANGO_SECRET_KEY=troque-por-uma-chave-longa
DJANGO_DEBUG=0
DJANGO_ALLOWED_HOSTS=SEU_IP_OU_DOMINIO
POSTGRES_DB=appdb
POSTGRES_USER=appuser
POSTGRES_PASSWORD=senha-forte-aqui
POSTGRES_HOST=db
POSTGRES_PORT=5432
IMAGE=ghcr.io/SEU_USUARIO/SEU_REPO:latest
```

---

## Parte 2 - Arquivos no repositório

### `Dockerfile`

```dockerfile
FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends libpq5 && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
RUN python manage.py collectstatic --noinput
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3"]
```

> Ajuste `config.wsgi` para o nome do seu projeto. `requirements.txt` deve conter `django`, `gunicorn`, `psycopg[binary]` e `whitenoise`.

### `docker-compose.prod.yml`

```yaml
services:
  db:
    image: postgres:16
    restart: unless-stopped
    env_file: .env
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}"]
      interval: 5s
      timeout: 3s
      retries: 10

  web:
    image: ${IMAGE}
    restart: unless-stopped
    env_file: .env
    depends_on:
      db:
        condition: service_healthy
    ports:
      - "80:8000"

volumes:
  pgdata:
```

> Para HTTPS/domínio, adicione um serviço `nginx` ou Caddy na frente do `web` e remova o `ports` do `web`.

### `settings.py` (trechos)

```python
import os

SECRET_KEY = os.environ["DJANGO_SECRET_KEY"]
DEBUG = os.environ.get("DJANGO_DEBUG", "0") == "1"
ALLOWED_HOSTS = os.environ["DJANGO_ALLOWED_HOSTS"].split(",")

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": os.environ["POSTGRES_DB"],
        "USER": os.environ["POSTGRES_USER"],
        "PASSWORD": os.environ["POSTGRES_PASSWORD"],
        "HOST": os.environ.get("POSTGRES_HOST", "db"),
        "PORT": os.environ.get("POSTGRES_PORT", "5432"),
    }
}

STATIC_ROOT = BASE_DIR / "staticfiles"
# Adicione "whitenoise.middleware.WhiteNoiseMiddleware" logo após SecurityMiddleware
```

---

## Parte 3 - Segredos no GitHub

Em **Settings → Secrets and variables → Actions**, crie:

| Secret | Valor |
|---|---|
| `EC2_HOST` | IP público / Elastic IP |
| `EC2_USER` | `ec2-user` |
| `EC2_SSH_KEY` | Conteúdo da chave privada `.pem` (de preferência uma chave dedicada ao deploy) |
| `GHCR_TOKEN` | PAT com escopo `read:packages` (usado pela EC2 para baixar a imagem) |

---

## Parte 4 - Pipeline `.github/workflows/deploy.yml`

```yaml
name: CI/CD

on:
  push:
    branches: [main]

env:
  IMAGE_NAME: ghcr.io/${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_DB: test
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
        ports: ["5432:5432"]
        options: >-
          --health-cmd pg_isready --health-interval 5s
          --health-timeout 3s --health-retries 10
    env:
      DJANGO_SECRET_KEY: ci-key
      DJANGO_DEBUG: "1"
      DJANGO_ALLOWED_HOSTS: "*"
      POSTGRES_DB: test
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
      POSTGRES_HOST: localhost
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
      - run: pip install -r requirements.txt
      - run: python manage.py test

  build:
    needs: test
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: |
            ${{ env.IMAGE_NAME }}:latest
            ${{ env.IMAGE_NAME }}:${{ github.sha }}

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Copiar compose para a EC2
        uses: appleboy/scp-action@v0.1.7
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USER }}
          key: ${{ secrets.EC2_SSH_KEY }}
          source: docker-compose.prod.yml
          target: /home/ec2-user/app

      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USER }}
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            cd ~/app
            echo "${{ secrets.GHCR_TOKEN }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
            docker compose -f docker-compose.prod.yml pull web
            docker compose -f docker-compose.prod.yml up -d
            docker compose -f docker-compose.prod.yml exec -T web python manage.py migrate --noinput
            docker image prune -f
```

> Se o pacote no GHCR for **público**, o `docker login` na EC2 é dispensável.

---

## Parte 5 - Primeiro deploy e verificação

1. Faça `git push origin main` e acompanhe em **Actions**.
2. Na EC2:

```bash
cd ~/app
docker compose -f docker-compose.prod.yml ps
docker compose -f docker-compose.prod.yml logs -f web
docker compose -f docker-compose.prod.yml exec web python manage.py createsuperuser
```

3. Acesse `http://SEU_IP/admin/`.

---

## Backup e rollback

**Backup do banco** (agende no `cron` da EC2 e envie ao S3):

```bash
docker compose -f docker-compose.prod.yml exec -T db \
  pg_dump -U appuser appdb | gzip > backup_$(date +%F).sql.gz
aws s3 cp backup_$(date +%F).sql.gz s3://SEU-BUCKET/backups/
```

**Rollback**: a imagem é publicada também com a tag do commit. Para voltar:

```bash
# edite IMAGE no .env, por exemplo:
# IMAGE=ghcr.io/SEU_USUARIO/SEU_REPO:<sha-anterior>
docker compose -f docker-compose.prod.yml up -d
```

---

## Boas práticas e próximos passos

- **Nunca** versionar `.env`; adicione ao `.gitignore`.
- Não publique a porta 5432; use `docker compose exec db psql` ou túnel SSH para acessar o banco.
- Use HTTPS (Caddy ou Nginx + Let's Encrypt) com um domínio.
- Em vez de chave SSH, considere **AWS SSM Run Command** + OIDC (sem chaves de longa duração).
- Para produção real, migrar o banco para **RDS** (ver [10 - docker_rds.md](./10%20-%20docker_rds.md)) elimina a gestão de backup/patch do Postgres.
- Migrações destrutivas exigem cuidado: faça backup antes do deploy.
