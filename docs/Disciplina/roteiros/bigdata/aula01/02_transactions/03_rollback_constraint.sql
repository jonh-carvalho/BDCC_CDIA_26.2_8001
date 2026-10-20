-- SWIFTTRACK CORE - Cena 3: falha por valor negativo e ROLLBACK
SET search_path TO swifttrack_core;

\echo '=========================================='
\echo 'CENA 3: FALHA — VALOR NEGATIVO (ROLLBACK)'
\echo '=========================================='

\echo 'Estado ANTES (entrega ainda PENDING):'
SELECT d.id, d.status
FROM deliveries d
JOIN customers c ON c.id = d.customer_id
WHERE c.document = '12.345.678/0001-99'
  AND d.origin_address = 'Campinas - SP'
  AND d.destination_address = 'Belo Horizonte - MG';

BEGIN;

UPDATE deliveries d
SET status = 'DELIVERED', delivered_at = NOW()
FROM customers c
WHERE c.id = d.customer_id
  AND c.document = '12.345.678/0001-99'
  AND d.origin_address = 'Campinas - SP'
  AND d.destination_address = 'Belo Horizonte - MG';

\echo 'Entrega atualizada dentro da transação; a fatura negativa deve falhar.'

INSERT INTO invoices (
    delivery_id, customer_id, invoice_number, series,
    total_value, tax_value, net_value, status, due_date
)
SELECT d.id, c.id, 'NF-2026-0002', '001',
       -500.00, 0, -500.00, 'ISSUED', CURRENT_DATE + 30
FROM deliveries d
JOIN customers c ON c.id = d.customer_id
WHERE c.document = '12.345.678/0001-99'
  AND d.origin_address = 'Campinas - SP'
  AND d.destination_address = 'Belo Horizonte - MG';

-- A constraint chk_invoices_total_value rejeita o INSERT.
ROLLBACK;

\echo 'ROLLBACK executado — nenhuma alteração foi persistida!'
\echo 'Estado DEPOIS (deve continuar PENDING):'
SELECT d.id, d.status
FROM deliveries d
JOIN customers c ON c.id = d.customer_id
WHERE c.document = '12.345.678/0001-99'
  AND d.origin_address = 'Campinas - SP'
  AND d.destination_address = 'Belo Horizonte - MG';
SELECT COUNT(*) AS invoices_for_demo
FROM invoices i
JOIN customers c ON c.id = i.customer_id
JOIN deliveries d ON d.id = i.delivery_id
WHERE c.document = '12.345.678/0001-99'
  AND (d.origin_address, d.destination_address) IN (
      ('São Paulo - SP', 'Rio de Janeiro - RJ'),
      ('Campinas - SP', 'Belo Horizonte - MG'),
      ('Santos - SP', 'Porto Alegre - RS')
  );
