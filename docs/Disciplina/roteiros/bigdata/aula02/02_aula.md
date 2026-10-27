-- Active: 1792551606560@@127.0.0.1@5432
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
* *Mini-desafio rápido:* escrever uma query que retorne apenas o `manifest_type` e o `name` do primeiro item do JSON.

```sql
SELECT manifest_type, payload->'items'->0->>'name' AS first_item
FROM delivery_manifests;
#```   


---

#### BLOCO 3: Prática — Índices e Performance 
**3.1. O Problema da Busca Linear **
*   **Objetivo:** observar o custo de procurar uma chave dentro de documentos sem um índice apropriado.
*   Antes de começar, confirme que a tabela contém os dados da prática e verifique se já existe um índice em `payload`:
```sql
\d delivery_manifests
```
*   Apresente a consulta e peça que os alunos prevejam quais linhas serão retornadas. Em seguida, execute-a com `EXPLAIN (ANALYZE, BUFFERS)` para inspecionar o plano:
```sql
-- O operador @> verifica se o documento contém o fragmento informado.
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, manifest_type
FROM delivery_manifests
WHERE payload @> '{"requires_thermal_bag": true}';
```
*   **Leitura guiada do plano:**
    *   `Seq Scan` significa que o PostgreSQL percorreu as linhas da tabela e avaliou o filtro em cada documento.
    *   `Rows Removed by Filter` indica quantas linhas foram examinadas, mas não atenderam à condição.
    *   `Execution Time` e `Buffers` ajudam a comparar o custo, mas variam conforme o volume de dados, o cache e o ambiente.
*   Com apenas os três registros de exemplo, o PostgreSQL pode preferir um `Seq Scan` mesmo após a criação do índice: para tabelas pequenas, ler tudo pode ser mais barato. Para comparar os planos, use uma tabela de demonstração maior ou trate a escolha como decisão do otimizador, não como garantia de uso do índice.

**3.2. O Poder do Índice GIN **
*   **Conceito:** GIN significa *Generalized Inverted Index* (Índice Invertido Generalizado). Em vez de guardar uma entrada por documento inteiro, o índice registra ocorrências de chaves e valores para localizar documentos candidatos com mais rapidez.
*   **Ação:** crie o índice e repita exatamente a consulta da etapa anterior:
```sql
CREATE INDEX idx_manifest_payload_gin ON delivery_manifests USING GIN (payload);

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, manifest_type
FROM delivery_manifests
WHERE payload @> '{"requires_thermal_bag": true}';
```
*   **Validação e interpretação:** quando o otimizador considerar vantajoso, o plano poderá mostrar `Bitmap Index Scan` usando `idx_manifest_payload_gin`, seguido de `Bitmap Heap Scan`, que busca as linhas correspondentes na tabela. Compare o plano e os buffers com a etapa anterior. A mudança não é garantida em tabelas pequenas ou quando o filtro retorna grande parte das linhas.
*   **Discussão sobre operadores:** o índice GIN padrão para `JSONB` (`jsonb_ops`) atende operadores como `@>` e `?`. Para cargas de trabalho focadas em contenção, existe também a classe `jsonb_path_ops`, que pode produzir um índice menor, mas não oferece o mesmo suporte a todos os operadores. Não é necessário criar ambos nesta atividade.
*   **Limite importante:** esse índice ajuda a localizar chaves e valores, mas não transforma uma comparação numérica como `weight_kg > 5` em uma busca indexada. Para esse tipo de consulta, é necessário extrair o valor e usar uma estratégia adequada, como uma coluna relacional ou um índice de expressão compatível. Esse ponto prepara o desafio do próximo bloco.

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
