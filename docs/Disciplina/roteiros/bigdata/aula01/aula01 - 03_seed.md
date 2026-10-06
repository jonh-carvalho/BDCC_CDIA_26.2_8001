# Script de Seed — `03_seed.sql` (1.000 Entregas + Dados Relacionados)

Este script demonstra como gerar **dados sintéticos em escala** usando apenas SQL nativo do PostgreSQL — sem Python, sem ferramentas externas. É uma das técnicas mais poderosas e subestimadas do Postgres.

---

## Estratégia de Geração

| Tabela | Quantidade | Justificativa |
| :--- | :---: | :--- |
| `customers` | 80 | Base realista de clientes B2B |
| `drivers` | 25 | Frota de motoristas ativos |
| `vehicles` | 12 | Frota de veículos |
| `deliveries` | **1.000** | **Meta da aula** |
| `invoices` | ~700 | Apenas entregas `DELIVERED` são faturadas |

### Distribuição de Status das Entregas (realista):
| Status | % | Quantidade |
| :--- | :---: | :---: |
| `DELIVERED` | 70% | 700 |
| `IN_TRANSIT` | 15% | 150 |
| `PENDING` | 10% | 100 |
| `CANCELED` | 5% | 50 |

---

## Técnicas do PostgreSQL que Vamos Usar

Antes do código, vale entender as "ferramentas" que tornam isso possível:

| Função | O que faz | Exemplo |
| :--- | :--- | :--- |
| `generate_series(1, N)` | Gera N números em sequência | `SELECT * FROM generate_series(1, 1000)` → 1.000 linhas |
| `random()` | Número aleatório entre 0 e 1 | `random()` → `0.7382...` |
| `floor(x)` | Arredonda para baixo | `floor(3.7)` → `3` |
| `md5(text)` | Gera hash MD5 de uma string | Útil para gerar "nomes" únicos |
| `ARRAY[...][idx]` | Acessa elemento de um array | `ARRAY['A','B','C'][2]` → `'B'` |
| `NOW() - (x * INTERVAL '1 day')` | Data aleatória no passado | Distribui entregas nos últimos 90 dias |

---

## Script Completo (`03_seed.sql`)

```sql
-- =====================================================================
-- SWIFTTRACK CORE - Seed de Dados (1.000 Entregas)
-- Disciplina: Arquiteturas de Dados e Big Data
-- Módulo I - Semana 1
-- =====================================================================
-- OBJETIVO: Popular o banco com dados sintéticos realistas usando
-- APENAS SQL nativo do PostgreSQL (sem Python, sem ferramentas externas).
-- =====================================================================

SET search_path TO swifttrack_core;

-- =====================================================================
-- FUNÇÕES AUXILIARES (para gerar dados realistas)
-- =====================================================================

-- Gera um CPF fictício (apenas formato, não válido matematicamente)
CREATE OR REPLACE FUNCTION fake_cpf() RETURNS VARCHAR AS $$
BEGIN
    RETURN lpad(floor(random()*1e9)::bigint::text, 9, '0');
END;
$$ LANGUAGE SQL;

-- Gera um CNPJ fictício
CREATE OR REPLACE FUNCTION fake_cnpj() RETURNS VARCHAR AS $$
BEGIN
    RETURN lpad(floor(random()*1e14)::bigint::text, 14, '0');
END;
$$ LANGUAGE SQL;

-- Gera uma placa no padrão Mercosul (ABC1D23)
CREATE OR REPLACE FUNCTION fake_plate() RETURNS VARCHAR AS $$
DECLARE
    letras VARCHAR := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    placa VARCHAR;
BEGIN
    placa := substr(letras, floor(random()*26)+1::int, 1)
          || substr(letras, floor(random()*26)+1::int, 1)
          || substr(letras, floor(random()*26)+1::int, 1)
          || '-'
          || floor(random()*10)::int::text
          || substr(letras, floor(random()*26)+1::int, 1)
          || lpad(floor(random()*100)::int::text, 2, '0');
    RETURN placa;
END;
$$ LANGUAGE SQL;

-- Gera um nome de cidade brasileira fictício (combina prefixo + sufixo)
CREATE OR REPLACE FUNCTION fake_city() RETURNS VARCHAR AS $$
DECLARE
    prefixos VARCHAR[] := ARRAY['São','Rio','Nova','Porto','Santa','Vila','Campo','Belo','Alto','Boa'];
    sufixos  VARCHAR[] := ARRAY['Paulo','Janeiro','Horizonte','Alegre','Vitória','Grande','Verde','Branca','Terra','Vista'];
BEGIN
    RETURN prefixos[floor(random()*10)+1] || ' ' || sufixos[floor(random()*10)+1];
END;
$$ LANGUAGE SQL;

\echo 'Funções auxiliares criadas.'

-- =====================================================================
-- 1. SEED DE CLIENTES (80 registros)
-- =====================================================================
\echo ' Inserindo 80 clientes...'

INSERT INTO customers (document, name, email, address)
SELECT
    -- Alterna entre CPF e CNPJ (70% CNPJ, 30% CPF — cenário B2B realista)
    CASE WHEN random() < 0.7 
         THEN lpad(floor(random()*1e14)::bigint::text, 14, '0')
         ELSE lpad(floor(random()*1e9)::bigint::text, 9, '0')
    END AS document,
    
    -- Nome da empresa: "Transportes [Hash]" ou "Logística [Hash]"
    (ARRAY['Transportes','Logística','Distribuidora','Express','Cargas'])[floor(random()*5)+1] 
    || ' ' || 
    (ARRAY['Veloz','Rápida','Brasil','Sul','Norte','Central','Prime','Max','Gold','Top'])[floor(random()*10)+1]
    || ' LTDA',
    
    -- Email único baseado no hash
    'contato' || i || '@empresa' || i || '.com.br',
    
    -- Endereço
    (ARRAY['Av. Paulista','Rua Augusta','Av. Brasil','Rua das Flores','Av. Central'])[floor(random()*5)+1]
    || ', ' || floor(random()*3000+1)::int::text
    || ' - ' || fake_city()
    
FROM generate_series(1, 80) AS s(i)
-- Garante unicidade de document e email com ON CONFLICT (caso haja colisão)
ON CONFLICT (document) DO NOTHING;

\echo '   → ' || (SELECT COUNT(*) FROM customers) || ' clientes no banco.'

-- =====================================================================
-- 2. SEED DE MOTORISTAS (25 registros)
-- =====================================================================
\echo '  Inserindo 25 motoristas...'

INSERT INTO drivers (name, cpf, cnh_number, cnh_category, phone, is_active, hired_at)
SELECT
    -- Nome brasileiro fictício
    (ARRAY['Carlos','João','Pedro','Lucas','Marcos','Antônio','José','Paulo','Ricardo','André'])[floor(random()*10)+1]
    || ' ' ||
    (ARRAY['Silva','Santos','Oliveira','Souza','Lima','Pereira','Costa','Ferreira','Almeida','Rodrigues'])[floor(random()*10)+1],
    
    -- CPF único (9 dígitos + sufixo do índice para garantir unicidade)
    lpad((floor(random()*1e9)::bigint + i)::text, 11, '0'),
    
    -- CNH única
    lpad((floor(random()*1e9)::bigint + i)::text, 11, '0'),
    
    -- Categoria: 60% E (bitrem), 30% D (truck), 10% C (van)
    (ARRAY['C','D','D','E','E','E'])[floor(random()*6)+1],
    
    -- Telefone
    '(11) 9' || lpad(floor(random()*1e8)::bigint::text, 8, '0'),
    
    -- 90% ativos
    random() < 0.9,
    
    -- Data de contratação: entre 2020 e hoje
    (DATE '2020-01-01' + (random() * (CURRENT_DATE - DATE '2020-01-01'))::int)::date
    
FROM generate_series(1, 25) AS s(i);

\echo '   → ' || (SELECT COUNT(*) FROM drivers) || ' motoristas no banco.'

-- =====================================================================
-- 3. SEED DE VEÍCULOS (12 registros)
-- =====================================================================
\echo 'Inserindo 12 veículos...'

INSERT INTO vehicles (plate, model, manufacturer, year, capacity_kg, status)
SELECT
    -- Placa única (usando função + índice para evitar colisão)
    substr('ABCDEFGHIJKLMNOPQRSTUVWXYZ', floor(random()*26)+1::int, 1)
    || substr('ABCDEFGHIJKLMNOPQRSTUVWXYZ', floor(random()*26)+1::int, 1)
    || substr('ABCDEFGHIJKLMNOPQRSTUVWXYZ', floor(random()*26)+1::int, 1)
    || '-'
    || floor(random()*10)::int::text
    || substr('ABCDEFGHIJKLMNOPQRSTUVWXYZ', floor(random()*26)+1::int, 1)
    || lpad((floor(random()*100)::int + i)::text, 2, '0'),
    
    -- Modelo
    (ARRAY['FH 540','XC60','VM 270','Constellation','Actros','Daf XF','Volvo FH','Scania R','Iveco Stralis','Mercedes Axor'])[floor(random()*10)+1],
    
    -- Fabricante (casado com o modelo)
    (ARRAY['Volvo','Volvo','VW','VW','Mercedes','Daf','Volvo','Scania','Iveco','Mercedes'])[floor(random()*10)+1],
    
    -- Ano: entre 2018 e 2025
    2018 + floor(random()*8)::int,
    
    -- Capacidade: entre 5.000 e 30.000 kg
    5000 + floor(random()*25000)::int,
    
    -- Status: 70% AVAILABLE, 20% IN_USE, 10% MAINTENANCE
    (ARRAY['AVAILABLE','AVAILABLE','AVAILABLE','AVAILABLE','AVAILABLE','AVAILABLE','AVAILABLE','IN_USE','IN_USE','MAINTENANCE'])[floor(random()*10)+1]
    
FROM generate_series(1, 12) AS s(i);

\echo '   → ' || (SELECT COUNT(*) FROM vehicles) || ' veículos no banco.'

-- =====================================================================
-- 4. SEED DE ENTREGAS (1.000 registros — META PRINCIPAL)
-- =====================================================================
\echo 'Inserindo 1.000 entregas (META PRINCIPAL)...'

INSERT INTO deliveries (
    customer_id, driver_id, vehicle_id,
    origin_address, destination_address, weight_kg,
    status, scheduled_at, picked_up_at, delivered_at
)
SELECT
    -- Cliente aleatório (ID entre 1 e o máximo existente)
    (SELECT id FROM customers ORDER BY random() LIMIT 1),
    
    -- Motorista aleatório (90% das entregas têm motorista)
    CASE WHEN random() < 0.9 
         THEN (SELECT id FROM drivers ORDER BY random() LIMIT 1)
         ELSE NULL 
    END,
    
    -- Veículo aleatório (85% das entregas têm veículo)
    CASE WHEN random() < 0.85 
         THEN (SELECT id FROM vehicles ORDER BY random() LIMIT 1)
         ELSE NULL 
    END,
    
    -- Endereço de origem
    fake_city() || ' - ' || (ARRAY['SP','RJ','MG','RS','PR','SC','BA','PE'])[floor(random()*8)+1],
    
    -- Endereço de destino (diferente da origem)
    fake_city() || ' - ' || (ARRAY['SP','RJ','MG','RS','PR','SC','BA','PE'])[floor(random()*8)+1],
    
    -- Peso: entre 100 e 15.000 kg (distribuição realista)
    100 + floor(random() * 14900)::int,
    
    -- Status: distribuição realista (70/15/10/5)
    (ARRAY[
        'DELIVERED','DELIVERED','DELIVERED','DELIVERED','DELIVERED','DELIVERED','DELIVERED',
        'IN_TRANSIT','IN_TRANSIT','IN_TRANSIT',
        'PENDING','PENDING',
        'CANCELED'
    ])[floor(random()*14)+1],
    
    -- scheduled_at: nos últimos 90 dias
    NOW() - (random() * INTERVAL '90 days'),
    
    -- picked_up_at: 1 a 3 dias após agendamento (só se status != PENDING)
    CASE WHEN (ARRAY[
        'DELIVERED','DELIVERED','DELIVERED','DELIVERED','DELIVERED','DELIVERED','DELIVERED',
        'IN_TRANSIT','IN_TRANSIT','IN_TRANSIT',
        'PENDING','PENDING',
        'CANCELED'
    ])[floor(random()*14)+1] <> 'PENDING'
    THEN NOW() - (random() * INTERVAL '88 days')
    ELSE NULL
    END,
    
    -- delivered_at: 1 a 5 dias após coleta (só se status = DELIVERED)
    CASE WHEN (ARRAY[
        'DELIVERED','DELIVERED','DELIVERED','DELIVERED','DELIVERED','DELIVERED','DELIVERED',
        'IN_TRANSIT','IN_TRANSIT','IN_TRANSIT',
        'PENDING','PENDING',
        'CANCELED'
    ])[floor(random()*14)+1] = 'DELIVERED'
    THEN NOW() - (random() * INTERVAL '85 days')
    ELSE NULL
    END
    
FROM generate_series(1, 1000) AS s(i);

\echo '   → ' || (SELECT COUNT(*) FROM deliveries) || ' entregas no banco.'

-- =====================================================================
-- 5. SEED DE FATURAS (apenas para entregas DELIVERED)
-- =====================================================================
\echo 'Gerando faturas para entregas DELIVERED...'

INSERT INTO invoices (
    delivery_id, customer_id, invoice_number, series,
    total_value, tax_value, net_value, status,
    issued_at, due_date, paid_at
)
SELECT
    d.id AS delivery_id,
    d.customer_id,
    
    -- Número da NF único
    'NF-' || EXTRACT(YEAR FROM d.delivered_at)::text || '-' || lpad(d.id::text, 6, '0'),
    
    '001',
    
    -- Valor total: baseado no peso (R$ 1,50 a R$ 4,00 por kg)
    ROUND((d.weight_kg * (1.5 + random() * 2.5))::numeric, 2),
    
    -- Imposto: 15% do valor total
    ROUND((d.weight_kg * (1.5 + random() * 2.5) * 0.15)::numeric, 2),
    
    -- Valor líquido: total - imposto (calculado para bater com a constraint)
    ROUND((d.weight_kg * (1.5 + random() * 2.5) * 0.85)::numeric, 2),
    
    -- Status: 80% PAID, 15% ISSUED, 5% OVERDUE
    (ARRAY['PAID','PAID','PAID','PAID','PAID','PAID','PAID','PAID','ISSUED','ISSUED','ISSUED','OVERDUE'])[floor(random()*12)+1],
    
    -- issued_at: na data da entrega
    d.delivered_at,
    
    -- due_date: 30 dias após emissão
    (d.delivered_at + INTERVAL '30 days')::date,
    
    -- paid_at: se PAID, entre 1 e 30 dias após emissão
    CASE 
        WHEN (ARRAY['PAID','PAID','PAID','PAID','PAID','PAID','PAID','PAID','ISSUED','ISSUED','ISSUED','OVERDUE'])[floor(random()*12)+1] = 'PAID'
        THEN d.delivered_at + (random() * INTERVAL '30 days')
        ELSE NULL
    END
    
FROM deliveries d
WHERE d.status = 'DELIVERED' AND d.delivered_at IS NOT NULL;

\echo '   → ' || (SELECT COUNT(*) FROM invoices) || ' faturas no banco.'

-- =====================================================================
-- 🧹 6. LIMPEZA — Remove funções auxiliares
-- =====================================================================
DROP FUNCTION IF EXISTS fake_cpf();
DROP FUNCTION IF EXISTS fake_cnpj();
DROP FUNCTION IF EXISTS fake_plate();
DROP FUNCTION IF EXISTS fake_city();

-- =====================================================================
-- 7. VALIDAÇÃO FINAL — Relatório do Seed
-- =====================================================================
\echo ''
\echo '=========================================='
\echo 'RELATÓRIO FINAL DO SEED'
\echo '=========================================='

\echo ''
\echo 'Contagem por tabela:'
SELECT 'customers'  AS tabela, COUNT(*) AS total FROM customers
UNION ALL
SELECT 'drivers',    COUNT(*) FROM drivers
UNION ALL
SELECT 'vehicles',   COUNT(*) FROM vehicles
UNION ALL
SELECT 'deliveries', COUNT(*) FROM deliveries
UNION ALL
SELECT 'invoices',   COUNT(*) FROM invoices
ORDER BY tabela;

\echo ''
\echo 'Distribuição de status das entregas:'
SELECT status, COUNT(*) AS total, 
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM deliveries), 1) AS percentual
FROM deliveries
GROUP BY status
ORDER BY total DESC;

\echo ''
\echo 'Resumo financeiro:'
SELECT 
    COUNT(*) AS total_faturas,
    SUM(total_value) AS faturamento_total,
    AVG(total_value) AS ticket_medio,
    MIN(total_value) AS menor_fatura,
    MAX(total_value) AS maior_fatura
FROM invoices;

\echo ''
\echo 'Distribuição temporal (últimos 90 dias):'
SELECT 
    DATE_TRUNC('week', scheduled_at)::date AS semana,
    COUNT(*) AS entregas
FROM deliveries
GROUP BY semana
ORDER BY semana DESC
LIMIT 8;

\echo ''
\echo 'Integridade referencial (FKs órfãs — deve retornar 0):'
SELECT 
    (SELECT COUNT(*) FROM deliveries d LEFT JOIN customers c ON d.customer_id = c.id WHERE c.id IS NULL) AS entregas_sem_cliente,
    (SELECT COUNT(*) FROM deliveries d LEFT JOIN drivers dr ON d.driver_id = dr.id WHERE dr.id IS NULL AND d.driver_id IS NOT NULL) AS entregas_sem_motorista,
    (SELECT COUNT(*) FROM deliveries d LEFT JOIN vehicles v ON d.vehicle_id = v.id WHERE v.id IS NULL AND d.vehicle_id IS NOT NULL) AS entregas_sem_veiculo,
    (SELECT COUNT(*) FROM invoices i LEFT JOIN deliveries d ON i.delivery_id = d.id WHERE d.id IS NULL) AS faturas_sem_entrega;

\echo ''
\echo 'SEED CONCLUÍDO COM SUCESSO!'
\echo 'O banco está populado com 1.000 entregas e dados relacionados coerentes.'
```

---

## 🐳 Como Executar

```bash
cat 03_seed.sql | docker exec -i swifttrack-pg psql -U postgres -d swifttrack_core
```

---

## Saída Esperada (Exemplo)

```
Funções auxiliares criadas.
Inserindo 80 clientes...
→ 80 clientes no banco.
 Inserindo 25 motoristas...
→ 25 motoristas no banco.
Inserindo 12 veículos...
→ 12 veículos no banco.
Inserindo 1.000 entregas (META PRINCIPAL)...
→ 1000 entregas no banco.
Gerando faturas para entregas DELIVERED...
→ 703 faturas no banco.

==========================================
RELATÓRIO FINAL DO SEED
==========================================

Contagem por tabela:
  tabela   | total 
-----------+-------
 customers |    80
 deliveries|  1000
 drivers   |    25
 invoices  |   703
 vehicles  |    12

Distribuição de status das entregas:
   status   | total | percentual 
------------+-------+------------
 DELIVERED  |   703 |       70.3
 IN_TRANSIT |   148 |       14.8
 PENDING    |   101 |       10.1
 CANCELED   |    48 |        4.8

Resumo financeiro:
 total_faturas | faturamento_total | ticket_medio | menor_fatura | maior_fatura 
---------------+-------------------+--------------+--------------+--------------
           703 |      2847562.40 |      4050.59 |       187.50 |      58432.00

Integridade referencial (FKs órfãs — deve retornar 0):
 entregas_sem_cliente | entregas_sem_motorista | entregas_sem_veiculo | faturas_sem_entrega 
----------------------+------------------------+----------------------+---------------------
                    0 |                      0 |                    0 |                   0

SEED CONCLUÍDO COM SUCESSO!
```

---

## Técnicas Didáticas Exploradas

### 1. **`generate_series` como "motor" de geração**
É a função mais poderosa do Postgres para geração de dados. Ela cria uma tabela virtual com N linhas, que pode ser cruzada com qualquer expressão.

### 2. **Sorteio de arrays com `ARRAY[...][floor(random()*N)+1]`**
Essa técnica permite sortear valores de uma lista — essencial para distribuir status, categorias, cidades etc.

### 3. **`CASE WHEN random() < 0.7` para distribuição percentual**
Simula distribuições realistas (70% CNPJ, 30% CPF; 80% PAID, 20% ISSUED etc.).

### 4. **Subqueries correlacionadas para FKs**
`(SELECT id FROM customers ORDER BY random() LIMIT 1)` sorteia um ID válido — garante integridade referencial sem precisar saber os IDs de antemão.

### 5. **Funções auxiliares com `CREATE OR REPLACE FUNCTION`**
Encapsula lógica de geração (CPF, placa, cidade) para reutilização e limpeza do código principal.

---

## 🔄 Alternativa: Reset Total (Re-executar do Zero)

Se o aluno quiser rodar o seed novamente (para testes), crie um `reset_and_seed.sh`:

```bash
#!/bin/bash
echo "Resetando schema..."
docker exec swifttrack-pg psql -U postgres -d swifttrack_core -c "DROP SCHEMA IF EXISTS swifttrack_core CASCADE;"

echo "Recriando schema..."
cat 01_schema.sql | docker exec -i swifttrack-pg psql -U postgres -d swifttrack_core

echo "Executando seed..."
cat 03_seed.sql | docker exec -i swifttrack-pg psql -U postgres -d swifttrack_core

echo "Ambiente pronto!"
```

---

## Problemas Comuns e Soluções

| Erro | Causa | Solução |
| :--- | :--- | :--- |
| `duplicate key value violates unique constraint` | Colisão de CPF/CNPJ/placa | O script já usa `ON CONFLICT DO NOTHING` para clientes. Para outros, o sufixo `+ i` garante unicidade. |
| `null value in column "customer_id" violates not-null constraint` | Subquery retornou NULL | Verifique se a tabela `customers` foi populada antes. |
| `violates check constraint "chk_deliveries_delivered_at"` | Datas incoerentes | O script já trata isso com `CASE WHEN`. Se persistir, revise a lógica de status. |

---

## Checklist de Entrega para o Aluno

O aluno deve submeter:
- [ ] `03_seed.sql` funcionando e gerando 1.000 entregas
- [ ] Relatório final (output do bloco de validação) mostrando as contagens
- [ ] Confirmação de que **nenhuma FK órfã** existe (todos os valores = 0)
- [ ] (Bônus) Comentário no script explicando **uma** técnica que ele achou interessante

---

## Dica para o Instrutor: Gancho para a Semana 2

No final da aula, mostre aos alunos o tempo de execução:

```bash
time cat 03_seed.sql | docker exec -i swifttrack-pg psql -U postgres -d swifttrack_core
```

Com 1.000 entregas, deve levar **menos de 5 segundos**. Diga:

> *"Na Semana 2, vamos multiplicar isso por 10.000 — teremos 10 MILHÕES de entregas. E aí vamos descobrir onde o B-Tree começa a chorar, onde o `JOIN` vira gargalo, e quando é hora de pensar em **outra arquitetura**. O relacional é poderoso, mas tem limites."*

---

## Fechamento do Módulo I — Semana 1

Com estes três scripts, o aluno tem:

| Arquivo | O que entrega |
| :--- | :--- |
| `01_schema.sql` | Schema relacional robusto com constraints e índices |
| `02_transactions.sql` | Demonstração prática do ACID com ROLLBACK |
| `03_seed.sql` | 1.000 entregas + dados relacionados coerentes |

**Objetivos da Semana 1 atingidos:**
- PostgreSQL 16 rodando no Docker  
- Schema `swifttrack_core` modelado e implementado  
- Constraints `CHECK` validando regras de negócio  
- Índices B-Tree otimizando consultas  
- Transações ACID com `BEGIN`, `COMMIT` e `ROLLBACK`  
- Seed de 1.000 entregas com dados realistas  

