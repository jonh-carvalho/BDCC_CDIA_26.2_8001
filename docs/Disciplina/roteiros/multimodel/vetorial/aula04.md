# 🟡 Bloco 2 — Passo a Passo Detalhado
## Setup e Ingestão de Dados para o SwiftTrack IoT
**Duração:** 1h | **Foco:** Preparar o terreno para a busca semântica

---

## 📌 Visão Geral do Fluxo

```
┌─────────────┐    ┌──────────────┐    ┌──────────────┐    ┌─────────────┐
│  Endereços  │───▶│  sentence-   │───▶│  psycopg2 +  │───▶│ PostgreSQL  │
│  SwiftTrack │    │ transformers │    │ execute_values│    │ + pgvector  │
│   (CSV)     │    │  (MiniLM)    │    │   (bulk)     │    │             │
└─────────────┘    └──────────────┘    └──────────────┘    └─────────────┘
```

> **Nota didática:** Optamos pelo modelo local `all-MiniLM-L6-v2` (384 dimensões) em vez do OpenAI Ada-002 (1536 dim) por três motivos: (1) independência de API key, (2) execução offline em laboratório, (3) velocidade ~20x maior. Ajustaremos o schema para 384 dimensões — o conceito arquitetural é idêntico.

---

## 🔧 PASSO 1 — Setup do Ambiente Docker (10 min)

### 1.1. Verificar se o container do SwiftTrack está rodando

```bash
# Verificar containers ativos
docker ps | grep swifttrack

# Se NÃO estiver rodando, subir o ambiente completo
cd ~/swifttrack-iot/infra
docker-compose up -d postgres pgvector
```

### 1.2. Arquivo `docker-compose.yml` de referência

```yaml
version: '3.8'
services:
  postgres:
    image: pgvector/pgvector:pg16   # imagem oficial com pgvector pré-instalado
    container_name: swifttrack-db
    environment:
      POSTGRES_USER: swifttrack
      POSTGRES_PASSWORD: swifttrack123
      POSTGRES_DB: swifttrack_logistics
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U swifttrack"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  pgdata:
```

### 1.3. Conectar e validar

```bash
# Entrar no container
docker exec -it swifttrack-db psql -U swifttrack -d swifttrack_logistics

# Dentro do psql, verificar versão
SELECT version();
-- Deve retornar PostgreSQL 16.x

# Sair
\q
```

---

## 🔌 PASSO 2 — Instalação da Extensão pgvector (5 min)

```bash
docker exec -it swifttrack-db psql -U swifttrack -d swifttrack_logistics
```

```sql
-- Habilitar a extensão (executar uma única vez)
CREATE EXTENSION IF NOT EXISTS vector;

-- Verificar se foi instalada corretamente
SELECT * FROM pg_extension WHERE extname = 'vector';

-- Ver os tipos de dados disponíveis
SELECT typname FROM pg_type 
WHERE typname IN ('vector', 'halfvec', 'sparsevec', 'bit');
```

**Saída esperada:**
```
  typname  
-----------
 vector
 halfvec
 sparsevec
 bit
(4 rows)
```

> 💡 **Dica para o professor:** Se o `CREATE EXTENSION` falhar com "extension not found", a imagem Docker usada não tem o pgvector. Substituir por `pgvector/pgvector:pg16`.

---

## 🏗️ PASSO 3 — Modelagem da Tabela (10 min)

### 3.1. Schema completo com comentários didáticos

```sql
-- Limpar execuções anteriores (idempotência)
DROP TABLE IF EXISTS address_embeddings CASCADE;

-- Criar tabela principal
CREATE TABLE address_embeddings (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    raw_address     TEXT NOT NULL,           -- endereço original (como digitado pelo motorista)
    normalized_addr TEXT,                    -- versão normalizada (lowercase, sem acentos)
    hub_id          INT NOT NULL,            -- hub de origem (particionamento lógico)
    city            VARCHAR(100),
    embedding       vector(384) NOT NULL,    -- vetor do MiniLM (384 dim)
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    
    -- Restrições de domínio
    CONSTRAINT chk_hub_range CHECK (hub_id BETWEEN 1 AND 50)
);

-- Índices auxiliares (não vetoriais ainda — virão no Bloco 3)
CREATE INDEX idx_addr_hub ON address_embeddings(hub_id);
CREATE INDEX idx_addr_city ON address_embeddings(city);

-- Comentário da tabela para documentação
COMMENT ON TABLE address_embeddings IS 
    'Repositório vetorial de endereços do SwiftTrack para busca semântica last-mile';
```

### 3.2. Explicação campo a campo (para discutir com a turma)

| Campo | Justificativa Arquitetural |
|-------|----------------------------|
| `id UUID` | Evita exposição de sequências em APIs públicas do SwiftTrack |
| `raw_address` | Preserva o dado original para auditoria e debug |
| `normalized_addr` | Permite fallback para busca léxica (FTS) se a busca vetorial falhar |
| `hub_id` | Chave para **particionamento futuro** por hub (escalabilidade horizontal) |
| `embedding vector(384)` | Tipo nativo do pgvector; 384 = dimensão do MiniLM-L6-v2 |
| `created_at` | Rastreabilidade para invalidação de cache de embeddings |

---

## 📦 PASSO 4 — Dataset Seed do SwiftTrack (5 min)

### 4.1. Criar arquivo `seed_addresses.csv`

```csv
id,raw_address,hub_id,city
a001,"Rua das Flores, 123 - Apto 4",1,São Paulo
a002,"R. das Flores, 123",1,São Paulo
a003,"Rua das Flores cento e vinte e tres",1,São Paulo
a004,"Avenida Paulista, 1000 - 10o andar",1,São Paulo
a005,"Av Paulista mil",1,São Paulo
a006,"Ave Paulist 1000",1,São Paulo
a007,"Rua Augusta, 500",1,São Paulo
a008,"R. Augusta quinhentos",1,São Paulo
a009,"Rua Oscar Freire, 200",1,São Paulo
a010,"Alameda Santos, 1500",1,São Paulo
a011,"Rua Vergueiro, 3000",1,São Paulo
a012,"Avenida Brasil, 100",2,Rio de Janeiro
a013,"Av. Brasil cem",2,Rio de Janeiro
a014,"Rua Copacabana, 50",2,Rio de Janeiro
a015,"Praia de Ipanema, s/n",2,Rio de Janeiro
a016,"Rua XV de Novembro, 200",3,Curitiba
a017,"Rua XV novembro duzentos",3,Curitiba
a018,"Avenida Batel, 1000",3,Curitiba
a019,"Rua Marechal Deodoro, 500",4,Belo Horizonte
a020,"Av. Afonso Pena, 2000",4,Belo Horizonte
```

> 💡 **Observação pedagógica:** Note os pares semanticamente idênticos mas lexicalmente diferentes (ex: `a004`, `a005`, `a006`). É exatamente esse tipo de ambiguidade que o B-Tree não resolve e o pgvector resolve.

### 4.2. Carregar CSV no Postgres

```sql
-- Criar tabela temporária para import
CREATE TEMP TABLE tmp_addresses (
    id TEXT, raw_address TEXT, hub_id INT, city TEXT
);

-- Copiar dados (ajustar caminho conforme ambiente)
\copy tmp_addresses FROM '/data/seed_addresses.csv' CSV HEADER;

-- Inserir na tabela final (embedding será preenchido pelo Python)
INSERT INTO address_embeddings (id, raw_address, hub_id, city, embedding)
SELECT 
    id::UUID,
    raw_address,
    hub_id,
    city,
    '[0]'::vector  -- placeholder, será sobrescrito
FROM tmp_addresses;

DROP TABLE tmp_addresses;
```

---

## 🐍 PASSO 5 — Pipeline Python de Embeddings + Bulk Insert (25 min)

### 5.1. Instalação das dependências

```bash
# Em um ambiente virtual (recomendado)
python -m venv .venv && source .venv/bin/activate

pip install sentence-transformers psycopg2-binary numpy pandas
```

### 5.2. Script completo `ingest_embeddings.py`

```python
"""
SwiftTrack IoT - Pipeline de Ingestão de Embeddings
Semana 4 - Arquiteturas de Dados para IoT e Logística
"""
import os
import time
import numpy as np
import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
from sentence_transformers import SentenceTransformer

# ==================== CONFIGURAÇÃO ====================
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "swifttrack_logistics",
    "user": "swifttrack",
    "password": "swifttrack123"
}

MODEL_NAME = "all-MiniLM-L6-v2"  # 384 dimensões, ~80MB, roda em CPU
BATCH_SIZE = 32                    # tamanho do lote para inferência

# ==================== FUNÇÕES ====================

def load_model():
    """Carrega o modelo de embeddings (com cache local)."""
    print(f"📦 Carregando modelo {MODEL_NAME}...")
    t0 = time.time()
    model = SentenceTransformer(MODEL_NAME)
    print(f"✅ Modelo carregado em {time.time()-t0:.2f}s")
    print(f"   Dimensão do vetor: {model.get_sentence_embedding_dimension()}")
    return model


def fetch_addresses(conn):
    """Busca endereços sem embedding válido do Postgres."""
    query = """
        SELECT id, raw_address 
        FROM address_embeddings 
        WHERE embedding = '[0]'::vector
           OR embedding IS NULL
    """
    return pd.read_sql(query, conn)


def normalize_text(text: str) -> str:
    """Normalização mínima para melhorar qualidade do embedding."""
    import unicodedata
    # Remove acentos
    text = unicodedata.normalize('NFKD', text)\
                      .encode('ASCII', 'ignore').decode('ASCII')
    # Lowercase e trim
    return text.lower().strip()


def generate_embeddings(model, texts: list) -> np.ndarray:
    """Gera embeddings em lotes para eficiência de memória."""
    normalized = [normalize_text(t) for t in texts]
    embeddings = model.encode(
        normalized,
        batch_size=BATCH_SIZE,
        show_progress_bar=True,
        convert_to_numpy=True,
        normalize_embeddings=True  # importante para similaridade de cosseno
    )
    return embeddings


def bulk_insert_embeddings(conn, records: list):
    """
    Bulk insert otimizado com execute_values.
    records: lista de tuplas (embedding_str, id)
    """
    update_query = """
        UPDATE address_embeddings
        SET embedding = data.embedding
        FROM (VALUES %s) AS data(embedding, id)
        WHERE address_embeddings.id = data.id::uuid
    """
    
    with conn.cursor() as cur:
        execute_values(cur, update_query, records, page_size=100)
    conn.commit()


# ==================== MAIN ====================

def main():
    print("=" * 60)
    print("🚚 SwiftTrack IoT - Pipeline de Embeddings")
    print("=" * 60)
    
    # 1. Carregar modelo
    model = load_model()
    
    # 2. Conectar ao Postgres
    print("\n🔌 Conectando ao PostgreSQL...")
    conn = psycopg2.connect(**DB_CONFIG)
    
    # 3. Buscar endereços pendentes
    print("📋 Buscando endereços para processar...")
    df = fetch_addresses(conn)
    print(f"   {len(df)} endereços encontrados")
    
    if df.empty:
        print("✅ Nada a processar. Saindo.")
        return
    
    # 4. Gerar embeddings
    print("\n🧠 Gerando embeddings...")
    t0 = time.time()
    embeddings = generate_embeddings(model, df['raw_address'].tolist())
    print(f"✅ Embeddings gerados em {time.time()-t0:.2f}s")
    print(f"   Shape: {embeddings.shape}")
    
    # 5. Preparar registros para bulk update
    records = []
    for i, row in df.iterrows():
        # pgvector aceita string no formato '[0.1, 0.2, ...]'
        vec_str = "[" + ",".join(f"{x:.6f}" for x in embeddings[i]) + "]"
        records.append((vec_str, str(row['id'])))
    
    # 6. Bulk insert
    print("\n💾 Gravando embeddings no Postgres...")
    t0 = time.time()
    bulk_insert_embeddings(conn, records)
    print(f"✅ {len(records)} embeddings gravados em {time.time()-t0:.2f}s")
    
    # 7. Verificação final
    print("\n🔍 Verificação final...")
    check_query = """
        SELECT 
            COUNT(*) AS total,
            COUNT(embedding) FILTER (WHERE embedding != '[0]'::vector) AS populados,
            pg_size_pretty(pg_total_relation_size('address_embeddings')) AS tamanho
        FROM address_embeddings
    """
    result = pd.read_sql(check_query, conn)
    print(result.to_string(index=False))
    
    conn.close()
    print("\n🎉 Pipeline concluído com sucesso!")


if __name__ == "__main__":
    main()
```

### 5.3. Executar o pipeline

```bash
python ingest_embeddings.py
```

**Saída esperada:**
```
============================================================
🚚 SwiftTrack IoT - Pipeline de Embeddings
============================================================
📦 Carregando modelo all-MiniLM-L6-v2...
✅ Modelo carregado em 2.34s
   Dimensão do vetor: 384

🔌 Conectando ao PostgreSQL...
📋 Buscando endereços para processar...
   20 endereços encontrados

🧠 Gerando embeddings...
Batches: 100%|████████████| 1/1 [00:00<00:00, 12.34it/s]
✅ Embeddings gerados em 0.15s
   Shape: (20, 384)

💾 Gravando embeddings no Postgres...
✅ 20 embeddings gravados em 0.08s

🔍 Verificação final...
 total  populados tamanho
    20         20  48 kB

🎉 Pipeline concluído com sucesso!
```

---

## ✅ PASSO 6 — Validação Final (5 min)

### 6.1. Verificar dados no Postgres

```sql
-- Ver amostra dos embeddings
SELECT 
    id,
    raw_address,
    hub_id,
    vector_dims(embedding) AS dims,
    substring(embedding::text, 1, 60) || '...' AS embedding_preview
FROM address_embeddings
LIMIT 5;
```

### 6.2. Teste rápido de similaridade (prévia do Bloco 3)

```sql
-- Similaridade entre "Avenida Paulista 1000" e "Av Paulista mil"
SELECT 
    a.raw_address AS endereco_a,
    b.raw_address AS endereco_b,
    1 - (a.embedding <=> b.embedding) AS cosine_similarity
FROM address_embeddings a
CROSS JOIN address_embeddings b
WHERE a.id = 'a004' AND b.id = 'a005';
```

**Saída esperada:** similaridade > 0.85 (os vetores são semanticamente próximos).

---

## 🎯 Checklist de Conclusão do Bloco 2

- [ ] Container Docker `swifttrack-db` rodando e saudável
- [ ] Extensão `pgvector` instalada e verificada
- [ ] Tabela `address_embeddings` criada com schema correto
- [ ] 20 endereços seed carregados do CSV
- [ ] Modelo `all-MiniLM-L6-v2` baixado e funcionando
- [ ] Pipeline Python executado sem erros
- [ ] Todos os embeddings populados (verificado via SQL)
- [ ] Teste de similaridade cruzada mostrando coerência semântica

---

## 🐛 Troubleshooting Comum

| Problema | Causa | Solução |
|----------|-------|---------|
| `ERROR: extension "vector" does not exist` | Imagem Docker sem pgvector | Usar `pgvector/pgvector:pg16` |
| `Connection refused` no Python | Container não expôs porta | Verificar `ports: "5432:5432"` no compose |
| `CUDA out of memory` | GPU pequena | Forçar CPU: `model = SentenceTransformer(..., device='cpu')` |
| `invalid input syntax for type vector` | Formato do vetor errado | Usar `"[0.1,0.2,0.3]"` (sem espaços após vírgula) |
| Pipeline lento (>30s p/ 20 endereços) | Rede baixa p/ baixar modelo | Baixar modelo antecipadamente: `python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('all-MiniLM-L6-v2')"` |

---

## 📚 Pontos de Discussão para o Professor

Durante a execução, vale pausar e questionar a turma:

1. **"Por que normalizamos o texto antes do embedding?"**  
   → Resposta esperada: Reduz ruído, melhora generalização, mas modelos modernos (MiniLM) já são razoavelmente robustos a acentos.

2. **"Por que `normalize_embeddings=True`?"**  
   → Resposta esperada: Vetores unitários permitem que produto interno = similaridade de cosseno, mais rápido que calcular cosseno diretamente.

3. **"Por que `execute_values` em vez de `UPDATE` linha a linha?"**  
   → Resposta esperada: Reduz round-trips de rede de O(N) para O(N/page_size). Em 10k endereços, a diferença é de minutos para segundos.

4. **"Onde esse pipeline rodaria em produção no SwiftTrack?"**  
   → Resposta esperada: Airflow/Dagster rodando em batch noturno + endpoint síncrono no backend Python para endereços novos em tempo real.

---
