-- SWIFTTRACK CORE - Cena 5: verificação consolidada das cenas
SET search_path TO swifttrack_core;

-- CENA 5: VERIFICAÇÃO FINAL

-- Entregas da demonstração e seus status finais.
SELECT d.id, d.origin_address, d.destination_address, d.status, d.delivered_at
FROM deliveries d
JOIN customers c ON c.id = d.customer_id
WHERE c.document = '12.345.678/0001-99'
  AND d.origin_address IN ('São Paulo - SP', 'Campinas - SP', 'Santos - SP')
ORDER BY d.id;

-- Faturas da demonstração (apenas a Cena 2 deve ter persistido).
SELECT i.id, i.delivery_id, i.invoice_number, i.total_value, i.net_value, i.status
FROM invoices i
JOIN customers c ON c.id = i.customer_id
JOIN deliveries d ON d.id = i.delivery_id
WHERE c.document = '12.345.678/0001-99'
  AND d.origin_address IN ('São Paulo - SP', 'Campinas - SP', 'Santos - SP')
ORDER BY i.id;

-- Resumo da demonstração.
SELECT
    COUNT(*) AS total_deliveries,
    COUNT(*) FILTER (WHERE d.status = 'DELIVERED') AS delivered_deliveries,
    COUNT(*) FILTER (WHERE d.status = 'CANCELED') AS canceled_deliveries,
    COUNT(*) FILTER (WHERE d.status = 'PENDING') AS pending_deliveries
FROM deliveries d
JOIN customers c ON c.id = d.customer_id
WHERE c.document = '12.345.678/0001-99'
  AND d.origin_address IN ('São Paulo - SP', 'Campinas - SP', 'Santos - SP');

SELECT
    COUNT(*) AS total_invoices,
    COALESCE(SUM(i.total_value), 0) AS total_billed_value
FROM invoices i
JOIN customers c ON c.id = i.customer_id
JOIN deliveries d ON d.id = i.delivery_id
WHERE c.document = '12.345.678/0001-99'
  AND d.origin_address IN ('São Paulo - SP', 'Campinas - SP', 'Santos - SP');

-- Esperado: 3 entregas (1 DELIVERED, 1 PENDING, 1 CANCELED) e 1 fatura.
