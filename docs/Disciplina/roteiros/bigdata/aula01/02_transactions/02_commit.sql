-- SWIFTTRACK CORE - Cena 2: faturamento bem-sucedido
SET search_path TO swifttrack_core;

-- ==========================================
-- CENA 2: FATURAMENTO BEM-SUCEDIDO
-- ==========================================

-- Estado ANTES:
SELECT d.id, d.status
FROM deliveries d
JOIN customers c ON c.id = d.customer_idA
WHERE c.document = '12.345.678/0001-99'
  AND d.origin_address = 'São Paulo - SP'
  AND d.destination_address = 'Rio de Janeiro - RJ';
SELECT COUNT(*) AS total_invoices_before
FROM invoices i
JOIN customers c ON c.id = i.customer_id
JOIN deliveries d ON d.id = i.delivery_id
WHERE c.document = '12.345.678/0001-99'
  AND (d.origin_address, d.destination_address) IN (
      ('São Paulo - SP', 'Rio de Janeiro - RJ'),
      ('Campinas - SP', 'Belo Horizonte - MG'),
      ('Santos - SP', 'Porto Alegre - RS')
  );

BEGIN;

UPDATE deliveries d
SET status = 'DELIVERED', delivered_at = NOW()
FROM customers c
WHERE c.id = d.customer_id
  AND c.document = '12.345.678/0001-99'
  AND d.origin_address = 'São Paulo - SP'
  AND d.destination_address = 'Rio de Janeiro - RJ';

INSERT INTO invoices (
    delivery_id, customer_id, invoice_number, series,
    total_value, tax_value, net_value, status, due_date
)
SELECT d.id, c.id, 'NF-2026-0001', '001',
       3500.00, 525.00, 2975.00, 'ISSUED', CURRENT_DATE + 30
FROM deliveries d
JOIN customers c ON c.id = d.customer_id
WHERE c.document = '12.345.678/0001-99'
  AND d.origin_address = 'São Paulo - SP'
  AND d.destination_address = 'Rio de Janeiro - RJ';

COMMIT;

-- Transação COMMITADA com sucesso!
-- Estado DEPOIS:
SELECT d.id, d.status, d.delivered_at
FROM deliveries d
JOIN customers c ON c.id = d.customer_id
WHERE c.document = '12.345.678/0001-99'
  AND d.origin_address = 'São Paulo - SP'
  AND d.destination_address = 'Rio de Janeiro - RJ';
SELECT COUNT(*) AS total_invoices_after
FROM invoices i
JOIN customers c ON c.id = i.customer_id
JOIN deliveries d ON d.id = i.delivery_id
WHERE c.document = '12.345.678/0001-99'
  AND (d.origin_address, d.destination_address) IN (
      ('São Paulo - SP', 'Rio de Janeiro - RJ'),
      ('Campinas - SP', 'Belo Horizonte - MG'),
      ('Santos - SP', 'Porto Alegre - RS')
  );
