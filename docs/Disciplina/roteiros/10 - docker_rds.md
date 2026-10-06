## PostgreSQL no Docker

### Objetivo

Subir um banco PostgreSQL com suporte à extensão pgvector usando a imagem `pgvector/pgvector:pg16` em um container Docker, persistir os dados e conectar-se a ele (simulando um serviço gerenciado como o RDS).

### Pré-requisitos

- Docker instalado (`docker --version`)
*   **Amazon Linux 2023**
```bash
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
```
- Cliente `psql` (opcional) ou DBeaver/pgAdmin

### Parte 1 - Executando o PostgreSQL com `docker run`

1. Baixe a imagem:

```bash
docker pull pgvector/pgvector:pg16
```

2. Crie um volume para persistência:

```bash
docker volume create pgdata
```

3. Execute o container:

```bash
docker run -d --name meu-postgres -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin123 -e POSTGRES_DB=aula -p 5432:5432 -v pgdata:/var/lib/postgresql/data pgvector/pgvector:pg16
```

4. Verifique se está rodando:

```bash
docker ps
docker logs meu-postgres
```

### Parte 2 - Acessando o banco

Via container:

```bash
docker exec -it meu-postgres psql -U admin -d aula
```

Via cliente local:

```bash
psql -h localhost -p 5432 -U admin -d aula
```

### Parte 3 - Criando dados de teste

```sql
CREATE TABLE alunos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    curso VARCHAR(50)
);
```

```sql
INSERT INTO alunos (nome, curso) VALUES
('Ana', 'ADS'),
('Bruno', 'ADS');
```

```sql
SELECT * FROM alunos;
```

```sql
-- Habilite a extensão pgvector no banco aula
CREATE EXTENSION IF NOT EXISTS vector;
```

Saia com `\q`.

### Parte 4 - Testando a persistência

```bash
docker stop meu-postgres
docker rm meu-postgres
```

```bash
# Recrie o container com o mesmo comando da Parte 1 (passo 3)
docker exec -it meu-postgres psql -U admin -d aula -c "SELECT * FROM alunos;"
```

Os dados devem continuar disponíveis, pois estão no volume `pgdata`.

---

### Parte 5 - Usando Docker Compose

Crie o arquivo `docker-compose.yml`:

```yaml
services:
  db:
    image: pgvector/pgvector:pg16
    container_name: meu-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: admin123
      POSTGRES_DB: aula
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U admin -d aula"]
      interval: 10s
      timeout: 5s
      retries: 5

  pgadmin:
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@admin.com
      PGADMIN_DEFAULT_PASSWORD: admin123
    ports:
      - "8080:80"
    depends_on:
      - db

volumes:
  pgdata:
```

Comandos:

```bash
docker compose up -d
docker compose ps
docker compose down      # mantém os dados
docker compose down -v   # remove também o volume
```

Acesse o pgAdmin em `http://localhost:8080` e registre o servidor com host `db`, porta `5432`, usuário `admin`.

### Parte 6 - Backup e restore

```bash
docker exec meu-postgres pg_dump -U admin aula > backup.sql
docker exec -i meu-postgres psql -U admin -d aula < backup.sql
```

### Parte 7 - Executando na AWS EC2

O mesmo Docker Compose pode ser usado em uma instância EC2 Linux, com alguns cuidados:

1. Crie a instância em uma VPC e instale Docker e o plugin Docker Compose conforme as instruções da distribuição escolhida. Restrinja o acesso SSH (porta 22) ao seu IP.

```bash
# Amazon Linux 2023 
# Install docker
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker

# Install plugin docker compose v2
sudo yum install docker-compose-plugin -y
```

2. Transfira o `docker-compose.yml` para a instância e inicie os serviços com: 

```bash
docker compose up -d
``` 

Publique apenas as portas necessárias.

3. No grupo de segurança da EC2, não libere as portas `5432` nem `8080` para `0.0.0.0/0`. Se precisar de acesso direto, permita somente seu IP/CIDR. Prefira VPN, túnel SSH ou acesso por uma aplicação/backend dentro da VPC.

Evite expor o pgAdmin publicamente; se necessário, proteja-o com HTTPS e controles de acesso.

4. Troque as senhas de exemplo por senhas fortes e não armazene credenciais reais no repositório. Use um arquivo `.env` com permissões restritas ou um serviço de segredos; `.env` não é criptografado.
5. O volume nomeado `pgdata` persiste os dados no armazenamento da instância, mas não é backup e pode ser perdido junto com ela. Faça backups periódicos fora da EC2 (por exemplo, no Amazon S3), teste a restauração e planeje armazenamento persistente e recuperação.
6. Atualize o sistema e as imagens, monitore espaço em disco e logs. Uma única EC2 não oferece, por si só, alta disponibilidade nem backups gerenciados como o Amazon RDS.

Para desenvolvimento, acesse o banco sem abrir a porta publicamente usando um túnel SSH local, por exemplo `ssh -L 5433:localhost:5432 usuario@IP_PUBLICO_EC2`, e conecte o cliente a `localhost:5433`.

## Parte 8 - Backup e restore

```bash
docker exec meu-postgres pg_dump -U admin aula > backup.sql
docker exec -i meu-postgres psql -U admin -d aula < backup.sql
```

## Desafios

1. Altere a porta local para `5433` e conecte-se novamente.
2. Use um arquivo `.env` para guardar usuário e senha.
3. Adicione um script `init.sql` em `/docker-entrypoint-initdb.d/` para criar tabelas automaticamente.
4. Conecte uma aplicação (Python/Java) ao banco no container.

## Limpeza

```bash
docker compose down -v
docker rm -f meu-postgres
docker volume rm pgdata
```
