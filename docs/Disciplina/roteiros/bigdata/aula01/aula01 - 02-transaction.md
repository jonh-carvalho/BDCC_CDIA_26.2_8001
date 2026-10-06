# 🔄 Script de Transações ACID — `02_transactions.sql`

Este script é o **coração do desafio da Semana 1**. Ele demonstra, passo a passo, como o PostgreSQL garante Atomicidade, Consistência, Isolamento e Durabilidade — e, principalmente, **o que acontece quando algo dá errado**.

---

## Estrutura do Script

O script é dividido em **5 cenas**:

| Cena | Objetivo | Conceito ACID |
| :--- | :--- | :--- |
| **1** | Preparar dados base (cliente, motorista, veículo, entrega) | — |
| **2** | Transação bem-sucedida (faturamento normal) | Atomicidade + Durabilidade |
| **3** | Transação com falha (valor negativo) → ROLLBACK | Atomicidade + Consistência |
| **4** | Transação com falha (entrega cancelada) → ROLLBACK | Consistência (regra de negócio) |
| **5** | Verificação final do estado do banco | Isolamento (nada "vazou") |

---

## Script Completo (`02_transactions.sql`)

```sql
-- =====================================================================
-- SWIFTTRACK CORE - Transações ACID com ROLLBACK
-- Disciplina: Arquiteturas de Dados e Big Data
-- Módulo I - Semana 1
-- =====================================================================
-- OBJETIVO: Demonstrar como o PostgreSQL garante integridade em cenários
-- de sucesso e falha, usando BEGIN, COMMIT e ROLLBACK.
-- =====================================================================

-- Configura o search_path para não precisar prefixar "swifttrack_core."
SET search_path TO swifttrack_core;

-- =====================================================================
-- CENA 1: SETUP — Criando dados base para os testes
-- =====================================================================
-- Vamos inserir um cliente, um motorista, um veículo e uma entrega.
-- Usamos \gset para capturar os IDs gerados e reutilizá-los depois.

\echo '=========================================='
\echo 'CENA 1: SETUP DE DADOS BASE'
\echo '=========================================='

-- 1.1 Cliente
INSERT INTO customers (document, name, email, address)
VALUES ('12.345.678/0001-99', 'Logística Veloz LTDA', 'contato@veloz.com.br', 'Av. Paulista, 1000 - SP')
RETURNING id AS customer_id \gset

\echo 'Cliente criado com ID: :'customer_id

-- 1.2 Motorista
INSERT INTO drivers (name, cpf, cnh_number, cnh_category, hired_at)
VALUES ('Carlos Silva', '123.456.789-00', '00123456789', 'E', '2023-03-15')
RETURNING id AS driver_id \gset

\echo 'Motorista criado com ID: :'driver_id

-- 1.3 Veículo
INSERT INTO vehicles (plate, model, manufacturer, year, capacity_kg)
VALUES ('ABC-1D23', 'FH 540', 'Volvo', 2024, 25000.00)
RETURNING id AS vehicle_id \gset

\echo 'Veículo criado com ID: :'vehicle_id

-- 1.4 Entrega (duas, para termos cenários diferentes)
INSERT INTO deliveries (customer_id, driver_id, vehicle_id, origin_address, destination_address, weight_kg, status, scheduled_at)
VALUES 
    (:'customer_id', :'driver_id', :'vehicle_id, 'São Paulo - SP', 'Rio de Janeiro - RJ', 5000.00, 'PENDING', NOW() + INTERVAL '1 day'),
    (:'customer_id', :'driver_id', :'vehicle_id', 'São Paulo - SP', 'Curitiba - PR', 8000.00, 'PENDING', NOW() + INTERVAL '2 days')
RETURNING id AS delivery_id_1 \gset

-- Captura o ID da segunda entrega separadamente
INSERT INTO deliveries (customer_id, driver_id, vehicle_id, origin_address, destination_address, weight_kg, status, scheduled_at)
VALUES (:'customer_id', :'driver_id', :'vehicle_id', 'Campinas - SP', 'Belo Horizonte - MG', 3000.00, 'PENDING', NOW() + INTERVAL '3 days')
RETURNING id AS delivery_id_2 \gset

-- Captura uma terceira entrega que vamos CANCELAR para o Cenário 4
INSERT INTO deliveries (customer_id, driver_id, vehicle_id, origin_address, destination_address, weight_kg, status, scheduled_at)
VALUES (:'customer_id', :'driver_id', :'vehicle_id', 'Santos - SP', 'Porto Alegre - RS', 10000.00, 'PENDING', NOW() + INTERVAL '4 days')
RETURNING id AS delivery_id_3 \gset

\echo 'Entregas criadas. IDs: :'delivery_id_1', :'delivery_id_2', :'delivery_id_3

-- Cancela a entrega 3 para o Cenário 4
UPDATE deliveries SET status = 'CANCELED' WHERE id = :'delivery_id_3';
\echo 'Entrega :'delivery_id_3' foi CANCELADA (será usada no Cenário 4)'

\echo ''

-- =====================================================================
-- CENA 2: TRANSAÇÃO BEM-SUCEDIDA (COMMIT)
-- =====================================================================
-- Cenário: A entrega 1 foi concluída. Vamos faturá-la normalmente.
-- Esperado: Fatura criada + status da entrega muda para 'DELIVERED' + 'BILLED'

\echo '=========================================='
\echo 'CENA 2: FATURAMENTO BEM-SUCEDIDO'
\echo '=========================================='

-- Estado ANTES da transação
\echo 'Estado ANTES:'
SELECT id, status FROM deliveries WHERE id = :'delivery_id_1';
SELECT COUNT(*) AS total_invoices_before FROM invoices;

-- Inicia a transação
BEGIN;

-- Passo 1: Atualiza status da entrega para DELIVERED
UPDATE deliveries 
SET status = 'DELIVERED', delivered_at = NOW()
WHERE id = :'delivery_id_1';

-- Passo 2: Cria a fatura
INSERT INTO invoices (
    delivery_id, customer_id, invoice_number, series,
    total_value, tax_value, net_value, status, due_date
) VALUES (
    :'delivery_id_1', :'customer_id', 'NF-2026-0001', '001',
    3500.00, 525.00, 2975.00, 'ISSUED', CURRENT_DATE + INTERVAL '30 days'
);

-- Passo 3: Marca a entrega como faturada (regra de negócio adicional)
UPDATE deliveries SET status = 'BILLED' WHERE id = :'delivery_id_1';

-- Confirma tudo
COMMIT;

\echo 'Transação COMMITADA com sucesso!'

-- Estado DEPOIS da transação
\echo 'Estado DEPOIS:'
SELECT id, status, delivered_at FROM deliveries WHERE id = :'delivery_id_1';
SELECT COUNT(*) AS total_invoices_after FROM invoices;

\echo ''

-- =====================================================================
-- CENA 3: TRANSAÇÃO COM FALHA — VALOR NEGATIVO (ROLLBACK)
-- =====================================================================
-- Cenário: Tentamos faturar a entrega 2 com valor NEGATIVO.
-- A constraint chk_invoices_total_value VAI REJEITAR.
-- Esperado: NADA é persistido. O ROLLBACK desfaz tudo.

\echo '=========================================='
\echo 'CENA 3: FALHA — VALOR NEGATIVO (ROLLBACK)'
\echo '=========================================='

-- Estado ANTES
\echo 'Estado ANTES (entrega 2 ainda PENDING):'
SELECT id, status FROM deliveries WHERE id = :'delivery_id_2';
SELECT COUNT(*) AS total_invoices FROM invoices;

BEGIN;

-- Passo 1: Tenta atualizar a entrega
UPDATE deliveries 
SET status = 'DELIVERED', delivered_at = NOW()
WHERE id = :'delivery_id_2';

\echo 'Entrega atualizada (ainda dentro da transação)...'

-- Passo 2: Tenta criar fatura com VALOR NEGATIVO → VAI FALHAR!
INSERT INTO invoices (
    delivery_id, customer_id, invoice_number, series,
    total_value, tax_value, net_value, status, due_date
) VALUES (
    :'delivery_id_2', :'customer_id', 'NF-2026-0002', '001',
    -500.00, 0, -500.00, 'ISSUED', CURRENT_DATE + INTERVAL '30 days'
);

-- A LINHA ACIMA VAI GERAR ERRO:
-- ERROR: new row for relation "invoices" violates check constraint "chk_invoices_total_value"
-- DETAIL: Failing row contains (... -500.00 ...)

-- Se chegasse aqui (não chega), faríamos COMMIT.
-- Como deu erro, precisamos dar ROLLBACK para liberar a transação.
ROLLBACK;

\echo 'ROLLBACK executado — nenhuma alteração foi persistida!'

-- Estado DEPOIS — deve ser IGUAL ao estado ANTES
\echo 'Estado DEPOIS (deve estar igual ao ANTES):'
SELECT id, status FROM deliveries WHERE id = :'delivery_id_2';
SELECT COUNT(*) AS total_invoices FROM invoices;

\echo ''

-- =====================================================================
-- CENA 4: TRANSAÇÃO COM FALHA — ENTREGA CANCELADA (ROLLBACK)
-- =====================================================================
-- Cenário: Tentamos faturar a entrega 3, que foi CANCELADA.
-- Isso viola uma regra de negócio implícita (não faturamos entregas canceladas).
-- Vamos simular isso com uma constraint CHECK adicional via aplicação,
-- mas aqui vamos forçar um erro de FK/estado.

\echo '=========================================='
\echo 'CENA 4: FALHA — ENTREGA CANCELADA (ROLLBACK)'
\echo '=========================================='

-- Estado ANTES
\echo 'Estado ANTES (entrega 3 está CANCELED):'
SELECT id, status FROM deliveries WHERE id = :'delivery_id_3';

BEGIN;

-- Passo 1: Tenta "reativar" a entrega e faturá-la
UPDATE deliveries 
SET status = 'DELIVERED', delivered_at = NOW()
WHERE id = :'delivery_id_3';

-- Passo 2: Tenta criar fatura
INSERT INTO invoices (
    delivery_id, customer_id, invoice_number, series,
    total_value, tax_value, net_value, status, due_date
) VALUES (
    :'delivery_id_3', :'customer_id', 'NF-2026-0003', '001',
    5000.00, 750.00, 4250.00, 'ISSUED', CURRENT_DATE + INTERVAL '30 days'
);

-- Aqui entra a regra de negócio: em um sistema real, a aplicação
-- verificaria que a entrega estava cancelada e lançaria uma exceção.
-- Para fins didáticos, vamos SIMULAR essa detecção com um DO block:

DO $$
DECLARE
    v_status VARCHAR;
BEGIN
    SELECT status INTO v_status FROM deliveries WHERE id = :'delivery_id_3';
    -- Em um cenário real, a entrega original estava CANCELED.
    -- Vamos forçar um erro se detectarmos inconsistência:
    IF v_status = 'DELIVERED' THEN
        -- Simula detecção de fraude: entrega estava cancelada mas foi "reativada"
        RAISE EXCEPTION 'REGRA DE NEGÓCIO VIOLADA: Não é permitido faturar entrega previamente cancelada (ID: %)', :'delivery_id_3';
    END IF;
END $$;

-- Se chegasse aqui, faríamos COMMIT.
-- Como o DO block lançou exceção, a transação entra em estado de erro.
ROLLBACK;

\echo 'ROLLBACK executado — entrega continua CANCELED, nenhuma fatura criada!'

-- Estado DEPOIS
\echo 'Estado DEPOIS:'
SELECT id, status FROM deliveries WHERE id = :'delivery_id_3';
SELECT COUNT(*) AS total_invoices FROM invoices;

\echo ''

-- =====================================================================
-- CENA 5: VERIFICAÇÃO FINAL — O ESTADO CONSOLIDADO
-- =====================================================================

\echo '=========================================='
\echo 'CENA 5: VERIFICAÇÃO FINAL'
\echo '=========================================='

\echo 'Entregas e seus status finais:'
SELECT id, customer_id, status, delivered_at 
FROM deliveries 
ORDER BY id;

\echo ''
\echo 'Faturas emitidas (apenas a Cena 2 deve ter persistido):'
SELECT id, delivery_id, invoice_number, total_value, net_value, status 
FROM invoices 
ORDER BY id;

\echo ''
\echo 'Resumo:'
SELECT 
    (SELECT COUNT(*) FROM deliveries) AS total_deliveries,
    (SELECT COUNT(*) FROM deliveries WHERE status = 'BILLED') AS billed_deliveries,
    (SELECT COUNT(*) FROM deliveries WHERE status = 'CANCELED') AS canceled_deliveries,
    (SELECT COUNT(*) FROM deliveries WHERE status = 'PENDING') AS pending_deliveries,
    (SELECT COUNT(*) FROM invoices) AS total_invoices,
    (SELECT SUM(total_value) FROM invoices) AS total_billed_value;

\echo ''
\echo 'FIM DO SCRIPT DE TRANSAÇÕES'
\echo 'Lição: Quando uma constraint falha, o PostgreSQL aborta a transação.'
\echo '   É OBRIGATÓRIO dar ROLLBACK antes de iniciar uma nova transação.'
```

---

## Como Executar

Usando o mesmo padrão da aula anterior (pipe direto):

```bash
cat 02_transactions.sql | docker exec -i swifttrack-pg psql -U postgres -d swifttrack_core
```

---

## O Que os Alunos Devem Observar

### 1. **A Atomicidade em Ação**
Na **Cena 3**, o `UPDATE` da entrega **foi executado** antes do `INSERT` da fatura. Mas quando o `INSERT` falhou, **AMBOS foram desfeitos**. A entrega voltou ao status `PENDING`. Isso é Atomicidade: "tudo ou nada".

### 2. **O Estado de Erro da Transação**
Quando uma constraint falha dentro de um `BEGIN`, o PostgreSQL entra em um estado chamado **"aborted transaction"**. Nesse estado:
- ❌ Você **NÃO** pode executar mais nenhum comando (nem `SELECT`)
- ❌ Você **NÃO** pode dar `COMMIT`
- ✅ A **ÚNICA** coisa que você pode fazer é `ROLLBACK`

Se o aluno esquecer de dar `ROLLBACK` e tentar rodar outra query, verá:
```
ERROR: current transaction is aborted, commands ignored until end of transaction block
```

### 3. **A Diferença Entre COMMIT e ROLLBACK**
| Comando | Efeito | Quando usar |
| :--- | :--- | :--- |
| `COMMIT` | Torna as alterações **permanentes** | Quando tudo deu certo |
| `ROLLBACK` | **Desfaz** todas as alterações do `BEGIN` | Quando algo deu errado |

### 4. **O Poder das Constraints**
As constraints `CHECK` que criamos no `01_schema.sql` são a **última linha de defesa**. Mesmo que a aplicação tenha um bug e envie um valor negativo, o banco **rejeita**. Isso é a **Consistência** do ACID.

---

## Teste de Variações

### Variação 1: Mostrar o "Estado de Erro"
Peça para os alunos **comentarem** a linha do `ROLLBACK` na Cena 3 e tentarem rodar um `SELECT` depois do erro. Eles verão a mensagem de "transaction is aborted". Isso fixa o conceito.

### Variação 2: Transação Aninhada (SAVEPOINT)
Como usar `SAVEPOINT` para fazer rollback parcial:

```sql
BEGIN;
INSERT INTO invoices (...) VALUES (...);
SAVEPOINT sp_invoice;
INSERT INTO invoices (...) VALUES (...);  -- falha
ROLLBACK TO SAVEPOINT sp_invoice;         -- desfaz só o segundo INSERT
COMMIT;                                   -- mantém o primeiro
```

### Variação 3: Simulação de Concorrência

Abra **dois terminais** conectados ao mesmo banco. No Terminal 1, dê `BEGIN; UPDATE deliveries...` (sem COMMIT). No Terminal 2, tente dar `SELECT` ou `UPDATE` na mesma linha. Mostre o comportamento de **Isolamento**.