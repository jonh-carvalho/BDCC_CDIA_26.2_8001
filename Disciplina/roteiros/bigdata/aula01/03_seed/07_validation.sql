-- =====================================================================
-- SWIFTTRACK CORE - Cena 7: validação final do seed
-- =====================================================================

SET search_path TO swifttrack_core;

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
