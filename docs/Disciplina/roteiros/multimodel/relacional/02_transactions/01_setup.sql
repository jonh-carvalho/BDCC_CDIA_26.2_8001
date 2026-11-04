-- SWIFTTRACK CORE - Cena 1: preparação dos dados de demonstração
-- O bloco DO evita comandos exclusivos do psql e pode ser executado por extensões PostgreSQL do VS Code.
SET search_path TO swifttrack_core;

DO $$
DECLARE
  v_customer_id customers.id%TYPE;
  v_driver_id drivers.id%TYPE;
  v_vehicle_id vehicles.id%TYPE;
BEGIN
  RAISE NOTICE '==========================================';
  RAISE NOTICE 'CENA 1: SETUP DE DADOS BASE';
  RAISE NOTICE '==========================================';

  INSERT INTO customers (document, name, email, address)
  VALUES ('12.345.678/0001-99', 'Logística Veloz LTDA', 'contato@veloz.com.br', 'Av. Paulista, 1000 - SP')
  ON CONFLICT (document) DO UPDATE
  SET name = EXCLUDED.name, email = EXCLUDED.email, address = EXCLUDED.address
  RETURNING id INTO v_customer_id;

  INSERT INTO drivers (name, cpf, cnh_number, cnh_category, hired_at)
  VALUES ('Carlos Silva', '123.456.789-00', '00123456789', 'E', '2023-03-15')
  ON CONFLICT (cpf) DO UPDATE
  SET name = EXCLUDED.name, cnh_number = EXCLUDED.cnh_number,
    cnh_category = EXCLUDED.cnh_category, hired_at = EXCLUDED.hired_at
  RETURNING id INTO v_driver_id;

  INSERT INTO vehicles (plate, model, manufacturer, year, capacity_kg)
  VALUES ('ABC-1D23', 'FH 540', 'Volvo', 2024, 25000.00)
  ON CONFLICT (plate) DO UPDATE
  SET model = EXCLUDED.model, manufacturer = EXCLUDED.manufacturer,
    year = EXCLUDED.year, capacity_kg = EXCLUDED.capacity_kg
  RETURNING id INTO v_vehicle_id;

  -- Remove apenas os dados previamente criados por estas cenas.
  DELETE FROM invoices
  WHERE delivery_id IN (
    SELECT d.id
    FROM deliveries d
    WHERE d.customer_id = v_customer_id
      AND (d.origin_address, d.destination_address) IN (
        ('São Paulo - SP', 'Rio de Janeiro - RJ'),
        ('Campinas - SP', 'Belo Horizonte - MG'),
        ('Santos - SP', 'Porto Alegre - RS')
      )
  )
  OR invoice_number IN ('NF-2026-0001', 'NF-2026-0002', 'NF-2026-0003');

  DELETE FROM deliveries
  WHERE customer_id = v_customer_id
    AND (origin_address, destination_address) IN (
      ('São Paulo - SP', 'Rio de Janeiro - RJ'),
      ('Campinas - SP', 'Belo Horizonte - MG'),
      ('Santos - SP', 'Porto Alegre - RS')
    );

  INSERT INTO deliveries (
    customer_id, driver_id, vehicle_id, origin_address, destination_address,
    weight_kg, status, scheduled_at
  )
  VALUES
    (v_customer_id, v_driver_id, v_vehicle_id, 'São Paulo - SP', 'Rio de Janeiro - RJ',
     5000.00, 'PENDING', NOW() + INTERVAL '1 day'),
    (v_customer_id, v_driver_id, v_vehicle_id, 'Campinas - SP', 'Belo Horizonte - MG',
     3000.00, 'PENDING', NOW() + INTERVAL '3 days'),
    (v_customer_id, v_driver_id, v_vehicle_id, 'Santos - SP', 'Porto Alegre - RS',
     10000.00, 'CANCELED', NOW() + INTERVAL '4 days');

  RAISE NOTICE 'Cliente, motorista, veículo e três entregas preparados.';
END;
$$;

SELECT d.id, d.origin_address, d.destination_address, d.status
FROM deliveries d
JOIN customers c ON c.id = d.customer_id
WHERE c.document = '12.345.678/0001-99'
  AND d.origin_address IN ('São Paulo - SP', 'Campinas - SP', 'Santos - SP')
ORDER BY d.id;
