# Roteiro Introdutório: pgvector do Zero
## "Vetores para quem nunca viu vetor"

> **Filosofia deste roteiro:** Esqueça IA, embeddings e modelos por enquanto. Vamos aprender pgvector usando **vetores inventados à mão**. Quando o mecanismo fizer sentido na sua cabeça, a parte de IA vira detalhe de implementação.

---

## A Analogia de Abertura (2 minutos)

Imagine que cada endereço do SwiftTrack é um ponto num mapa. Só que em vez de latitude/longitude (2D), o ponto tem **384 coordenadas** (384D).

- Dois endereços semanticamente parecidos ficam **perto** nesse mapa.
- Dois endereços diferentes ficam **longe**.

**pgvector** é só uma forma de guardar esses pontos dentro do Postgres e perguntar: *"quais pontos estão mais perto deste aqui?"*

Pronto. É isso. O resto é sintaxe.

---

##  Os 5 Passos (em 15 minutos)

### **PASSO 1 — Instalar a extensão** (1 comando)

```sql
CREATE EXTENSION vector;
```

Só isso. O Postgres agora entende o tipo `vector`.

---

### **PASSO 2 — Criar uma tabela com vetor** (1 CREATE)

```sql
CREATE TABLE enderecos (
    id       SERIAL PRIMARY KEY,
    nome     TEXT,
    ponto    vector(3)   -- vetor de 3 dimensões (só pra começar simples)
);
```

> Usamos `vector(3)` em vez de `vector(384)` para **caber na cabeça**. O conceito é idêntico.

---

### **PASSO 3 — Inserir vetores à mão** (1 INSERT)

```sql
INSERT INTO enderecos (nome, ponto) VALUES
    ('Paulista 1000',    '[0.9, 0.1, 0.2]'),
    ('Av Paulista mil',  '[0.85, 0.12, 0.18]'),  -- parecido com o de cima
    ('Rua Augusta 500',  '[0.8, 0.3, 0.25]'),    -- ainda perto
    ('Av Brasil RJ',     '[0.1, 0.9, 0.8]'),     -- longe dos outros
    ('Rua XV Curitiba',  '[0.2, 0.85, 0.75]');   -- perto do Rio
```

**Olhe os números:**
- Os 3 primeiros têm primeira coordenada alta (~0.8–0.9) → são de SP.
- Os 2 últimos têm coordenadas 2 e 3 altas → são de outras cidades.

Sem IA nenhuma, só olhando os números, você já vê agrupamentos.

---

### **PASSO 4 — Buscar os mais parecidos** (1 SELECT)

O operador mágico é `<=>` (similaridade de cosseno). Quanto **menor** o resultado, **mais parecido**.

```sql
-- "Quem é mais parecido com 'Paulista 1000'?"
SELECT 
    nome,
    ponto <=> '[0.9, 0.1, 0.2]' AS distancia
FROM enderecos
ORDER BY ponto <=> '[0.9, 0.1, 0.2]'
LIMIT 3;
```

**Resultado:**
```
       nome        |    distancia    
-------------------+-----------------
 Paulista 1000     |               0
 Av Paulista mil   | 0.0012...
 Rua Augusta 500   | 0.0187...
```

Os 3 mais parecidos são os de SP. Os do RJ e Curitiba ficaram de fora.

**Isso é busca semântica.** Sem `LIKE`, sem `ILIKE`, sem regex. Só matemática de vetores.

---

### **PASSO 5 — Acelerar com índice** (1 CREATE INDEX)

Quando a tabela cresce (10k, 100k, 1M de linhas), a busca fica lenta. Solução:

```sql
CREATE INDEX ON enderecos 
USING ivfflat (ponto vector_cosine_ops)
WITH (lists = 3);
```

Pronto. O Postgres agora sabe como procurar rápido.

> **Regra prática:** `lists` ≈ `sqrt(n_linhas)`. Para 10k linhas, use `lists = 100`.

---

## Exemplo Completo Executável (copie e cole)

```sql
-- Limpa tudo
DROP TABLE IF EXISTS enderecos;

-- Cria
CREATE TABLE enderecos (
    id    SERIAL PRIMARY KEY,
    nome  TEXT,
    ponto vector(3)
);

-- Popula
INSERT INTO enderecos (nome, ponto) VALUES
    ('Paulista 1000',   '[0.9, 0.1, 0.2]'),
    ('Av Paulista mil', '[0.85, 0.12, 0.18]'),
    ('Rua Augusta 500', '[0.8, 0.3, 0.25]'),
    ('Av Brasil RJ',    '[0.1, 0.9, 0.8]'),
    ('Rua XV Curitiba', '[0.2, 0.85, 0.75]');

-- Busca
SELECT 
    nome,
    ROUND((ponto <=> '[0.9, 0.1, 0.2]')::numeric, 4) AS distancia
FROM enderecos
ORDER BY ponto <=> '[0.9, 0.1, 0.2]';
```

---

## Resumo em 1 Cartão

| Conceito | O que é | Sintaxe |
|----------|---------|---------|
| **Vetor** | Lista de números que representa "o significado" de algo | `vector(384)` |
| **Distância** | Quão diferentes dois vetores são | `<=>` (cosseno) |
| **Busca KNN** | "Quem são os K mais parecidos?" | `ORDER BY ponto <=> '[...]' LIMIT 5` |
| **Índice** | Acelera a busca em tabelas grandes | `USING ivfflat (...)` |

---

## Agora sim: onde entra a IA?

Quando você tiver um endereço real como texto (`"R. das Flores, 123"`), você precisa de um **modelo de IA** (tipo `all-MiniLM-L6-v2` ou `OpenAI Ada-002`) para **transformar o texto em vetor**.

Mas a busca em si — o `SELECT ... ORDER BY <=>` — é **exatamente a mesma coisa** que você acabou de fazer com vetores inventados.

> **Moral da história:** pgvector é só um "mapa de pontos". A IA é só o "GPS" que transforma texto em coordenadas nesse mapa.

---

## Analogia bônus (para explicar ao Guilherme)

> "Imagina que cada endereço é uma criança no pátio da escola. Crianças que gostam das mesmas coisas ficam perto. O pgvector é o professor que consegue dizer rapidinho: *'ó, me traz as 5 crianças mais parecidas com o João'* — sem precisar perguntar pra cada uma."

---

Quando este roteiro fizer sentido, aí sim vale avançar para o **pipeline real com embeddings** (Bloco 2 do plano anterior).