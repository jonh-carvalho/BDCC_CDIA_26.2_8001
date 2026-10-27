-- =====================================================================
-- SWIFTTRACK CORE - Cena 1: funções auxiliares e clientes
-- =====================================================================

SET search_path TO swifttrack_core;

-- Gera um CPF fictício (apenas formato, não válido matematicamente)
CREATE OR REPLACE FUNCTION fake_cpf() RETURNS VARCHAR AS $$
BEGIN
    RETURN lpad(floor(random()*1e9)::bigint::text, 9, '0');
END;
$$ LANGUAGE plpgsql;

-- Gera um CNPJ fictício
CREATE OR REPLACE FUNCTION fake_cnpj() RETURNS VARCHAR AS $$
BEGIN
    RETURN lpad(floor(random()*1e14)::bigint::text, 14, '0');
END;
$$ LANGUAGE plpgsql;

-- Gera uma placa no padrão Mercosul (ABC1D23)
CREATE OR REPLACE FUNCTION fake_plate() RETURNS VARCHAR AS $$
DECLARE
    letras VARCHAR := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    placa VARCHAR;
BEGIN
    placa := substr(letras, floor(random()*26)::int + 1, 1)
          || substr(letras, floor(random()*26)::int + 1, 1)
          || substr(letras, floor(random()*26)::int + 1, 1)
          || '-'
          || floor(random()*10)::int::text
          || substr(letras, floor(random()*26)::int + 1, 1)
          || lpad(floor(random()*100)::int::text, 2, '0');
    RETURN placa;
END;
$$ LANGUAGE plpgsql;

-- Gera um nome de cidade brasileira fictício (combina prefixo + sufixo)
CREATE OR REPLACE FUNCTION fake_city() RETURNS VARCHAR AS $$
DECLARE
    prefixos VARCHAR[] := ARRAY['São','Rio','Nova','Porto','Santa','Vila','Campo','Belo','Alto','Boa'];
    sufixos  VARCHAR[] := ARRAY['Paulo','Janeiro','Horizonte','Alegre','Vitória','Grande','Verde','Branca','Terra','Vista'];
BEGIN
    RETURN prefixos[floor(random()*10)+1] || ' ' || sufixos[floor(random()*10)+1];
END;
$$ LANGUAGE plpgsql;

\echo 'Funções auxiliares criadas.'
\echo 'Inserindo 80 clientes...'

INSERT INTO customers (document, name, email, address)
SELECT
    CASE WHEN random() < 0.7
         THEN lpad(floor(random()*1e14)::bigint::text, 14, '0')
         ELSE lpad(floor(random()*1e9)::bigint::text, 9, '0')
    END AS document,
    (ARRAY['Transportes','Logística','Distribuidora','Express','Cargas'])[floor(random()*5)+1]
    || ' ' ||
    (ARRAY['Veloz','Rápida','Brasil','Sul','Norte','Central','Prime','Max','Gold','Top'])[floor(random()*10)+1]
    || ' LTDA',
    'contato' || i || '@empresa' || i || '.com.br',
    (ARRAY['Av. Paulista','Rua Augusta','Av. Brasil','Rua das Flores','Av. Central'])[floor(random()*5)+1]
    || ', ' || floor(random()*3000+1)::int::text
    || ' - ' || fake_city()
FROM generate_series(1, 80) AS s(i)
ON CONFLICT (document) DO NOTHING;

SELECT '   → ' || COUNT(*) || ' clientes no banco.' FROM customers;
