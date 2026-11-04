### 📋 Roteiro Prático: Banco PostgreSQL com Documentos JSONB

#### **Objetivo da Atividade**
Capacitar o aluno a integrar o paradigma de documentos (*schema-on-read*) com o modelo relacional tradicional, resolvendo cenários de dados variáveis e acelerando buscas com índices **GIN**.

---

#### **Etapa 1: Entendendo o Problema de Modelagem**
Antes de criar as tabelas, apresente o cenário em que o modelo relacional puro falha:
* **O problema:** Tentar modelar um catálogo flexível (ex.: itens de entrega que variam entre alimentos refrigerados, eletrônicos frágeis ou móveis pesados) usando tabelas relacionais puras gera centenas de colunas com valores `NULL` ou estruturas ineficientes.
* **A solução:** Utilizar o tipo **`JSONB`** (formato binário decomposto, indexável e de rápida navegação) para armazenar metadados heterogêneos mantendo chaves estrangeiras com o ecossistema relacional.

---

#### **Etapa 2: Criação da Tabela Híbrida**
O aluno deve executar o script DDL para criar a tabela `delivery_manifests`, fazendo a ponte entre a tabela relacional de entregas (`deliveries`) e os documentos semiestruturados:

```sql
-- Criação da tabela híbrida (Relacional + JSONB)
CREATE TABLE delivery_manifests (
    id SERIAL PRIMARY KEY,
    delivery_id INT NOT NULL, -- Chave estrangeira para a tabela relacional 'deliveries'
    manifest_type VARCHAR(50) NOT NULL, -- Ex: 'food', 'fragile', 'oversized'
    payload JSONB NOT NULL,             -- Documento flexível
    created_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT fk_delivery FOREIGN KEY (delivery_id) REFERENCES deliveries(id)
);
```

---

#### **Etapa 3: Inserção de Dados Heterogêneos (Schema-on-Read)**
Oriente o aluno a inserir registros com estruturas totalmente distintas na coluna `payload`, provando a flexibilidade do `JSONB` sem necessidade de alterar o schema do banco:

```sql
INSERT INTO delivery_manifests (delivery_id, manifest_type, payload) VALUES
(1, 'food', '{
    "category": "perishable",
    "items": [{"name": "Açaí Premium", "temp_celsius": -18, "weight_kg": 2.5}],
    "requires_thermal_bag": true
}'),
(2, 'fragile', '{
    "category": "electronics",
    "items": [{"name": "Monitor 4K OLED", "fragile": true, "weight_kg": 8.5, "insurance_value": 4500}],
    "requires_signature": true
}'),
(3, 'oversized', '{
    "category": "furniture",
    "items": [{"name": "Sofá 3 Lugares", "dimensions_cm":, "weight_kg": 45.0}],
    "requires_forklift": false,
    "assembly_required": true
}');
```

---

#### **Etapa 4: Navegação e Operadores Nativos JSONB**
Solicite aos alunos que pratiquem os principais operadores de consulta em `JSONB`:

1. **Navegação (`->` vs `->>`):**
   * `->` retorna um objeto JSON/JSONB.
   * `->>` retorna o valor convertido para texto.
   ```sql
   -- Extrair o tipo de manifesto e o nome do primeiro item como texto
   SELECT manifest_type, payload->'items'->0->>'name' AS item_name
   FROM delivery_manifests;
   ```

2. **Operador de Contenção (`@>`):**
   * Verifica se o documento JSON da esquerda contém a estrutura da direita.
   ```sql
   -- Buscar apenas manifestos que exigem bolsa térmica
   SELECT * FROM delivery_manifests 
   WHERE payload @> '{"requires_thermal_bag": true}';
   ```

---

#### **Etapa 5: Otimização de Performance com Índice GIN**
Demonstre a diferença entre uma busca linear (varredura sequencial) e uma busca indexada no documento:

1. **Análise de Busca Sequencial:**
   Peça ao aluno para executar o `EXPLAIN ANALYZE` antes do índice para observar o custo do `Seq Scan`:
   ```sql
   EXPLAIN ANALYZE 
   SELECT * FROM delivery_manifests 
   WHERE payload @> '{"requires_thermal_bag": true}';
   ```

2. **Criação do Índice Invertido Generalizado (GIN):**
   Explicar que o índice GIN "desmonta" a estrutura do JSONB e indexa cada par chave-valor individualmente:
   ```sql
   CREATE INDEX idx_manifest_payload_gin ON delivery_manifests USING GIN (payload);
   ```

3. **Validação do Ganho de Performance:**
   Ao reexecutar o `EXPLAIN ANALYZE`, mostre que o plano de execução mudou para **Bitmap Index Scan**, comprovando a otimização.

---

#### **Etapa 6: Desafio Prático e Consulta Avançada (JSON Path)**
* **Desafio:** "Localize todos os manifestos que contenham itens onde `'fragile': true` **E** com `'weight_kg' > 5`".
* **Armadilha comum a alertar:** O operador `@>` do índice GIN busca existência/contenção exata, mas não suporta comparações numéricas do tipo maior que (`>`) nativamente no JSON.
* **Resolução recomendada (PostgreSQL 12+ / JSON Path):**
  ```sql
  SELECT id, manifest_type, payload
  FROM delivery_manifests
  WHERE jsonb_path_exists(
      payload, 
      '$.items[*] ? (@.fragile == true && @.weight_kg > 5)'
  );
  ```

---

#### **Entregável do Aluno**
O aluno deve submeter um script `.sql` contendo os comandos de criação de tabela, inserções, criação do índice GIN, e a query do desafio acompanhada pelo resultado do `EXPLAIN ANALYZE`.

---

💡 Gostaria que eu elaborasse um guia de avaliação (rubrica) ou um teste automatizado em SQL para validar os entregáveis dos alunos?