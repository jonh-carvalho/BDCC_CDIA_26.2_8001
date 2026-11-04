-- =====================================================================
-- SWIFTTRACK CORE - Cena 3: veículos
-- =====================================================================

SET search_path TO swifttrack_core;

SELECT 'Inserindo 12 veículos...' AS mensagem;

INSERT INTO vehicles (plate, model, manufacturer, year, capacity_kg, status)
SELECT
    substr('ABCDEFGHIJKLMNOPQRSTUVWXYZ', floor(random()*26)::int + 1, 1)
    || substr('ABCDEFGHIJKLMNOPQRSTUVWXYZ', floor(random()*26)::int + 1, 1)
    || substr('ABCDEFGHIJKLMNOPQRSTUVWXYZ', floor(random()*26)::int + 1, 1)
    || '-'
    || floor(random()*10)::int::text
    || substr('ABCDEFGHIJKLMNOPQRSTUVWXYZ', floor(random()*26)::int + 1, 1)
    || lpad((floor(random()*100)::int + i)::text, 2, '0'),
    (ARRAY['FH 540','XC60','VM 270','Constellation','Actros','Daf XF','Volvo FH','Scania R','Iveco Stralis','Mercedes Axor'])[floor(random()*10)+1],
    (ARRAY['Volvo','Volvo','VW','VW','Mercedes','Daf','Volvo','Scania','Iveco','Mercedes'])[floor(random()*10)+1],
    2018 + floor(random()*8)::int,
    5000 + floor(random()*25000)::int,
    (ARRAY['AVAILABLE','AVAILABLE','AVAILABLE','AVAILABLE','AVAILABLE','AVAILABLE','AVAILABLE','IN_USE','IN_USE','MAINTENANCE'])[floor(random()*10)+1]
FROM generate_series(1, 12) AS s(i);

SELECT '   → ' || COUNT(*) || ' veículos no banco.' FROM vehicles;
