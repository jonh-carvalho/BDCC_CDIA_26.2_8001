# Guia de Laboratório — Semana 3: Apache AGE e Grafos
## **SwiftTrack: Rede Logística com Grafos**

> **Objetivo:** Ao final deste laboratório, você terá um grafo logístico funcional no Apache AGE e será capaz de executar queries Cypher para análise de rotas, motoristas e entregas.

---

## **Pré-requisitos**

Antes de começar, verifique se você tem instalado:

| Ferramenta | Versão Mínima | Como verificar |
|------------|---------------|----------------|
| Docker Desktop | 4.x | `docker --version` |
| Git | 2.x | `git --version` |
| Editor de texto (VS Code recomendado) | - | - |
| Cliente SQL (pgAdmin, DBeaver ou psql) | - | - |

---

## **PASSO 1 — Preparar o Ambiente**

### 1.1 Criar a pasta do projeto

```bash
mkdir semana3_age
cd semana3_age
mkdir init-scripts
```

### 1.2 Criar o arquivo `docker-compose.yml`

```bash
# No Linux/Mac:
nano docker-compose.yml

# No Windows (PowerShell):
notepad docker-compose.yml
```

Cole o conteúdo:

```yaml
version: '3.8'
services:
  postgres-age:
    image: apache/age:latest
    container_name: swifttrack_age
    environment:
      POSTGRES_DB: swifttrack_graph
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secret123
    ports:
      - "5433:5432"
    volumes:
      - age_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U admin"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  age_data:
```

### 1.3 Subir o container

```bash
docker-compose up -d
```

### 1.4 Checkpoint 1 — Verificar se está rodando

```bash
docker ps
```

**Resultado esperado:**
```
CONTAINER ID   IMAGE              STATUS         PORTS                    NAMES
abc123...      apache/age:latest  Up 10 seconds  0.0.0.0:5433->5432/tcp   swifttrack_age
```

> **Se o STATUS for diferente de "Up"**, execute: `docker logs swifttrack_age` e chame o professor.

---

## **PASSO 2 — Conectar ao Banco de Dados**

### Opção A: Via terminal (mais rápido)

```bash
docker exec -it swifttrack_age psql -U admin -d swifttrack_graph
```

Você verá o prompt: `swifttrack_graph=#`

### Opção B: Via DBeaver/pgAdmin

| Campo | Valor |
|-------|-------|
| Host | `localhost` |
| Porta | `5433` |
| Database | `swifttrack_graph` |
| User | `admin` |
| Password | `secret123` |

### Checkpoint 2 — Testar conexão

No prompt SQL, execute:
```sql
SELECT version();
```

Deve retornar algo como: `PostgreSQL 16.x (Apache AGE 1.x.x)`

---

## **PASSO 3 — Habilitar a Extensão AGE**

No prompt SQL, execute:

```sql
-- Criar a extensão
CREATE EXTENSION IF NOT EXISTS age;

-- Carregar a biblioteca
LOAD 'age';

-- Configurar o caminho de busca (OBRIGATÓRIO para o AGE funcionar)
SET search_path = ag_catalog, "$user", public;

-- Criar o grafo
SELECT create_graph('logistics_network');

-- Verificar se foi criado
SELECT * FROM ag_graph;
```

### Checkpoint 3 — Verificar grafo criado

Deve aparecer uma linha com `name = 'logistics_network'`.

---

## **PASSO 4 — Criar os Nós (Vértices)**

### 4.1 Criar os 10 Hubs Logísticos

```sql
-- Hub São Paulo (Central)
SELECT * FROM cypher('logistics_network', $$
    CREATE (:Hub {
        id: 'HUB_SP', 
        name: 'São Paulo Central', 
        city: 'São Paulo', 
        state: 'SP',
        capacity: 5000
    })
$$) AS (result agtype);

-- Repita para os demais hubs (RJ, MG, PR, RS, DF, BA, PE, CE, AM)
-- [Ver arquivo completo 02_create_nodes.sql fornecido pelo professor]
```

> **Dica:** Execute o script completo `02_create_nodes.sql` fornecido pelo professor para criar todos os 10 hubs, 15 motoristas, 10 veículos e 20 clientes.

### Checkpoint 4 — Contar nós criados

```sql
SELECT * FROM cypher('logistics_network', $$
    MATCH (n) 
    RETURN labels(n)[0] AS tipo, count(*) AS quantidade
    ORDER BY quantidade DESC
$$) AS (tipo agtype, quantidade agtype);
```

**Resultado esperado:**
| tipo | quantidade |
|------|------------|
| Customer | 20 |
| Driver | 15 |
| Vehicle | 10 |
| Hub | 10 |

---

## **PASSO 5 — Criar os Relacionamentos (Arestas)**

Execute o script `03_create_relationships.sql` que contém:

1. **Rotas entre Hubs** (`CONNECTS_TO`) — com distância, tempo e custo
2. **Atribuições** (`ASSIGNED_TO`) — motoristas → veículos
3. **Entregas** (`DELIVERED`) — motoristas → clientes

### Checkpoint 5 — Contar relacionamentos

```sql
SELECT * FROM cypher('logistics_network', $$
    MATCH ()-[r]->() 
    RETURN type(r) AS tipo_rel, count(*) AS quantidade
    ORDER BY quantidade DESC
$$) AS (tipo_rel agtype, quantidade agtype);
```

**Resultado esperado:**
| tipo_rel | quantidade |
|----------|------------|
| CONNECTS_TO | 18 |
| DELIVERED | 15 |
| ASSIGNED_TO | 10 |

---

## **PASSO 6 — Executar Queries de Análise**

### Query 1: Caminho mais curto entre dois hubs

```sql
SELECT * FROM cypher('logistics_network', $$
    MATCH path = shortestPath(
        (start:Hub {id: 'HUB_SP'})-[:CONNECTS_TO*]->(end:Hub {id: 'HUB_PR'})
    )
    RETURN 
        [node IN nodes(path) | node.name] AS rota,
        reduce(dist = 0, rel IN relationships(path) | dist + rel.distance_km) AS distancia_km
$$) AS (rota agtype, distancia_km agtype);
```

### Query 2: Motoristas com mais entregas concluídas

```sql
SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver)-[:DELIVERED {status: 'completed'}]->(c:Customer)
    RETURN d.name AS motorista, count(c) AS entregas
    ORDER BY entregas DESC
    LIMIT 5
$$) AS (motorista agtype, entregas agtype);
```

### Query 3: Hubs mais conectados (análise de rede)

```sql
SELECT * FROM cypher('logistics_network', $$
    MATCH (hub:Hub)-[r:CONNECTS_TO]->()
    RETURN hub.name AS hub, count(r) AS conexoes
    ORDER BY conexoes DESC
$$) AS (hub agtype, conexoes agtype);
```

### Checkpoint 6 — Todas as queries devem retornar resultados sem erros

---

## **PASSO 7 — Desafio Prático (Individual/Dupla)**

**Enunciado:** Encontre a rota de **menor custo** entre São Paulo e Curitiba, considerando:
- Distância × custo por km de cada trecho
- Top 3 rotas mais baratas
- Para cada rota, sugira um motorista com rating > 4.5

**Dicas:**
- Use `MATCH path = (start)-[:CONNECTS_TO*1..3]->(end)`
- Use `reduce()` para calcular o custo total
- Combine com outra query para buscar motoristas qualificados

### Entrega
Salve sua solução em um arquivo `desafio_seu_nome.cypher` e envie ao professor.

---

## **PASSO 8 — Limpeza (Fim do Laboratório)**

Quando terminar, pare e remova o container:

```bash
# Parar o container
docker-compose down

# (Opcional) Remover também os dados persistidos
docker volume rm semana3_age_age_data
```

---

## **Troubleshooting — Problemas Comuns**

| Problema | Causa Provável | Solução |
|----------|----------------|---------|
| `container is not running` | Container falhou ao iniciar | `docker logs swifttrack_age` |
| `port is already allocated` | Porta 5433 em uso | Mude para `5434:5432` no compose |
| `function cypher does not exist` | `search_path` não configurado | Execute `SET search_path = ag_catalog, "$user", public;` |
| `graph does not exist` | Grafo não foi criado | Execute `SELECT create_graph('logistics_network');` |
| `permission denied` no volume | Permissão de pasta | Use volume nomeado (não bind mount) |

---

## **Comandos Rápidos de Referência**

```sql
-- Listar todos os nós
MATCH (n) RETURN labels(n)[0] AS tipo, count(*) ORDER BY tipo;

-- Listar todos os relacionamentos
MATCH ()-[r]->() RETURN type(r) AS tipo, count(*) ORDER BY tipo;

-- Ver propriedades de um nó específico
MATCH (h:Hub {id: 'HUB_SP'}) RETURN h;

-- Apagar todo o grafo (CUIDADO!)
SELECT drop_graph('logistics_network', true);
```