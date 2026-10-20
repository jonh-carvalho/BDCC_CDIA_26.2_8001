# Plano de Aula: Módulo 1 — Semana 2

## Tema: O Paradigma Documento — Catálogos Flexíveis

**Duração Total:** 4 horas (1h Teoria + 3h Prática)
**Público-alvo:** Engenheiros de Dados, Desenvolvedores Backend, Arquitetos de Software.
**Pré-requisitos:** PostgreSQL 16 rodando (configurado na Semana 1) e conhecimento básico de SQL.

---

### Objetivos de Aprendizagem

Ao final, serão capazes de:

1. Identificar cenários onde o modelo relacional puro gera "gargalos de modelagem" (ex: tabelas com dezenas de colunas `NULL`).
2. Utilizar o tipo `JSONB` do PostgreSQL para implementar o padrão *schema-on-read*.
3. Manipular e consultar dados semiestruturados usando operadores nativos (`@>`, `?`, `?|`).
4. Criar e otimizar buscas em documentos JSON utilizando índices `GIN`.

---

### Cronograma Detalhado

#### BLOCO 1: Teoria 

**1.1. A Dor do Relacional em Dados Variáveis**

*   **Cenário Problema:** Como modelar uma tabela `delivery_items` para uma logística que transporta *de tudo*?
    *   *Entrega de Comida:* Precisa de controle de temperatura, tempo de validade.
    *   *Entrega de Documentos:* Precisa de peso volumétrico, código de rastreio físico.
    *   *Entrega de Mudança:* Precisa de contagem de caixas, requer carroça/elevador.
*   **Abordagens Ruins no SQL:** 
    *   *Tabela larga:* 50 colunas, 90% delas `NULL` (wasted space, hard to maintain).
    *   *EAV (Entity-Attribute-Value):* Pesadelo de performance para leituras (muitos JOINs na mesma tabela).
*   **A Solução:** O paradigma de documento e o *schema-on-read* (a estrutura é validada na leitura/aplicação, não na escrita no banco).

**1.2. JSONB no PostgreSQL**
*   Diferença entre `JSON` (texto puro, reparsa toda hora) e `JSONB` (binário decomposto, indexável, rápido).
*   **Operadores Essenciais (Demonstrar no slide/datashow):**
    *   `@>` (Contém): O documento à esquerda contém o da direita?
    *   `?` (Existe chave): A chave existe no nível raiz?
    *   `?|` (Existe alguma das chaves): OR lógico para chaves.
    *   `->` vs `->>`: Navegação (retorna JSON vs retorna Texto).


---

#### BLOCO 2: Prática — Setup e Modelagem 

**2.1. Criação da Tabela Híbrida **
*   Os alunos devem criar a tabela `delivery_manifests` que faz ponte entre o relacional (Semana 1) e o documento.
```sql
-- No psql ou DBeaver/pgAdmin
CREATE TABLE delivery_manifests (
    id SERIAL PRIMARY KEY,
    delivery_id INT NOT NULL, -- FK para a tabela 'deliveries' da Semana 1
    manifest_type VARCHAR(50) NOT NULL, -- Ex: 'food', 'fragile', 'documents'
    payload JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT fk_delivery FOREIGN KEY (delivery_id) REFERENCES deliveries(id)
);
```

**2.2. Inserção de Dados Heterogêneos **
*   Fornecer um script `INSERT` para os alunos executarem, demonstrando a flexibilidade do `payload`.
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
    "items": [{"name": "Sofá 3 Lugares", "dimensions_cm": [220, 90, 85], "weight_kg": 45.0}],
    "requires_forklift": false,
    "assembly_required": true
}');
```
*   *Mini-desafio rápido:* Peça para eles escreverem uma query que retorne apenas o `manifest_type` e o `name` do primeiro item do JSON.

---

#### BLOCO 3: Prática — Índices e Performance 
**3.1. O Problema da Busca Linear **
*   Rodar uma query filtrando o JSON *sem índice* e mostrar o `EXPLAIN ANALYZE` (Seq Scan).
```sql
-- Query ineficiente sem índice
SELECT * FROM delivery_manifests 
WHERE payload @> '{"requires_thermal_bag": true}';
```

**3.2. O Poder do Índice GIN **
*   **Conceito:** Generalized Inverted Index (Índice Invertido Generalizado). Explicar que ele "desmonta" o JSON e indexa cada par chave-valor.
*   **Ação:** Criar o índice.
```sql
CREATE INDEX idx_manifest_payload_gin ON delivery_manifests USING GIN (payload);
```
*   **Validação:** Rodar o `EXPLAIN ANALYZE` novamente. Mostrar a mudança de *Seq Scan* para *Bitmap Index Scan* (GIN).
*   *Dica de Ouro do Instrutor:* Mostrar que o GIN é ótimo para `@>` e `?`, mas **péssimo** para comparações numéricas dentro do JSON (ex: `weight_kg > 5`). Isso gera o gancho para o Desafio.

---

#### BLOCO 4: O Desafio e Consolidação 
**4.1. O Desafio da Semana (40 min)**
*   **Briefing do Desafio:** "O setor de seguros precisa de um relatório urgente. Precisamos encontrar todos os manifestos que contenham itens classificados como `'fragile': true` E que tenham `'weight_kg' > 5`. Como o GIN não indexa cast numérico nativamente, como vocês resolvem isso de forma performática ou funcional?"
*   *Tempo para os alunos tentarem (individual ou em duplas).*

**4.2. Resolução Comentada (Gabarito) **
*   Abordagem 1 (SQL/JSON Path - *Recomendado para PG 12+*):
```sql
SELECT id, manifest_type, payload
FROM delivery_manifests
WHERE jsonb_path_exists(
    payload, 
    '$.items[*] ? (@.fragile == true && @.weight_kg > 5)'
);
```
*   Abordagem 2 (Desnormalização com Coluna Gerada - *Para performance extrema*):
```sql
-- Criando uma coluna gerada para indexar com B-Tree tradicional
ALTER TABLE delivery_manifests 
ADD COLUMN max_fragile_weight NUMERIC GENERATED ALWAYS AS (
    (SELECT MAX((item->>'weight_kg')::numeric) 
     FROM jsonb_array_elements(payload->'items') AS item 
     WHERE item->>'fragile' = 'true')
) STORED;

CREATE INDEX idx_fragile_weight ON delivery_manifests(max_fragile_weight);
```

**4.3. Wrap-up e Entrega **
*   Resumo dos conceitos.
*   Explicação de como empacotar o entregável.
