-- =====================================================================
-- SWIFTTRACK CORE - Cena 6: limpeza das funções auxiliares
-- Execute após as cenas que geram dados.
-- =====================================================================

SET search_path TO swifttrack_core;

DROP FUNCTION IF EXISTS fake_cpf();
DROP FUNCTION IF EXISTS fake_cnpj();
DROP FUNCTION IF EXISTS fake_plate();
DROP FUNCTION IF EXISTS fake_city();

SELECT 'Funções auxiliares removidas.' AS mensagem;
