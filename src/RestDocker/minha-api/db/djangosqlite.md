# Django API com Docker + SQLite (roteiro inicial)

## Objetivo

Criar a API Django e rodá-la em um container Docker usando SQLite. Este é o ponto de partida: o roteiro seguinte ([djangopg.md](./djangopg.md)) evolui o mesmo projeto para PostgreSQL.

Resultado: endpoint `http://localhost:8000/api/tarefas/` funcionando em container, com dados persistidos em um volume.

## Pré-requisitos

- Python 3.12+ e Docker (`docker compose version`)

---

## Parte 1 - Criar o projeto

```bash
mkdir minha-api && cd minha-api
python -m venv .venv
# Windows: .venv\Scripts\activate   |  Linux/Mac: source .venv/bin/activate
pip install django djangorestframework gunicorn
pip freeze > requirements.txt
django-admin startproject config .
python manage.py startapp tarefas
```

No Windows, salve o conteúdo abaixo como `criar-projeto.ps1` na pasta onde deseja criar o projeto e execute-o no PowerShell. O script usa diretamente o Python do ambiente virtual, sem precisar ativá-lo:

```powershell
$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Force -Path "minha-api" | Out-Null
Set-Location "minha-api"

python -m venv .venv
$python = ".\.venv\Scripts\python.exe"
& $python -m pip install django djangorestframework gunicorn
& $python -m pip freeze | Set-Content -Encoding ascii requirements.txt
& ".\.venv\Scripts\django-admin.exe" startproject config .
& $python manage.py startapp tarefas
```

Execute com ` .\criar-projeto.ps1` (sem o espaço inicial). Se a política de execução bloquear o script, use `powershell -ExecutionPolicy Bypass -File .\criar-projeto.ps1`.


## Parte 2 - Código da API

### `config/settings.py`

Registre os apps, aceite requisições externas e deixe o caminho do SQLite configurável (isso facilita a troca por Postgres depois):

```python
import os

ALLOWED_HOSTS = os.environ.get("DJANGO_ALLOWED_HOSTS", "*").split(",")

INSTALLED_APPS = [
    # ... apps padrão ...
    "rest_framework",
    "tarefas",
]

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": os.environ.get("SQLITE_PATH", BASE_DIR / "db.sqlite3"),
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

### `tarefas/serializers.py` (novo arquivo)

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
from django.urls import include, path
from rest_framework.routers import DefaultRouter
from tarefas.views import TarefaViewSet

router = DefaultRouter()
router.register("tarefas", TarefaViewSet)

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/", include(router.urls)),
]
```

Gere a migração (será versionada no Git):

```bash
python manage.py makemigrations tarefas
```

---

## Parte 3 - Docker

### `Dockerfile`

```dockerfile
FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["sh", "-c", "python manage.py migrate --noinput && gunicorn config.wsgi:application --bind 0.0.0.0:8000"]
```

O `migrate` roda ao iniciar, criando o arquivo do SQLite se ele não existir.

### `.dockerignore`

```
.venv/
__pycache__/
*.pyc
db.sqlite3
.git/
```

### `docker-compose.yml`

```yaml
services:
  web:
    build: .
    ports:
      - "8000:8000"
    environment:
      SQLITE_PATH: /data/db.sqlite3
    volumes:
      - sqlitedata:/data

volumes:
  sqlitedata:
```

O volume `sqlitedata` guarda o arquivo `.sqlite3` fora do container; sem ele, os dados seriam perdidos a cada recriação.

---

## Parte 4 - Executar e testar

```bash
docker compose up -d --build
docker compose logs -f web
```

```bash
curl http://localhost:8000/api/tarefas/
curl -X POST http://localhost:8000/api/tarefas/ -H "Content-Type: application/json" -d '{"titulo":"Estudar Docker"}'
curl http://localhost:8000/api/tarefas/
```

No PowerShell, use `curl.exe` ou `Invoke-RestMethod`. Também é possível abrir `http://localhost:8000/api/tarefas/` no navegador.

### Testar a persistência

```bash
docker compose down
docker compose up -d
curl http://localhost:8000/api/tarefas/
```

A tarefa criada deve continuar na lista.

### (Opcional) Admin

```bash
docker compose exec web python manage.py createsuperuser
```

Acesse `http://localhost:8000/admin/`. Sem arquivos estáticos configurados, o admin aparece sem estilo; isso é esperado neste roteiro inicial.

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

- **`DisallowedHost`**: defina `DJANGO_ALLOWED_HOSTS` ou mantenha o padrão `*` (somente em desenvolvimento).
- **`no such table`**: faltou a migração; confira se `tarefas/migrations/` existe e rebuild a imagem.
- **Dados sumiram**: provavelmente foi usado `docker compose down -v`, que remove o volume.
- **Porta 8000 ocupada**: troque para `"8001:8000"` no Compose.

## Limitações do SQLite (por que evoluir)

- Um único arquivo: não suporta bem várias instâncias/containers escrevendo ao mesmo tempo.
- Menos recursos que o PostgreSQL (tipos, extensões, concorrência).
- Backup e escala dependem de copiar o arquivo.

## Próximo passo

Siga [djangopg.md](./djangopg.md) e [preparopg.md](./preparopg.md) para trocar o SQLite pelo PostgreSQL em container. A mudança se resume a: ajustar `DATABASES` em `settings.py` para ler as variáveis `POSTGRES_*`, adicionar `psycopg[binary]` ao `requirements.txt` e incluir o serviço `db` no Compose.
