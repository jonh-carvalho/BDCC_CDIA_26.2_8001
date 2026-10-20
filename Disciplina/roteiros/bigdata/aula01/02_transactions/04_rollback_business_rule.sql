-- SWIFTTRACK CORE - Cena 4: tentativa de faturar entrega cancelada
SET search_path TO swifttrack_core;

\echo '=========================================='
\echo 'CENA 4: FALHA — ENTREGA CANCELADA (ROLLBACK)'
\echo '=========================================='

\echo 'Estado ANTES (entrega cancelada):'
SELECT d.id, d.status
FROM deliveries d
JOIN customers c ON c.id = d.customer_id
WHERE c.document = '12.345.678/0001-99'
  AND d.origin_address = 'Santos - SP'
  AND d.destination_address = 'Porto Alegre - RS';

BEGIN;

-- Simula uma validação da aplicação antes de atualizar ou faturar.
DO $$
DECLARE
    v_status VARCHAR;
BEGIN
    SELECT d.status INTO v_status
    FROM deliveries d
    JOIN customers c ON c.id = d.customer_id
    WHERE c.document = '12.345.678/0001-99'
      AND d.origin_address = 'Santos - SP'
      AND d.destination_address = 'Porto Alegre - RS';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Entrega de demonstração não encontrada; execute a Cena 1 primeiro';
    END IF;

    IF v_status = 'CANCELED' THEN
        RAISE EXCEPTION 'REGRA DE NEGÓCIO VIOLADA: Não é permitido faturar entrega cancelada';
    END IF;
END $$;

-- O DO block lança uma exceção; o ROLLBACK encerra a transação abortada.
ROLLBACK;

\echo 'ROLLBACK executado — entrega continua CANCELED e nenhuma fatura foi criada!'
\echo 'Estado DEPOIS:'
SELECT d.id, d.status
FROM deliveries d
JOIN customers c ON c.id = d.customer_id
WHERE c.document = '12.345.678/0001-99'
  AND d.origin_address = 'Santos - SP'
  AND d.destination_address = 'Porto Alegre - RS';
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
