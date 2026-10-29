# Django API + PostgreSQL com Docker (para iniciantes)

## Objetivo

Criar do zero uma API REST em Django (Django REST Framework) conectada a um PostgreSQL, ambos em containers Docker, testar localmente e depois rodar na EC2.

Ao final você terá: projeto Django, endpoint `/api/tarefas/`, banco Postgres persistente e tudo subindo com um único comando.

## Pré-requisitos

- Python 3.12 e Git (para o passo local)
- Docker e Docker Compose (`docker --version`, `docker compose version`)
- Editor de código (VS Code)

---

## Parte 1 - Estrutura do projeto

```bash
mkdir minha-api && cd minha-api
python -m venv .venv
# Windows: .venv\Scripts\activate   |  Linux/Mac: source .venv/bin/activate
pip install django djangorestframework "psycopg[binary]" gunicorn
pip freeze > requirements.txt
django-admin startproject config .
python manage.py startapp tarefas
```

Estrutura esperada:

```
minha-api/
├── config/          (settings.py, urls.py, wsgi.py)
├── tarefas/         (models.py, views.py, serializers.py)
├── manage.py
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
└── .env
```

---

## Parte 2 - Código da API

### `config/settings.py`

Adicione os apps e troque o banco para Postgres lendo variáveis de ambiente:

```python
import os

SECRET_KEY = os.environ.get("DJANGO_SECRET_KEY", "dev-inseguro")
DEBUG = os.environ.get("DJANGO_DEBUG", "1") == "1"
ALLOWED_HOSTS = os.environ.get("DJANGO_ALLOWED_HOSTS", "*").split(",")

INSTALLED_APPS = [
    # ... apps padrão ...
    "rest_framework",
    "tarefas",
]

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": os.environ.get("POSTGRES_DB", "appdb"),
        "USER": os.environ.get("POSTGRES_USER", "appuser"),
        "PASSWORD": os.environ.get("POSTGRES_PASSWORD", "senha"),
        "HOST": os.environ.get("POSTGRES_HOST", "db"),
        "PORT": os.environ.get("POSTGRES_PORT", "5432"),
    }
}
```

### `tarefas/models.py`

```python
from django.db import models

class Tarefa(models.Model):
    titulo = models.CharField(max_length=200)
    concluida = models.BooleanField(default=False)
    criada_em = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.titulo
```

### `tarefas/serializers.py`

```python
from rest_framework import serializers
from .models import Tarefa

class TarefaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Tarefa
        fields = "__all__"
```

### `tarefas/views.py`

```python
from rest_framework import viewsets
from .models import Tarefa
from .serializers import TarefaSerializer

class TarefaViewSet(viewsets.ModelViewSet):
    queryset = Tarefa.objects.all().order_by("-criada_em")
    serializer_class = TarefaSerializer
```

### `config/urls.py`

```python
from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from tarefas.views import TarefaViewSet

router = DefaultRouter()
router.register("tarefas", TarefaViewSet)

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/", include(router.urls)),
]
```

---

## Parte 3 - Docker

### `.env` (não versionar!)

```env
DJANGO_SECRET_KEY=troque-esta-chave
DJANGO_DEBUG=1
DJANGO_ALLOWED_HOSTS=*
POSTGRES_DB=appdb
POSTGRES_USER=appuser
POSTGRES_PASSWORD=senha-forte
POSTGRES_HOST=db
POSTGRES_PORT=5432
```

### `.gitignore` e `.dockerignore`

```
.venv/
.env
__pycache__/
*.pyc
```

### `Dockerfile`

```dockerfile
FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]
```

### `docker-compose.yml`

```yaml
services:
  db:
    image: postgres:16
    env_file: .env
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}"]
      interval: 5s
      retries: 10

  web:
    build: .
    env_file: .env
    depends_on:
      db:
        condition: service_healthy
    ports:
      - "8000:8000"

volumes:
  pgdata:
```

Por que assim?
- `db` é o nome do serviço e também o **host** que o Django usa para achar o banco.
- O volume `pgdata` mantém os dados mesmo se o container for recriado.
- A porta 5432 não é publicada: só o `web` acessa o banco.
- O `healthcheck` evita o Django subir antes do Postgres estar pronto.

---

## Parte 4 - Rodando localmente

```bash
docker compose up -d --build
docker compose exec web python manage.py makemigrations tarefas
docker compose exec web python manage.py migrate
docker compose exec web python manage.py createsuperuser
docker compose logs -f web
```

Teste:

```bash
curl http://localhost:8000/api/tarefas/
curl -X POST http://localhost:8000/api/tarefas/ -H "Content-Type: application/json" -d '{"titulo":"Estudar Docker"}'
curl http://localhost:8000/api/tarefas/
```

Também abra `http://localhost:8000/api/tarefas/` no navegador (interface do DRF) e `http://localhost:8000/admin/`.

> Os arquivos de migração criados em `tarefas/migrations/` devem ser versionados no Git.

Verificar o banco:

```bash
docker compose exec db psql -U appuser -d appdb -c "SELECT * FROM tarefas_tarefa;"
```

---

## Parte 5 - Rodando na EC2

1. Crie a EC2 (Amazon Linux 2023) com Security Group: 22 (seu IP) e 8000 (ou 80) aberta; **não** abra a 5432.
2. Instale Docker e Compose:

```bash
sudo yum update -y
sudo yum install docker git -y
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
```
(saia e entre novamente no SSH)

3. Envie o projeto (via `git clone` do seu repositório) e crie o `.env` na EC2 com valores de produção: `DJANGO_DEBUG=0`, `DJANGO_ALLOWED_HOSTS=IP_DA_EC2` e senha forte.
4. Suba:

```bash
docker compose up -d --build
docker compose exec web python manage.py migrate
```

5. Acesse `http://IP_DA_EC2:8000/api/tarefas/`.

Para automatizar o deploy a cada push, veja [deployec2dockerpg.md](./deployec2dockerpg.md).

---

## Comandos úteis

| Ação | Comando |
|---|---|
| Ver containers | `docker compose ps` |
| Logs | `docker compose logs -f web` |
| Shell do Django | `docker compose exec web python manage.py shell` |
| Parar | `docker compose down` |
| Parar e **apagar dados** | `docker compose down -v` |
| Rebuild após mudar código | `docker compose up -d --build` |

## Problemas comuns

- **`connection refused` / `could not translate host name "db"`**: confira `POSTGRES_HOST=db` e se o serviço `db` está de pé.
- **`DisallowedHost`**: inclua o IP/domínio em `DJANGO_ALLOWED_HOSTS`.
- **Mudei a senha do Postgres e não funciona**: o volume guarda a senha antiga; use `docker compose down -v` (apaga os dados) ou altere a senha via `ALTER USER`.
- **`relation does not exist`**: faltou rodar `makemigrations` / `migrate`.
- **Não abre na EC2**: libere a porta no Security Group.

## Desafios

1. Adicione o campo `descricao` ao modelo, gere a migração e aplique.
2. Adicione um filtro `?concluida=true` na listagem.
3. Escreva um teste com `python manage.py test` e rode no container.
4. Não use `runserver` em produção: já usamos gunicorn; adicione whitenoise para servir arquivos estáticos do admin.
