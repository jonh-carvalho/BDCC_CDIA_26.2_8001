# Preparando PostgreSQL no Docker

## Objetivo

Subir um banco PostgreSQL em container Docker, criar um usuário próprio para a aplicação Django, verificar a conexão e manter os dados em um volume persistente.

O roteiro usa Docker Compose. O serviço do banco se chamará `db`; esse nome será também o host usado pelo Django quando os dois containers estiverem na mesma rede Compose.

## Pré-requisitos

- Docker instalado e em execução
- Docker Compose disponível (`docker compose version`)
- Terminal (PowerShell, Linux ou macOS)

## 1. Criar a pasta e proteger as credenciais

Na pasta do projeto, crie um arquivo `.env.db` para a inicialização do PostgreSQL:

```env
POSTGRES_DB=appdb
POSTGRES_USER=pgadmin
POSTGRES_PASSWORD=troque-por-uma-senha-forte
```

O usuário `pgadmin` será usado apenas para administrar o banco. A aplicação deve se conectar usando um usuário separado, criado adiante. Depois, crie também um `.env` com as credenciais da aplicação:

```env
POSTGRES_DB=appdb
POSTGRES_USER=appuser
POSTGRES_PASSWORD=senha-da-aplicacao
POSTGRES_HOST=db
POSTGRES_PORT=5432
```

Adicione os dois arquivos ao `.gitignore` para não enviar senhas ao repositório:

```gitignore
.env
.env.db
```

Não use as senhas de exemplo em um ambiente real.

## 2. Definir o serviço PostgreSQL

Crie ou atualize `docker-compose.yml`:

```yaml
services:
  db:
    image: postgres:16
    restart: unless-stopped
    env_file:
      - .env.db
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}"]
      interval: 5s
      timeout: 3s
      retries: 10

volumes:
  pgdata:
```

O volume `pgdata` guarda os arquivos do banco fora do ciclo de vida do container. Não há publicação da porta `5432`: outros serviços no mesmo Compose acessam o banco pela rede interna, usando `db:5432`.

> Se o projeto já possui `docker-compose.yml`, integre o serviço `db` e o volume `pgdata` ao arquivo existente; não mantenha dois arquivos Compose concorrentes sem necessidade.

## 3. Iniciar e conferir o banco

Na pasta onde está o Compose:

```bash
docker compose up -d db
docker compose ps
docker compose logs db
```

Espere o serviço ficar como `healthy`. Se ele aparecer como `starting`, aguarde alguns segundos e consulte `docker compose ps` novamente.

## 4. Acessar o PostgreSQL

Abra o cliente `psql` dentro do container:

```bash
docker compose exec db psql -U pgadmin -d appdb
```

No prompt do `psql`, confira os bancos, usuários e a conexão atual:

```sql
\l
\du
SELECT current_database(), current_user;
```

Saia do cliente com `\q`.

## 5. Criar um usuário para o Django

Não use o usuário administrador `pgadmin` nas configurações do Django. Abra o `psql` como administrador e crie um usuário da aplicação:

```bash
docker compose exec db psql -U pgadmin -d appdb
```

No `psql`, crie a role. O comando `\password` solicita a senha sem deixá-la escrita no histórico SQL:

```sql
CREATE ROLE appuser LOGIN;
\password appuser
GRANT CONNECT ON DATABASE appdb TO appuser;
GRANT USAGE, CREATE ON SCHEMA public TO appuser;
\du
\q
```

Guarde a senha informada para configurar o Django. Em versões recentes do PostgreSQL, conceder explicitamente `CREATE` no schema `public` permite que o Django crie as tabelas durante as migrações.

## 6. Conectar a aplicação Django

Se Django e PostgreSQL estão no mesmo `docker-compose.yml`, configure o serviço Django (`web`) para carregar o `.env` com as credenciais de `appuser`:

```yaml
  web:
    # build, depends_on e demais configurações da aplicação
    env_file:
      - .env
```

O `.env` contém a senha configurada ao criar `appuser`; não altere as variáveis administrativas de `.env.db`. O serviço `db` precisa estar na mesma rede Compose que o serviço Django. Exemplo de configuração do banco em `settings.py`:

```python
import os

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
```

Com o serviço Django chamado `web`, valide a conexão e aplique as migrações:

```bash
docker compose up -d
docker compose exec web python manage.py migrate
```

As migrações do Django criam e atualizam as tabelas da aplicação. Em um projeto Django, normalmente não é necessário criar manualmente no PostgreSQL as tabelas correspondentes aos modelos.

## 7. Testar dados e persistência

Confira as tabelas criadas pelo Django:

```bash
docker compose exec db psql -U appuser -d appdb -c "\dt"
```

Pare e recrie apenas o container:

```bash
docker compose stop db
docker compose up -d db
```

Confira novamente as tabelas. Elas continuam disponíveis porque os dados estão no volume `pgdata`, não apenas no container.

## 8. Acesso opcional com ferramenta local

Para conectar temporariamente com `psql`, DBeaver ou pgAdmin instalado na própria máquina, adicione ao serviço `db`:

```yaml
    ports:
      - "127.0.0.1:5432:5432"
```

Recrie o serviço e conecte-se com host `localhost`, porta `5432`, banco `appdb` e usuário `appuser`.

> Não publique a porta do PostgreSQL em `0.0.0.0` nem a libere no Security Group da EC2. Em produção, deixe o banco acessível apenas pela rede privada do Docker. Para acesso administrativo remoto, prefira um túnel SSH ou Systems Manager Session Manager.

## Comandos úteis

| Ação | Comando |
|---|---|
| Ver estado dos serviços | `docker compose ps` |
| Acompanhar logs do banco | `docker compose logs -f db` |
| Abrir `psql` como administrador | `docker compose exec db psql -U pgadmin -d appdb` |
| Abrir `psql` como usuário Django | `docker compose exec db psql -U appuser -d appdb` |
| Parar serviços sem apagar dados | `docker compose down` |
| Apagar também os dados persistidos | `docker compose down -v` |

## Problemas comuns

- **`password authentication failed`**: confira se o Django carrega `.env` e se os dados correspondem ao usuário criado. As variáveis em `.env.db` só inicializam credenciais quando o volume de dados está vazio; alterá-las depois não troca automaticamente a senha gravada no banco.
- **`could not translate host name "db"`**: Django e PostgreSQL provavelmente não estão na mesma rede Compose ou o host configurado não corresponde ao nome do serviço.
- **`connection refused`**: verifique `docker compose ps`, os logs e se o healthcheck passou.
- **Erro de permissão ao criar tabela/schema**: confirme que Django conecta como `appuser` e que ele recebeu `USAGE, CREATE` no schema `public`.
- **Banco ou tabelas sumiram**: confirme se o serviço ainda monta `pgdata` e se não foi executado `docker compose down -v`. Esse comando remove o volume e apaga os dados.

## Observações para EC2

- Mantenha a porta `5432` fechada no Security Group; o Django acessa o serviço pela rede interna do Compose.
- Armazene `.env` e `.env.db` somente na EC2, com permissões restritas, e não os versione.
- O volume Docker persiste dados quando o container é recriado, mas não substitui backup. Faça backups regulares e teste a restauração.
- Para produção com alta disponibilidade, recuperação gerenciada e manutenção simplificada, avalie usar Amazon RDS em vez de administrar o PostgreSQL na própria EC2.