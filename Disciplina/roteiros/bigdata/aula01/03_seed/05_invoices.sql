-- =====================================================================
-- SWIFTTRACK CORE - Cena 5: faturas para entregas concluídas
-- Pré-requisito: cena 4 executada.
-- =====================================================================

SET search_path TO swifttrack_core;

\echo 'Gerando faturas para entregas DELIVERED...'

WITH invoice_inputs AS MATERIALIZED (
    SELECT
        d.id AS delivery_id,
        d.customer_id,
        d.delivered_at,
        d.weight_kg,
        ROUND((d.weight_kg * (1.5 + random() * 2.5))::numeric, 2) AS total_value,
        random() AS status_roll,
        random() AS paid_at_roll
    FROM deliveries d
    WHERE d.status = 'DELIVERED' AND d.delivered_at IS NOT NULL
)
INSERT INTO invoices (
    delivery_id, customer_id, invoice_number, series,
    total_value, tax_value, net_value, status,
    issued_at, due_date, paid_at
)
SELECT
    d.delivery_id,
    d.customer_id,
    'NF-' || EXTRACT(YEAR FROM d.delivered_at)::text || '-' || lpad(d.delivery_id::text, 6, '0'),
    '001',
    d.total_value,
    ROUND((d.total_value * 0.15)::numeric, 2),
    d.total_value - ROUND((d.total_value * 0.15)::numeric, 2),
    CASE
        WHEN d.status_roll < 8.0 / 12 THEN 'PAID'
        WHEN d.status_roll < 11.0 / 12 THEN 'ISSUED'
        ELSE 'OVERDUE'
    END,
    d.delivered_at,
    (d.delivered_at + INTERVAL '30 days')::date,
    CASE
        WHEN d.status_roll < 8.0 / 12
        THEN d.delivered_at + (d.paid_at_roll * INTERVAL '30 days')
        ELSE NULL
    END
FROM invoice_inputs d;

SELECT '   → ' || COUNT(*) || ' faturas no banco.' FROM invoices;
