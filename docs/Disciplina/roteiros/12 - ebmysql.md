# Django REST com RDS MySQL integrado ao Elastic Beanstalk

Este roteiro explica as alterações necessárias no projeto Django REST para usar um banco de dados MySQL no RDS acoplado ao Elastic Beanstalk.

### 🛠️ Parte 0: Preparação inicial

1. Verifique que o projeto já tenha `mysqlclient` instalado em `requirements.txt`.
   - No projeto atual há `mysqlclient==2.2.8`.
2. Confirme que `gunicorn`, `Django`, `djangorestframework` e `pillow` também estão no `requirements.txt`.
3. Certifique-se de que o Elastic Beanstalk está configurado para Python 3.12.

### 🔧 Parte 1: Ajustes no `catalogo/settings.py`

O código do projeto já está preparado para carregar o banco MySQL a partir de variáveis de ambiente. Use esta configuração principal em produção:

```python
import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

DEBUG = True if os.getenv('DJANGO_DEBUG', 'True') == 'True' else False

if DEBUG:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.mysql',
            'NAME': os.getenv('MYSQL_DATABASE', 'catalogo'),
            'USER': os.getenv('MYSQL_USER', 'root'),
            'PASSWORD': os.getenv('MYSQL_PASSWORD', '123456'),
            'HOST': os.getenv('MYSQL_HOST', '127.0.0.1'),
            'PORT': os.getenv('MYSQL_PORT', '3306'),
        }
    }
else:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.mysql',
            'NAME': os.getenv('RDS_DB_NAME', 'ebdb'),
            'USER': os.getenv('RDS_USERNAME', 'ebroot'),
            'PASSWORD': os.getenv('RDS_PASSWORD', ''),
            'HOST': os.getenv('RDS_HOSTNAME', ''),
            'PORT': os.getenv('RDS_PORT', '3306'),
        }
    }
```

4. Mantenha `ALLOWED_HOSTS` configurado por variável de ambiente:

```python
ALLOWED_HOSTS = os.getenv(
    'DJANGO_ALLOWED_HOSTS',
    'localhost,127.0.0.1,.elasticbeanstalk.com'
).split(',')
```

5. Em produção, use `DEBUG=False` no EB.

### 📦 Parte 2: Configuração do Elastic Beanstalk com RDS integrado

#### Opção A: Criar ambiente EB com RDS integrado

1. No console Elastic Beanstalk, crie um novo ambiente Python.
2. Durante a criação do ambiente, em **Database**, adicione um banco de dados MySQL.
3. Defina:
   - Engine: MySQL
   - Version: compatível com seu projeto
   - DB instance class: `db.t4g.micro` ou similar para laboratório
   - Storage: 20 GiB ou conforme necessário
4. Complete a criação do ambiente.

Quando o ambiente for criado, o Beanstalk fornecerá automaticamente variáveis de ambiente:
- `RDS_DB_NAME`
- `RDS_USERNAME`
- `RDS_PASSWORD`
- `RDS_HOSTNAME`
- `RDS_PORT`

#### Opção B: Criar ambiente EB e anexar RDS depois

1. Crie o banco RDS MySQL separadamente no console AWS.
2. No ambiente EB, abra **Configuration > Software**.
3. Adicione as variáveis de ambiente abaixo com os valores do RDS:
   - `RDS_DB_NAME`
   - `RDS_USERNAME`
   - `RDS_PASSWORD`
   - `RDS_HOSTNAME`
   - `RDS_PORT`
   - `DJANGO_DEBUG=False`
   - `DJANGO_ALLOWED_HOSTS=<seu-dominio>,.elasticbeanstalk.com`

### 📄 Parte 3: `.ebextensions` e `Procfile`

1. Garanta que seu `Procfile` esteja assim:

```
web: gunicorn catalogo.wsgi:application --bind 127.0.0.1:8000
```

2. No `.ebextensions/django.config`, inclua comandos para migrar o banco e coletar estáticos:

```yaml
option_settings:
  aws:elasticbeanstalk:container:python:
    WSGIPath: catalogo/wsgi.py
  aws:elasticbeanstalk:application:environment:
    DJANGO_SETTINGS_MODULE: catalogo.settings
    DJANGO_DEBUG: False
  aws:elasticbeanstalk:environment:proxy:staticfiles:
    /static: staticfiles
    /media: media
container_commands:
  01_migrate:
    command: "python manage.py migrate --noinput"
    leader_only: true
  02_collectstatic:
    command: "python manage.py collectstatic --noinput"
    leader_only: true
```

3. Não é necessário setar explicitamente as variáveis `RDS_*` no `.ebextensions` se o banco for criado pelo próprio EB, porque elas já são injetadas no ambiente.

### 🧪 Parte 4: Teste local antes do deploy

1. Instale as dependências:
   ```bash
   pip install -r requirements.txt
   ```
2. Se usar MySQL local, verifique o servidor MySQL e configure as variáveis:
   - `MYSQL_DATABASE`
   - `MYSQL_USER`
   - `MYSQL_PASSWORD`
   - `MYSQL_HOST`
   - `MYSQL_PORT`

3. Rode as migrações:
   ```bash
   python manage.py migrate
   ```
4. Inicie o servidor:
   ```bash
   python manage.py runserver
   ```

### 🚀 Parte 5: Deploy no Elastic Beanstalk

1. Gere o ZIP do projeto com arquivos na raiz (sem pasta pai).
2. Não inclua:
   - `venv/` ou `.venv/`
   - `.git/`
   - `db.sqlite3`
   - `__pycache__/`
   - `.env`
3. Faça o upload para o EB.
4. Verifique se o ambiente está `Green`.
5. Acesse:
   - `https://<seu-dominio>/`
   - `https://<seu-dominio>/api/produtos/`

### ✅ Checklist final para RDS MySQL no EB

- [ ] `requirements.txt` contém `mysqlclient` e `gunicorn`
- [ ] `catalogo/settings.py` usa `django.db.backends.mysql` em produção
- [ ] `DEBUG=False` no ambiente EB
- [ ] `DJANGO_ALLOWED_HOSTS` configurado corretamente
- [ ] `.ebextensions/django.config` executa migrate e collectstatic
- [ ] RDS integrado criado pelo Beanstalk ou variáveis `RDS_*` definidas manualmente
- [ ] ZIP de deploy não contém `db.sqlite3`, `venv`, `.git` ou arquivos sensíveis
- [ ] Ambiente EB ficou `Green`
- [ ] Endpoints `healthcheck` e `/api/produtos/` respondem corretamente
