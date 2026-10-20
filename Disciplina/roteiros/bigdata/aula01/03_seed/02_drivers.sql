-- =====================================================================
-- SWIFTTRACK CORE - Cena 2: motoristas
-- =====================================================================

SET search_path TO swifttrack_core;

\echo 'Inserindo 25 motoristas...'

INSERT INTO drivers (name, cpf, cnh_number, cnh_category, phone, is_active, hired_at)
SELECT
    (ARRAY['Carlos','João','Pedro','Lucas','Marcos','Antônio','José','Paulo','Ricardo','André'])[floor(random()*10)+1]
    || ' ' ||
    (ARRAY['Silva','Santos','Oliveira','Souza','Lima','Pereira','Costa','Ferreira','Almeida','Rodrigues'])[floor(random()*10)+1],
    lpad((floor(random()*1e9)::bigint + i)::text, 11, '0'),
    lpad((floor(random()*1e9)::bigint + i)::text, 11, '0'),
    (ARRAY['C','D','D','E','E','E'])[floor(random()*6)+1],
    '(11) 9' || lpad(floor(random()*1e8)::bigint::text, 8, '0'),
    random() < 0.9,
    (DATE '2020-01-01' + (random() * (CURRENT_DATE - DATE '2020-01-01'))::int)::date
FROM generate_series(1, 25) AS s(i);

SELECT '   → ' || COUNT(*) || ' motoristas no banco.' FROM drivers;
