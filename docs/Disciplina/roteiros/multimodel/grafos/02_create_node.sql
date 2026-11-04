-- ============================================
-- Script: Criar Nós do Grafo Logístico
-- Grafo: logistics_network
-- ============================================

SET search_path = "$user", public, ag_catalog;

-- ------------------------------------------
-- 1. HUBS LOGÍSTICOS (10 hubs)
-- ------------------------------------------

-- Hub São Paulo (Central)
SELECT * FROM cypher('logistics_network', $$
    CREATE (:Hub {
        id: 'HUB_SP', 
        name: 'São Paulo Central', 
        city: 'São Paulo', 
        state: 'SP',
        capacity: 5000,
        latitude: -23.5505,
        longitude: -46.6333,
        created_at: '2025-01-01'::date
    })
$$) AS (result agtype);

-- Hub Rio de Janeiro
SELECT * FROM cypher('logistics_network', $$
    CREATE (:Hub {
        id: 'HUB_RJ', 
        name: 'Rio de Janeiro Central', 
        city: 'Rio de Janeiro', 
        state: 'RJ',
        capacity: 3000,
        latitude: -22.9068,
        longitude: -43.1729,
        created_at: '2025-01-01'::date
    })
$$) AS (result agtype);

-- Hub Belo Horizonte
SELECT * FROM cypher('logistics_network', $$
    CREATE (:Hub {
        id: 'HUB_MG', 
        name: 'Belo Horizonte Hub', 
        city: 'Belo Horizonte', 
        state: 'MG',
        capacity: 2000,
        latitude: -19.9167,
        longitude: -43.9345,
        created_at: '2025-01-01'::date
    })
$$) AS (result agtype);

-- Hub Curitiba
SELECT * FROM cypher('logistics_network', $$
    CREATE (:Hub {
        id: 'HUB_PR', 
        name: 'Curitiba Hub', 
        city: 'Curitiba', 
        state: 'PR',
        capacity: 1500,
        latitude: -25.4284,
        longitude: -49.2733,
        created_at: '2025-01-01'::date
    })
$$) AS (result agtype);

-- Hub Porto Alegre
SELECT * FROM cypher('logistics_network', $$
    CREATE (:Hub {
        id: 'HUB_RS', 
        name: 'Porto Alegre Hub', 
        city: 'Porto Alegre', 
        state: 'RS',
        capacity: 1800,
        latitude: -30.0346,
        longitude: -51.2177,
        created_at: '2025-01-01'::date
    })
$$) AS (result agtype);

-- Hub Brasília
SELECT * FROM cypher('logistics_network', $$
    CREATE (:Hub {
        id: 'HUB_DF', 
        name: 'Brasília Hub', 
        city: 'Brasília', 
        state: 'DF',
        capacity: 2500,
        latitude: -15.7975,
        longitude: -47.8919,
        created_at: '2025-01-01'::date
    })
$$) AS (result agtype);

-- Hub Salvador
SELECT * FROM cypher('logistics_network', $$
    CREATE (:Hub {
        id: 'HUB_BA', 
        name: 'Salvador Hub', 
        city: 'Salvador', 
        state: 'BA',
        capacity: 1200,
        latitude: -12.9714,
        longitude: -38.5014,
        created_at: '2025-01-01'::date
    })
$$) AS (result agtype);

-- Hub Recife
SELECT * FROM cypher('logistics_network', $$
    CREATE (:Hub {
        id: 'HUB_PE', 
        name: 'Recife Hub', 
        city: 'Recife', 
        state: 'PE',
        capacity: 1000,
        latitude: -8.0476,
        longitude: -34.8770,
        created_at: '2025-01-01'::date
    })
$$) AS (result agtype);

-- Hub Fortaleza
SELECT * FROM cypher('logistics_network', $$
    CREATE (:Hub {
        id: 'HUB_CE', 
        name: 'Fortaleza Hub', 
        city: 'Fortaleza', 
        state: 'CE',
        capacity: 1100,
        latitude: -3.7172,
        longitude: -38.5433,
        created_at: '2025-01-01'::date
    })
$$) AS (result agtype);

-- Hub Manaus
SELECT * FROM cypher('logistics_network', $$
    CREATE (:Hub {
        id: 'HUB_AM', 
        name: 'Manaus Hub', 
        city: 'Manaus', 
        state: 'AM',
        capacity: 800,
        latitude: -3.1190,
        longitude: -60.0217,
        created_at: '2025-01-01'::date
    })
$$) AS (result agtype);


-- ------------------------------------------
-- 2. MOTORISTAS (15 motoristas)
-- ------------------------------------------

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Driver {id: 'DRV_001', name: 'Carlos Silva', license: 'CNH-D', rating: 4.8, years_experience: 8, status: 'active'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Driver {id: 'DRV_002', name: 'Ana Santos', license: 'CNH-D', rating: 4.9, years_experience: 10, status: 'active'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Driver {id: 'DRV_003', name: 'Pedro Oliveira', license: 'CNH-C', rating: 4.7, years_experience: 6, status: 'active'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Driver {id: 'DRV_004', name: 'Maria Costa', license: 'CNH-D', rating: 4.6, years_experience: 5, status: 'active'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Driver {id: 'DRV_005', name: 'João Pereira', license: 'CNH-C', rating: 4.5, years_experience: 4, status: 'active'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Driver {id: 'DRV_006', name: 'Fernanda Lima', license: 'CNH-D', rating: 4.9, years_experience: 12, status: 'active'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Driver {id: 'DRV_007', name: 'Roberto Alves', license: 'CNH-C', rating: 4.4, years_experience: 3, status: 'active'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Driver {id: 'DRV_008', name: 'Lucia Mendes', license: 'CNH-D', rating: 4.8, years_experience: 9, status: 'active'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Driver {id: 'DRV_009', name: 'Marcos Souza', license: 'CNH-C', rating: 4.3, years_experience: 2, status: 'inactive'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Driver {id: 'DRV_010', name: 'Patricia Rocha', license: 'CNH-D', rating: 4.7, years_experience: 7, status: 'active'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Driver {id: 'DRV_011', name: 'Ricardo Ferreira', license: 'CNH-C', rating: 4.6, years_experience: 5, status: 'active'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Driver {id: 'DRV_012', name: 'Camila Barbosa', license: 'CNH-D', rating: 4.8, years_experience: 8, status: 'active'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Driver {id: 'DRV_013', name: 'André Martins', license: 'CNH-C', rating: 4.5, years_experience: 4, status: 'active'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Driver {id: 'DRV_014', name: 'Juliana Cardoso', license: 'CNH-D', rating: 4.9, years_experience: 11, status: 'active'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Driver {id: 'DRV_015', name: 'Bruno Araújo', license: 'CNH-C', rating: 4.4, years_experience: 3, status: 'active'})
$$) AS (result agtype);


-- ------------------------------------------
-- 3. VEÍCULOS (10 veículos)
-- ------------------------------------------

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Vehicle {id: 'VEH_001', type: 'Van', capacity_kg: 1000, plate: 'ABC-1234', year: 2022, status: 'available'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Vehicle {id: 'VEH_002', type: 'Caminhão Pequeno', capacity_kg: 3000, plate: 'XYZ-5678', year: 2021, status: 'available'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Vehicle {id: 'VEH_003', type: 'Moto', capacity_kg: 50, plate: 'MOT-9012', year: 2023, status: 'available'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Vehicle {id: 'VEH_004', type: 'Caminhão Grande', capacity_kg: 8000, plate: 'TRK-3456', year: 2020, status: 'available'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Vehicle {id: 'VEH_005', type: 'Van', capacity_kg: 1200, plate: 'VAN-7890', year: 2023, status: 'available'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Vehicle {id: 'VEH_006', type: 'Caminhão Médio', capacity_kg: 5000, plate: 'MED-2345', year: 2022, status: 'available'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Vehicle {id: 'VEH_007', type: 'Moto', capacity_kg: 40, plate: 'MOT-6789', year: 2024, status: 'available'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Vehicle {id: 'VEH_008', type: 'Van', capacity_kg: 1100, plate: 'VAN-0123', year: 2021, status: 'maintenance'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Vehicle {id: 'VEH_009', type: 'Caminhão Pequeno', capacity_kg: 3500, plate: 'TRK-4567', year: 2023, status: 'available'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Vehicle {id: 'VEH_010', type: 'Caminhão Grande', capacity_kg: 10000, plate: 'BIG-8901', year: 2019, status: 'available'})
$$) AS (result agtype);


-- ------------------------------------------
-- 4. CLIENTES (20 clientes)
-- ------------------------------------------

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_001', name: 'Empresa ABC Ltda', city: 'São Paulo', state: 'SP', type: 'B2B', priority: 'high'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_002', name: 'Loja XYZ', city: 'Rio de Janeiro', state: 'RJ', type: 'B2C', priority: 'medium'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_003', name: 'Indústria DEF S.A.', city: 'Belo Horizonte', state: 'MG', type: 'B2B', priority: 'high'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_004', name: 'Comércio GHI', city: 'Curitiba', state: 'PR', type: 'B2C', priority: 'low'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_005', name: 'Distribuidora JKL', city: 'Porto Alegre', state: 'RS', type: 'B2B', priority: 'medium'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_006', name: 'Tech Solutions MNO', city: 'Brasília', state: 'DF', type: 'B2B', priority: 'high'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_007', name: 'Mercado PQR', city: 'Salvador', state: 'BA', type: 'B2C', priority: 'medium'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_008', name: 'Farmácia STU', city: 'Recife', state: 'PE', type: 'B2C', priority: 'high'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_009', name: 'Construtora VWX', city: 'Fortaleza', state: 'CE', type: 'B2B', priority: 'medium'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_010', name: 'Restaurante YZA', city: 'Manaus', state: 'AM', type: 'B2C', priority: 'low'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_011', name: 'Supermercado BCD', city: 'São Paulo', state: 'SP', type: 'B2C', priority: 'high'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_012', name: 'Eletro EFG', city: 'Rio de Janeiro', state: 'RJ', type: 'B2C', priority: 'medium'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_013', name: 'Auto Peças HIJ', city: 'Belo Horizonte', state: 'MG', type: 'B2B', priority: 'medium'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_014', name: 'Livraria KLM', city: 'Curitiba', state: 'PR', type: 'B2C', priority: 'low'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_015', name: 'Têxtil NOP', city: 'Porto Alegre', state: 'RS', type: 'B2B', priority: 'high'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_016', name: 'Alimentos QRS', city: 'Brasília', state: 'DF', type: 'B2B', priority: 'high'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_017', name: 'Pet Shop TUV', city: 'Salvador', state: 'BA', type: 'B2C', priority: 'low'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_018', name: 'Ótica WXY', city: 'Recife', state: 'PE', type: 'B2C', priority: 'medium'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_019', name: 'Móveis ZAB', city: 'Fortaleza', state: 'CE', type: 'B2B', priority: 'medium'})
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    CREATE (:Customer {id: 'CUST_020', name: 'Cosméticos CDE', city: 'Manaus', state: 'AM', type: 'B2C', priority: 'low'})
$$) AS (result agtype);

-- Mensagem de confirmação
DO $$
BEGIN
    RAISE NOTICE '✅ Todos os nós criados com sucesso!';
    RAISE NOTICE '   - 10 Hubs';
    RAISE NOTICE '   - 15 Motoristas';
    RAISE NOTICE '   - 10 Veículos';
    RAISE NOTICE '   - 20 Clientes';
END $$;