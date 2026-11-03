Perfeito! Vou preparar os **scripts completos e prontos para execução** em aula, organizados por etapas lógicas.

---

## **📁 Scripts Completos - Semana 3: Apache AGE e Grafos**

### **1. docker-compose-age.yml**
*Configuração do ambiente Docker com PostgreSQL + Apache AGE*

```yaml
version: '3.8'

services:
  postgres-age:
    image: apache/age:latest
    container_name: swifttrack_age
    environment:
      POSTGRES_DB: swifttrack_graph
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secret123
      POSTGRES_INITDB_ARGS: "--encoding=UTF8"
    ports:
      - "5433:5432"
    volumes:
      - age_data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U admin -d swifttrack_graph"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  age_data:
    driver: local
```

---

### **2. 01_enable_age.sql**
*Habilitar extensão Apache AGE e criar grafo*

```sql
-- ============================================
-- Script: Habilitar Apache AGE
-- Executar no banco: swifttrack_graph
-- ============================================

-- Carregar extensão AGE
CREATE EXTENSION IF NOT EXISTS age;
LOAD 'age';

-- Configurar search_path para incluir ag_catalog
SET search_path = "$user", public, ag_catalog;

-- Criar o grafo logistics_network
SELECT create_graph('logistics_network');

-- Verificar grafos criados
SELECT * FROM ag_graph;

-- Mensagem de confirmação
DO $$
BEGIN
    RAISE NOTICE '✅ Apache AGE habilitado com sucesso!';
    RAISE NOTICE '✅ Grafo "logistics_network" criado!';
END $$;
```

---

### **3. 02_create_nodes.sql**
*Criar todos os nós do grafo (Hubs, Motoristas, Veículos, Clientes)*

```sql
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
```

---

### **4. 03_create_relationships.sql**
*Criar todos os relacionamentos (rotas, atribuições, entregas)*

```sql
-- ============================================
-- Script: Criar Relacionamentos do Grafo
-- Grafo: logistics_network
-- ============================================

SET search_path = "$user", public, ag_catalog;

-- ------------------------------------------
-- 1. ROTAS ENTRE HUBS (arestas CONNECTS_TO)
-- ------------------------------------------

-- SP <-> RJ
SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_SP'}), (b:Hub {id: 'HUB_RJ'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 430, avg_time_hours: 6, cost_per_km: 2.5, road_condition: 'good'}]->(b)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_RJ'}), (b:Hub {id: 'HUB_SP'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 430, avg_time_hours: 6, cost_per_km: 2.5, road_condition: 'good'}]->(b)
$$) AS (result agtype);

-- RJ <-> MG
SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_RJ'}), (b:Hub {id: 'HUB_MG'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 440, avg_time_hours: 7, cost_per_km: 2.3, road_condition: 'good'}]->(b)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_MG'}), (b:Hub {id: 'HUB_RJ'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 440, avg_time_hours: 7, cost_per_km: 2.3, road_condition: 'good'}]->(b)
$$) AS (result agtype);

-- SP <-> PR
SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_SP'}), (b:Hub {id: 'HUB_PR'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 410, avg_time_hours: 5.5, cost_per_km: 2.4, road_condition: 'excellent'}]->(b)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_PR'}), (b:Hub {id: 'HUB_SP'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 410, avg_time_hours: 5.5, cost_per_km: 2.4, road_condition: 'excellent'}]->(b)
$$) AS (result agtype);

-- MG <-> PR
SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_MG'}), (b:Hub {id: 'HUB_PR'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 590, avg_time_hours: 8, cost_per_km: 2.2, road_condition: 'fair'}]->(b)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_PR'}), (b:Hub {id: 'HUB_MG'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 590, avg_time_hours: 8, cost_per_km: 2.2, road_condition: 'fair'}]->(b)
$$) AS (result agtype);

-- PR <-> RS
SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_PR'}), (b:Hub {id: 'HUB_RS'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 710, avg_time_hours: 9, cost_per_km: 2.1, road_condition: 'good'}]->(b)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_RS'}), (b:Hub {id: 'HUB_PR'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 710, avg_time_hours: 9, cost_per_km: 2.1, road_condition: 'good'}]->(b)
$$) AS (result agtype);

-- SP <-> DF
SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_SP'}), (b:Hub {id: 'HUB_DF'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 1015, avg_time_hours: 12, cost_per_km: 2.0, road_condition: 'good'}]->(b)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_DF'}), (b:Hub {id: 'HUB_SP'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 1015, avg_time_hours: 12, cost_per_km: 2.0, road_condition: 'good'}]->(b)
$$) AS (result agtype);

-- DF <-> BA
SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_DF'}), (b:Hub {id: 'HUB_BA'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 1440, avg_time_hours: 16, cost_per_km: 1.9, road_condition: 'fair'}]->(b)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_BA'}), (b:Hub {id: 'HUB_DF'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 1440, avg_time_hours: 16, cost_per_km: 1.9, road_condition: 'fair'}]->(b)
$$) AS (result agtype);

-- BA <-> PE
SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_BA'}), (b:Hub {id: 'HUB_PE'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 840, avg_time_hours: 11, cost_per_km: 2.0, road_condition: 'good'}]->(b)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_PE'}), (b:Hub {id: 'HUB_BA'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 840, avg_time_hours: 11, cost_per_km: 2.0, road_condition: 'good'}]->(b)
$$) AS (result agtype);

-- PE <-> CE
SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_PE'}), (b:Hub {id: 'HUB_CE'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 800, avg_time_hours: 10, cost_per_km: 2.1, road_condition: 'good'}]->(b)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_CE'}), (b:Hub {id: 'HUB_PE'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 800, avg_time_hours: 10, cost_per_km: 2.1, road_condition: 'good'}]->(b)
$$) AS (result agtype);

-- DF <-> AM (rota fluvial/aérea mais cara)
SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_DF'}), (b:Hub {id: 'HUB_AM'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 2700, avg_time_hours: 24, cost_per_km: 3.5, road_condition: 'mixed'}]->(b)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (a:Hub {id: 'HUB_AM'}), (b:Hub {id: 'HUB_DF'})
    CREATE (a)-[:CONNECTS_TO {distance_km: 2700, avg_time_hours: 24, cost_per_km: 3.5, road_condition: 'mixed'}]->(b)
$$) AS (result agtype);


-- ------------------------------------------
-- 2. ATRIBUIÇÃO DE MOTORISTAS A VEÍCULOS
-- ------------------------------------------

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_001'}), (v:Vehicle {id: 'VEH_001'})
    CREATE (d)-[:ASSIGNED_TO {since: '2025-01-15'::date, status: 'active', shift: 'morning'}]->(v)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_002'}), (v:Vehicle {id: 'VEH_002'})
    CREATE (d)-[:ASSIGNED_TO {since: '2025-03-20'::date, status: 'active', shift: 'afternoon'}]->(v)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_003'}), (v:Vehicle {id: 'VEH_003'})
    CREATE (d)-[:ASSIGNED_TO {since: '2025-02-10'::date, status: 'active', shift: 'morning'}]->(v)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_004'}), (v:Vehicle {id: 'VEH_004'})
    CREATE (d)-[:ASSIGNED_TO {since: '2025-04-05'::date, status: 'active', shift: 'night'}]->(v)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_005'}), (v:Vehicle {id: 'VEH_005'})
    CREATE (d)-[:ASSIGNED_TO {since: '2025-05-12'::date, status: 'active', shift: 'morning'}]->(v)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_006'}), (v:Vehicle {id: 'VEH_006'})
    CREATE (d)-[:ASSIGNED_TO {since: '2025-01-20'::date, status: 'active', shift: 'afternoon'}]->(v)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_007'}), (v:Vehicle {id: 'VEH_007'})
    CREATE (d)-[:ASSIGNED_TO {since: '2025-06-15'::date, status: 'active', shift: 'morning'}]->(v)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_008'}), (v:Vehicle {id: 'VEH_008'})
    CREATE (d)-[:ASSIGNED_TO {since: '2025-03-01'::date, status: 'inactive', shift: 'afternoon'}]->(v)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_009'}), (v:Vehicle {id: 'VEH_009'})
    CREATE (d)-[:ASSIGNED_TO {since: '2025-07-10'::date, status: 'active', shift: 'night'}]->(v)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_010'}), (v:Vehicle {id: 'VEH_010'})
    CREATE (d)-[:ASSIGNED_TO {since: '2025-02-28'::date, status: 'active', shift: 'morning'}]->(v)
$$) AS (result agtype);


-- ------------------------------------------
-- 3. ENTREGAS REALIZADAS (DELIVERED)
-- ------------------------------------------

-- Entregas completadas
SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_001'}), (c:Customer {id: 'CUST_001'})
    CREATE (d)-[:DELIVERED {
        date: '2026-10-15'::date, 
        weight_kg: 250, 
        status: 'completed', 
        rating: 5,
        delivery_time_hours: 2.5,
        notes: 'Entrega realizada no horário'
    }]->(c)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_002'}), (c:Customer {id: 'CUST_002'})
    CREATE (d)-[:DELIVERED {
        date: '2026-10-20'::date, 
        weight_kg: 1200, 
        status: 'completed', 
        rating: 4,
        delivery_time_hours: 3.0,
        notes: 'Cliente satisfeito'
    }]->(c)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_003'}), (c:Customer {id: 'CUST_003'})
    CREATE (d)-[:DELIVERED {
        date: '2026-10-18'::date, 
        weight_kg: 800, 
        status: 'completed', 
        rating: 5,
        delivery_time_hours: 4.0,
        notes: 'Carga frágil entregue com cuidado'
    }]->(c)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_004'}), (c:Customer {id: 'CUST_004'})
    CREATE (d)-[:DELIVERED {
        date: '2026-10-22'::date, 
        weight_kg: 3500, 
        status: 'completed', 
        rating: 4,
        delivery_time_hours: 5.5,
        notes: 'Entrega grande, requeriu ajuda'
    }]->(c)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_005'}), (c:Customer {id: 'CUST_005'})
    CREATE (d)-[:DELIVERED {
        date: '2026-10-19'::date, 
        weight_kg: 900, 
        status: 'completed', 
        rating: 5,
        delivery_time_hours: 2.0,
        notes: 'Entrega rápida'
    }]->(c)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_006'}), (c:Customer {id: 'CUST_006'})
    CREATE (d)-[:DELIVERED {
        date: '2026-10-21'::date, 
        weight_kg: 4500, 
        status: 'completed', 
        rating: 5,
        delivery_time_hours: 6.0,
        notes: 'Carga pesada, tudo certo'
    }]->(c)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_007'}), (c:Customer {id: 'CUST_007'})
    CREATE (d)-[:DELIVERED {
        date: '2026-10-23'::date, 
        weight_kg: 30, 
        status: 'completed', 
        rating: 4,
        delivery_time_hours: 1.5,
        notes: 'Entrega expressa'
    }]->(c)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_008'}), (c:Customer {id: 'CUST_008'})
    CREATE (d)-[:DELIVERED {
        date: '2026-10-17'::date, 
        weight_kg: 150, 
        status: 'completed', 
        rating: 3,
        delivery_time_hours: 3.5,
        notes: 'Atraso devido ao trânsito'
    }]->(c)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_010'}), (c:Customer {id: 'CUST_009'})
    CREATE (d)-[:DELIVERED {
        date: '2026-10-24'::date, 
        weight_kg: 7500, 
        status: 'completed', 
        rating: 5,
        delivery_time_hours: 8.0,
        notes: 'Carga extra-large, operação complexa'
    }]->(c)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_011'}), (c:Customer {id: 'CUST_010'})
    CREATE (d)-[:DELIVERED {
        date: '2026-10-16'::date, 
        weight_kg: 200, 
        status: 'completed', 
        rating: 4,
        delivery_time_hours: 2.5,
        notes: 'Entrega padrão'
    }]->(c)
$$) AS (result agtype);

-- Entregas em trânsito
SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_001'}), (c:Customer {id: 'CUST_011'})
    CREATE (d)-[:DELIVERED {
        date: '2026-10-28'::date, 
        weight_kg: 500, 
        status: 'in_transit', 
        rating: null,
        delivery_time_hours: null,
        notes: 'Em rota, previsão 2h'
    }]->(c)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_002'}), (c:Customer {id: 'CUST_012'})
    CREATE (d)-[:DELIVERED {
        date: '2026-10-29'::date, 
        weight_kg: 1800, 
        status: 'in_transit', 
        rating: null,
        delivery_time_hours: null,
        notes: 'Saiu do hub há 1h'
    }]->(c)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_003'}), (c:Customer {id: 'CUST_013'})
    CREATE (d)-[:DELIVERED {
        date: '2026-10-29'::date, 
        weight_kg: 600, 
        status: 'in_transit', 
        rating: null,
        delivery_time_hours: null,
        notes: 'Próximo ao destino'
    }]->(c)
$$) AS (result agtype);

-- Entregas agendadas (futuras)
SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_004'}), (c:Customer {id: 'CUST_014'})
    CREATE (d)-[:DELIVERED {
        date: '2026-10-30'::date, 
        weight_kg: 100, 
        status: 'scheduled', 
        rating: null,
        delivery_time_hours: null,
        notes: 'Agendada para amanhã'
    }]->(c)
$$) AS (result agtype);

SELECT * FROM cypher('logistics_network', $$
    MATCH (d:Driver {id: 'DRV_005'}), (c:Customer {id: 'CUST_015'})
    CREATE (d)-[:DELIVERED {
        date: '2026-10-31'::date, 
        weight_kg: 3000, 
        status: 'scheduled', 
        rating: null,
        delivery_time_hours: null,
        notes: 'Carga programada'
    }]->(c)
$$) AS (result agtype);

-- Mensagem de confirmação
DO $$
DECLARE
    route_count INTEGER;
    assignment_count INTEGER;
    delivery_count INTEGER;
BEGIN
    SELECT count(*) INTO route_count FROM cypher('logistics_network', $$
        MATCH ()-[r:CONNECTS_TO]->() RETURN r
    $$) AS (r agtype);
    
    SELECT count(*) INTO assignment_count FROM cypher('logistics_network', $$
        MATCH ()-[r:ASSIGNED_TO]->() RETURN r
    $$) AS (r agtype);
    
    SELECT count(*) INTO delivery_count FROM cypher('logistics_network', $$
        MATCH ()-[r:DELIVERED]->() RETURN r
    $$) AS (r agtype);
    
    RAISE NOTICE '✅ Todos os relacionamentos criados com sucesso!';
    RAISE NOTICE '   - % rotas entre hubs', route_count;
    RAISE NOTICE '   - % atribuições motorista-veículo', assignment_count;
    RAISE NOTICE '   - % entregas registradas', delivery_count;
END $$;
```

---

### **5. 04_queries_examples.sql**
*Queries Cypher de exemplo para demonstração em aula*

```sql
-- ============================================
-- Script: Queries Cypher de Exemplo
-- Grafo: logistics_network
-- ============================================

SET search_path = "$user", public, ag_catalog;

-- ------------------------------------------
-- QUERY 1: Traversal em 3 hops
-- Encontrar motoristas que entregaram em cidades conectadas a SP em até 3 hops
-- ------------------------------------------

SELECT * FROM cypher('logistics_network', $$
    MATCH (hub:Hub {id: 'HUB_SP'})-[:CONNECTS_TO*1..3]->(connectedHub)
    MATCH (driver:Driver)-[:DELIVERED]->(customer:Customer)
    WHERE customer.city = connectedHub.city
    RETURN DISTINCT 
        driver.name AS motorista,
        driver.rating AS avaliacao,
        count(customer) AS total_entregas,
        collect(DISTINCT connectedHub.name) AS hubs_alcancados
    ORDER BY total_entregas DESC
$$) AS (motorista agtype, avaliacao agtype, total_entregas agtype, hubs_alcancados agtype);


-- ------------------------------------------
-- QUERY 2: Caminho mais curto (SP -> PR)
-- ------------------------------------------

SELECT * FROM cypher('logistics_network', $$
    MATCH path = shortestPath(
        (start:Hub {id: 'HUB_SP'})-[:CONNECTS_TO*]->(end:Hub {id: 'HUB_PR'})
    )
    RETURN 
        [node IN nodes(path) | node.name] AS rota,
        reduce(totalDist = 0, rel IN relationships(path) | totalDist + rel.distance_km) AS distancia_total_km,
        reduce(totalCost = 0, rel IN relationships(path) | totalCost + (rel.distance_km * rel.cost_per_km)) AS custo_total,
        length(path) AS numero_hops
$$) AS (rota agtype, distancia_total_km agtype, custo_total agtype, numero_hops agtype);


-- ------------------------------------------
-- QUERY 3: Análise de rede - Hubs mais conectados
-- ------------------------------------------

SELECT * FROM cypher('logistics_network', $$
    MATCH (hub:Hub)-[r:CONNECTS_TO]->()
    RETURN 
        hub.name AS hub,
        hub.city AS cidade,
        count(r) AS conexoes_saidas,
        sum(r.distance_km) AS distancia_total_coberta_km,
        avg(r.cost_per_km) AS custo_medio_por_km
    ORDER BY conexoes_saidas DESC
$$) AS (hub agtype, cidade agtype, conexoes_saidas agtype, distancia_total_coberta_km agtype, custo_medio_por_km agtype);


-- ------------------------------------------
-- QUERY 4: Detecção de gargalos - Motoristas sobrecarregados
-- ------------------------------------------

SELECT * FROM cypher('logistics_network', $$
    MATCH (driver:Driver)-[:DELIVERED {status: 'in_transit'}]->(customer)
    WITH driver, count(customer) AS entregas_em_andamento
    WHERE entregas_em_andamento > 1
    RETURN 
        driver.name AS motorista,
        driver.rating AS avaliacao,
        entregas_em_andamento,
        driver.status AS status_motorista
    ORDER BY entregas_em_andamento DESC
$$) AS (motorista agtype, avaliacao agtype, entregas_em_andamento agtype, status_motorista agtype);


-- ------------------------------------------
-- QUERY 5: Veículos disponíveis por tipo
-- ------------------------------------------

SELECT * FROM cypher('logistics_network', $$
    MATCH (vehicle:Vehicle {status: 'available'})
    RETURN 
        vehicle.type AS tipo_veiculo,
        count(*) AS quantidade,
        avg(vehicle.capacity_kg) AS capacidade_media_kg,
        min(vehicle.capacity_kg) AS capacidade_minima_kg,
        max(vehicle.capacity_kg) AS capacidade_maxima_kg
    GROUP BY vehicle.type
    ORDER BY quantidade DESC
$$) AS (tipo_veiculo agtype, quantidade agtype, capacidade_media_kg agtype, capacidade_minima_kg agtype, capacidade_maxima_kg agtype);


-- ------------------------------------------
-- QUERY 6: Rating médio dos motoristas por número de entregas
-- ------------------------------------------

SELECT * FROM cypher('logistics_network', $$
    MATCH (driver:Driver)-[:DELIVERED {status: 'completed'}]->(customer)
    WITH driver, 
         count(customer) AS total_entregas,
         avg([r IN relationships((driver)-[:DELIVERED {status: 'completed'}]->()) | r.rating]) AS rating_medio
    WHERE total_entregas >= 2
    RETURN 
        driver.name AS motorista,
        total_entregas,
        round(rating_medio::numeric, 2) AS rating_medio_arredondado,
        driver.years_experience AS anos_experiencia
    ORDER BY rating_medio DESC
$$) AS (motorista agtype, total_entregas agtype, rating_medio_arredondado agtype, anos_experiencia agtype);


-- ------------------------------------------
-- QUERY 7: Custo otimizado de rota SP -> PR considerando múltiplos caminhos
-- ------------------------------------------

SELECT * FROM cypher('logistics_network', $$
    MATCH path = (start:Hub {id: 'HUB_SP'})-[:CONNECTS_TO*1..3]->(end:Hub {id: 'HUB_PR'})
    WHERE start <> end
    WITH path,
         reduce(totalDist = 0, rel IN relationships(path) | totalDist + rel.distance_km) AS distancia,
         reduce(totalCost = 0, rel IN relationships(path) | totalCost + (rel.distance_km * rel.cost_per_km)) AS custo
    RETURN 
        [node IN nodes(path) | node.name] AS caminho,
        distancia AS distancia_km,
        round(custo::numeric, 2) AS custo_estimado,
        length(path) AS hops
    ORDER BY custo ASC
    LIMIT 5
$$) AS (caminho agtype, distancia_km agtype, custo_estimado agtype, hops agtype);


-- Mensagem final
DO $$
BEGIN
    RAISE NOTICE '✅ Todas as queries de exemplo executadas!';
    RAISE NOTICE '💡 Dica: Use estas queries como base para o desafio prático';
END $$;
```

---

### **6. 05_challenge_solution.sql**
*Solução do desafio prático: Rota otimizada de custo mínimo SP -> PR*

```sql
-- ============================================
-- Script: Solução do Desafio Prático
-- Objetivo: Rota otimizada SP -> PR com menor custo
-- Considerando: distância, custo/km, capacidade veículo, rating motorista
-- ============================================

SET search_path = "$user", public, ag_catalog;

-- ------------------------------------------
-- SOLUÇÃO: Encontrar top 3 rotas de menor custo SP -> PR
-- ------------------------------------------

SELECT * FROM cypher('logistics_network', $$
    // Passo 1: Encontrar todos os caminhos possíveis (1 a 3 hops)
    MATCH path = (start:Hub {id: 'HUB_SP'})-[:CONNECTS_TO*1..3]->(end:Hub {id: 'HUB_PR'})
    WHERE start <> end
    
    // Passo 2: Calcular métricas de cada caminho
    WITH path,
         reduce(totalDist = 0, rel IN relationships(path) | totalDist + rel.distance_km) AS distancia_total,
         reduce(totalCost = 0, rel IN relationships(path) | totalCost + (rel.distance_km * rel.cost_per_km)) AS custo_total,
         length(path) AS num_hops
    
    // Passo 3: Filtrar apenas caminhos viáveis e ordenar por custo
    WHERE custo_total > 0
    
    RETURN 
        [node IN nodes(path) | node.name] AS rota,
        distancia_total AS distancia_km,
        round(custo_total::numeric, 2) AS custo_total_estimado,
        num_hops,
        round((custo_total / NULLIF(distancia_total, 0))::numeric, 2) AS custo_medio_por_km
    ORDER BY custo_total ASC
    LIMIT 3
$$) AS (rota agtype, distancia_km agtype, custo_total_estimado agtype, num_hops agtype, custo_medio_por_km agtype);


-- ------------------------------------------
-- BÔNUS: Associar motorista ideal para cada rota
-- ------------------------------------------

SELECT * FROM cypher('logistics_network', $$
    // Encontrar motoristas com rating > 4.5 e veículo disponível com capacidade >= 1000kg
    MATCH (driver:Driver)-[:ASSIGNED_TO {status: 'active'}]->(vehicle:Vehicle {status: 'available'})
    WHERE driver.rating > 4.5 
      AND vehicle.capacity_kg >= 1000
      AND driver.status = 'active'
    
    RETURN 
        driver.name AS motorista_recomendado,
        driver.rating AS rating,
        vehicle.type AS veiculo,
        vehicle.capacity_kg AS capacidade_kg,
        driver.years_experience AS experiencia_anos
    ORDER BY driver.rating DESC, vehicle.capacity_kg DESC
    LIMIT 5
$$) AS (motorista_recomendado agtype, rating agtype, veiculo agtype, capacidade_kg agtype, experiencia_anos agtype);


-- ------------------------------------------
-- ANÁLISE COMPLETA: Rota + Motorista Ideal
-- ------------------------------------------

-- Nota: Esta query combina informações de duas consultas separadas
-- Em um sistema real, você faria JOIN entre os resultados

DO $$
BEGIN
    RAISE NOTICE '═══════════════════════════════════════════════════';
    RAISE NOTICE '🏆 SOLUÇÃO DO DESAFIO: ROTA OTIMIZADA SP → PR';
    RAISE NOTICE '═══════════════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE '📊 Top 3 Rotas por Custo:';
    RAISE NOTICE '   Execute a Query 1 acima para ver os resultados';
    RAISE NOTICE '';
    RAISE NOTICE '🚛 Motoristas Recomendados:';
    RAISE NOTICE '   Execute a Query 2 acima para ver os resultados';
    RAISE NOTICE '';
    RAISE NOTICE '💡 Recomendação Final:';
    RAISE NOTICE '   - Escolha a rota de MENOR CUSTO da Query 1';
    RAISE NOTICE '   - Associe o motorista de MAIOR RATING da Query 2';
    RAISE NOTICE '   - Considere a capacidade do veículo para a carga';
    RAISE NOTICE '═══════════════════════════════════════════════════';
END $$;
```

---

### **7. README_execucao.md**
*Instruções passo a passo para executar em aula*

```markdown
# 📦 Instruções de Execução - Semana 3: Apache AGE

## 🚀 Passo 1: Subir o Ambiente Docker

```bash
# Navegar até a pasta dos scripts
cd semana3_age

# Subir o container
docker-compose -f docker-compose-age.yml up -d

# Aguardar inicialização (~30 segundos)
docker ps

# Verificar logs se necessário
docker logs -f swifttrack_age
```

## 📝 Passo 2: Conectar ao PostgreSQL

### Opção A: Via terminal (psql)
```bash
docker exec -it swifttrack_age psql -U admin -d swifttrack_graph
```

### Opção B: Via pgAdmin/DBeaver
- Host: localhost
- Port: 5433
- Database: swifttrack_graph
- User: admin
- Password: secret123

## 🔧 Passo 3: Executar Scripts em Ordem

```sql
-- 1. Habilitar AGE
\i 01_enable_age.sql

-- 2. Criar nós
\i 02_create_nodes.sql

-- 3. Criar relacionamentos
\i 03_create_relationships.sql

-- 4. Testar queries de exemplo
\i 04_queries_examples.sql

-- 5. Resolver desafio
\i 05_challenge_solution.sql
```

## ✅ Verificação Final

```sql
-- Contar elementos do grafo
SET search_path = "$user", public, ag_catalog;

SELECT 'Hubs' AS tipo, count(*) FROM cypher('logistics_network', $$ MATCH (h:Hub) RETURN h $$) AS (h agtype)
UNION ALL
SELECT 'Motoristas', count(*) FROM cypher('logistics_network', $$ MATCH (d:Driver) RETURN d $$) AS (d agtype)
UNION ALL
SELECT 'Veículos', count(*) FROM cypher('logistics_network', $$ MATCH (v:Vehicle) RETURN v $$) AS (v agtype)
UNION ALL
SELECT 'Clientes', count(*) FROM cypher('logistics_network', $$ MATCH (c:Customer) RETURN c $$) AS (c agtype)
UNION ALL
SELECT 'Rotas', count(*) FROM cypher('logistics_network', $$ MATCH ()-[r:CONNECTS_TO]->() RETURN r $$) AS (r agtype)
UNION ALL
SELECT 'Entregas', count(*) FROM cypher('logistics_network', $$ MATCH ()-[r:DELIVERED]->() RETURN r $$) AS (r agtype);
```

**Resultado esperado:**
- 10 Hubs
- 15 Motoristas
- 10 Veículos
- 20 Clientes
- 18 Rotas (bidirecionais)
- 15 Entregas

## 🐛 Troubleshooting

### Erro: "extension age is not available"
```bash
# Reiniciar container
docker-compose -f docker-compose-age.yml restart
```

### Erro: "graph logistics_network does not exist"
```sql
-- Recriar o grafo
SELECT create_graph('logistics_network');
```

### Erro de conexão
```bash
# Verificar se container está rodando
docker ps | grep swifttrack_age

# Verificar porta
docker port swifttrack_age
```

## 📚 Recursos Adicionais

- Documentação AGE: https://age.apache.org/docs/
- OpenCypher: https://opencypher.org/
- Cheat Sheet Cypher: https://neo4j.com/docs/cypher-cheat-sheet/
```

---

## **📂 Estrutura Final de Arquivos**

```
semana3_age/
├── docker-compose-age.yml
├── 01_enable_age.sql
├── 02_create_nodes.sql
├── 03_create_relationships.sql
├── 04_queries_examples.sql
├── 05_challenge_solution.sql
└── README_execucao.md
```

---

Todos os scripts estão **prontos para copiar e colar**! Quer que eu gere também um **script bash automático** que execute tudo em sequência, ou prefere ajustar algum detalhe nos dados/queries?