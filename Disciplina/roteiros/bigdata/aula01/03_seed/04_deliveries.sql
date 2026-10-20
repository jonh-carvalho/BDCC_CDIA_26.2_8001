-- =====================================================================
-- SWIFTTRACK CORE - Cena 4: entregas (meta de 1.000 registros)
-- Pré-requisitos: cenas 1, 2 e 3 executadas.
-- =====================================================================

SET search_path TO swifttrack_core;

\echo 'Inserindo 1.000 entregas (META PRINCIPAL)...'

WITH delivery_inputs AS MATERIALIZED (
    SELECT
        i,
        random() AS status_roll,
        random() AS scheduled_roll,
        random() AS picked_up_roll,
        random() AS delivered_roll
    FROM generate_series(1, 1000) AS s(i)
)
INSERT INTO deliveries (
    customer_id, driver_id, vehicle_id,
    origin_address, destination_address, weight_kg,
    status, scheduled_at, picked_up_at, delivered_at
)
SELECT
    (SELECT id FROM customers ORDER BY random() LIMIT 1),
    CASE WHEN random() < 0.9
         THEN (SELECT id FROM drivers ORDER BY random() LIMIT 1)
         ELSE NULL
    END,
    CASE WHEN random() < 0.85
         THEN (SELECT id FROM vehicles ORDER BY random() LIMIT 1)
         ELSE NULL
    END,
    fake_city() || ' - ' || (ARRAY['SP','RJ','MG','RS','PR','SC','BA','PE'])[floor(random()*8)+1],
    fake_city() || ' - ' || (ARRAY['SP','RJ','MG','RS','PR','SC','BA','PE'])[floor(random()*8)+1],
    100 + floor(random() * 14900)::int,
    CASE
        WHEN i.status_roll < 0.70 THEN 'DELIVERED'
        WHEN i.status_roll < 0.85 THEN 'IN_TRANSIT'
        WHEN i.status_roll < 0.95 THEN 'PENDING'
        ELSE 'CANCELED'
    END,
    NOW() - (i.scheduled_roll * INTERVAL '90 days'),
    CASE WHEN i.status_roll < 0.85 OR i.status_roll >= 0.95
    THEN NOW() - (i.picked_up_roll * INTERVAL '88 days')
    ELSE NULL
    END,
    CASE WHEN i.status_roll < 0.70
    THEN NOW() - (i.delivered_roll * INTERVAL '85 days')
    ELSE NULL
    END
FROM delivery_inputs i;

SELECT '   → ' || COUNT(*) || ' entregas no banco.' FROM deliveries;
