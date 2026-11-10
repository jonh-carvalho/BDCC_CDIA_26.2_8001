# AP2 - Django API Multimodelo (PostgreSQL) em Docker na EC2 + Documentação RUP

## Objetivo

Evoluir o projeto da AP1 (Django Rest + SQLite no Elastic Beanstalk) para uma arquitetura mais próxima de produção:

- Migrar o **deploy** do Elastic Beanstalk para uma **instância EC2 com Docker e Docker Compose**, conforme os roteiros [13 - djangosqlitedocker](../Disciplina/roteiros/13%20-%20djangosqlitedocker.md) e [14 - djangopgdocker](../Disciplina/roteiros/14%20-%20djangopgdocker.md).
- Migrar o banco de **SQLite** para **PostgreSQL em container**, explorando o conceito **multimodelo** (relacional + documento/JSONB e, opcionalmente, vetorial, objetos ou grafos) vistos na disciplina.
- Entregar a **documentação completa** das fases Iniciação, Elaboração e Transição do RUP/UP no site MkDocs do repositório do grupo.

## Prazo e entrega

- **Prazo:** `17/11/2026` até as 9:20h. O envio é feito pelo **repositório do Grupo**
- O `README.md` deve conter: link da API publicada (`http://<IP-PUBLICO>:8000/api/`), link do site MkDocs publicado e a arquitetura da solução (diagramas).
- **Apresentação no Laboratório:** todos os membros devem apresentar algum aspecto (deploy, modelo de dados, API, documentação). Incluir um slide com os destaques.
- Todos presentes devem estar no **repositório do grupo** (professor como colaborador) com **commits individuais**. A ausência de commits de algum membro são penalizados na nota individual(ACs) para a disciplina Projeto de Cloud.
---

## Cenário

O grupo já possui um projeto Django Rest, no contexto do Tema do Projeto de Cloud, publicado no Beanstalk com SQLite. O cliente solicitou:

1. Retirar a dependência do Beanstalk e do SQLite, executando a solução em **EC2 + Docker Compose** (containers `web` e `db`).
2. Persistir os dados em **PostgreSQL** com volume Docker, com segredos fora do Git (`.env`).
3. Expor uma API que combine **dados relacionais** (ACID) com **dados semiestruturados** (JSONB) do domínio do Tema.
4. Formalizar o projeto com a documentação de Iniciação, Elaboração e Transição.

---

## Parte A - Aplicação Django API (PostgreSQL multimodelo)

### Requisitos mínimos

| # | Requisito |
|---|---|
| A1 | Projeto e app Django nomeados no contexto do Tema (sem `produtos`/`tarefas`). |
| A2 | **Mínimo de 4 models relacionais** com pelo menos 2 relacionamentos `ForeignKey` e 1 `ManyToMany` (ou tabela associativa com atributos), com migrations versionadas. |
| A3 | **Modelo documento:** pelo menos 1 model com `JSONField` (JSONB) para atributos flexíveis do Tema (ex.: cardápio, especificações, metadados), com **índice GIN** criado por migration. |
| A4 | **Transação:** ao menos 1 endpoint que grave em 2+ tabelas dentro de `transaction.atomic()`, com rollback em caso de violação de regra de negócio. |
| A5 | API DRF com CRUD completo dos models, serializers aninhados quando fizer sentido, e **ao menos 1 filtro por campo JSON** (ex.: `?atributos__chave=valor`). |
| A6 | Django Admin funcional com superusuário criado (via variáveis de ambiente ou `createsuperuser` no container). |
| A7 | Configuração por variáveis de ambiente (`POSTGRES_*`, `SECRET_KEY`, `DEBUG`, `ALLOWED_HOSTS`), sem segredos no código. |
| A8 | Dados de exemplo (seed/fixture) e ao menos 3 testes automatizados (`python manage.py test`). |

### Pontos extras (até +10)

Implementar **um** paradigma adicional no mesmo PostgreSQL, justificado no Tema:

- **Vetorial:** `pgvector` + endpoint de busca por similaridade.
- **Objetos:** upload de mídia em MinIO/S3 com `django-storages`.
- **Grafos:** Apache AGE com consulta Cypher (ex.: relacionamentos do domínio).

---

## Parte B - Deploy em EC2 com Docker

### Requisitos mínimos

| # | Requisito |
|---|---|
| B1 | Instância **EC2** (Amazon Linux/Ubuntu) com Docker, Docker Compose e Git instalados; **Security Group** liberando apenas SSH (22) e a porta da API (8000 ou 80); Postgres **não exposto** publicamente. |
| B2 | `Dockerfile` e `docker-compose.yml` com serviços `web` (Django) e `db` (Postgres), **volume nomeado** para os dados e `depends_on`/healthcheck. |
| B3 | `requirements.txt` com `psycopg[binary]`; `settings.py` lendo o banco do ambiente. |
| B4 | `.env` **fora do Git** (`.gitignore`) e `.env.example` versionado, sem senhas reais. |
| B5 | Fluxo do roteiro: código alterado no Windows → `git push` → `git pull` na EC2 → `docker-compose up -d --build`. Migrations e `collectstatic` executados no deploy. |
| B6 | API acessível pelo **IP público** e Django Admin operante. |
| B7 | **Persistência comprovada:** reiniciar os containers (`docker-compose down` / `up`) e demonstrar que os dados permanecem. |
| B8 | Evidências no README: prints de `docker ps`, `docker-compose logs`, acesso à API e à tabela no Postgres (`psql`). |

### Pontos extras (até +5)

- Proxy reverso Nginx na porta 80 ou HTTPS.
- Gunicorn no lugar do `runserver`.
- Script de deploy/backup (`pg_dump`) documentado.
- Elastic IP associado.

---

## Parte C - Documentação (MkDocs publicado)

Todos os documentos devem estar no site MkDocs do repositório (publicado via GitHub Pages), preenchidos **para o Tema do grupo**, sem trechos como `[NOME DO PROJETO]` ou `XXXX`, e consistentes com a aplicação implementada.

### Iniciação (`docs/Iniciacao`)

| Documento | Arquivo | Conteúdo esperado |
|---|---|---|
| Documento de Visão | `dv.md` | Problema, partes interessadas, necessidades, funcionalidades, restrições. |
| Requisitos Suplementares | `rs.md` | Desempenho, disponibilidade, segurança, operação, custo, SLA, riscos. Deve citar a decisão de usar EC2 + Docker + Postgres. |

### Elaboração (`docs/Elaboracao`)

| Documento | Arquivo | Conteúdo esperado |
|---|---|---|
| Casos de Uso Arquiteturais | `cua.md` | Casos de uso significativos para a arquitetura e diagramas. |
| Pacotes/Subsistemas | `maps.md` | Pacotes (Django apps, API, dados, infraestrutura, segurança), dependências e rastreabilidade. |
| Dimensionamento de Computação (EC2) | `dim_comp.md` | Tipo de instância justificado (CPU/RAM para `web` + `db`), classes de análise, diagrama PlantUML. |
| Dimensionamento de Banco de Dados | `dimrbd.md` | Volumetria, crescimento, memória de cálculo, armazenamento, backup/restauração. Comparar volume Docker em EC2 vs. RDS. |
| Sequência/Comunicação | `seq_com.md` | Fluxos críticos (ex.: criação de registro transacional, consulta por JSONB, deploy) e matriz de rastreamento. |
| Índice da fase | `index.md` | Resumo e links dos artefatos. |

### Transição (`docs/Transicao`)

| Documento | Arquivo | Conteúdo esperado |
|---|---|---|
| Estratégias de Deploy (Atividades) | `ativ_deploy.md` | Estratégias avaliadas (Beanstalk, EC2 + Docker, RDS, etc.), a escolhida, diagrama de atividades do deploy realizado, estimativa de tempo e custo, plano de rollback. |

### Critérios gerais de documentação

- Diagramas renderizando no site (Mermaid/PlantUML).
- Matrizes de rastreamento ligando requisito → caso de uso → componente → teste/evidência.
- Histórico de versões e aprovações preenchidos.
- Estimativa de custo mensal coerente com a infraestrutura usada.

---

## Entregáveis

1. Repositório GitHub (professor como colaborador) com código, `Dockerfile`, `docker-compose.yml`, `.env.example`, seed e testes.
2. `README.md` com: arquitetura (diagrama), execução local, passo a passo do deploy na EC2, links da API e do MkDocs, e evidências (B8).
3. Site MkDocs publicado com todos os documentos da Parte C.
4. API no ar na EC2 até a data/hora da avaliação.
5. Apresentação no laboratório (todos os membros).

---

## Critérios de Correção (100 pontos + extras)

| Eixo | Critério | Pontos |
|---|---|---|
| **App Django (35)** | Models relacionais e relacionamentos (A1, A2) | 10 |
| | Modelo documento JSONB + índice GIN + filtro (A3, A5) | 10 |
| | Transação e regra de negócio (A4) | 5 |
| | API/DRF, Admin, seed e testes (A5, A6, A8) | 10 |
| **Deploy (30)** | Dockerfile/Compose com Postgres e volume (B2, B3) | 8 |
| | Segredos e variáveis de ambiente (A7, B4) | 5 |
| | EC2 + Security Group e acesso por IP público (B1, B6) | 7 |
| | Fluxo Git (Windows → GitHub → EC2) e persistência (B5, B7) | 5 |
| | Evidências e README do deploy (B8) | 5 |
| **Documentação (30)** | Iniciação: `dv.md` e `rs.md` | 8 |
| | Elaboração: `cua`, `maps`, `dim_comp`, `dimrbd`, `seq_com` | 14 |
| | Transição: `ativ_deploy.md` | 5 |
| | Publicação do MkDocs e consistência com a aplicação | 3 |
| **Apresentação (5)** | Participação de todos os membros e clareza | 5 |
| **Extras** | Paradigma adicional (+10) e infraestrutura (+5) | até +15 (nota limitada a 10,0) |

### Penalidades

- Segredos (senhas, chaves) versionados no Git: **-10 pontos**.
- API fora do ar na data da avaliação: máximo de 50% do eixo Deploy.
- Documentos com texto de template não preenchido: pontuação proporcional zerada no item.


---

## Referências

- [Roteiro 13 - Django + SQLite + Docker](../Disciplina/roteiros/13%20-%20djangosqlitedocker.md)
- [Roteiro 14 - Django + PostgreSQL + Docker](../Disciplina/roteiros/14%20-%20djangopgdocker.md)
- [Django - PostgreSQL specific model fields](https://docs.djangoproject.com/en/stable/ref/contrib/postgres/fields/)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [Docker Compose](https://docs.docker.com/compose/)
- Material multimodelo da disciplina (relacional, documentos/JSONB, vetorial, objetos, grafos)
