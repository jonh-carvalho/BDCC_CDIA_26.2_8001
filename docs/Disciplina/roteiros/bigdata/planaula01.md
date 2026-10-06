## Aula 01: O Núcleo Relacional — Faturamento e Gestão

**Carga Horária Total:** 4 horas (1h Teoria + 3h Prática)
**Público-alvo:** Estudantes de Engenharia de Dados, Ciência de Dados ou Backend.
**Pré-requisitos:** Conhecimentos básicos de SQL (SELECT, INSERT) e noções de Docker.

---

### 1. Objetivos de Aprendizagem

**Geral:**
Compreender, modelar e implementar um banco de dados relacional transacional robusto para um cenário de logística, garantindo integridade de dados e consistência financeira.

**Específicos:**
1. Explicar o Teorema ACID e sua importância crítica para sistemas financeiros.
2. Modelar um esquema ER para o domínio de logística (SwiftTrack).
3. Provisionar e configurar o PostgreSQL 16 utilizando Docker.
4. Aplicar constraints, chaves estrangeiras e índices B-Tree para garantir performance e integridade.
5. Manipular transações explícitas (`BEGIN`, `COMMIT`, `ROLLBACK`) simulando falhas.
6. Gerar e carregar dados sintéticos (Seed) em escala (1.000 registros).

---

### 2. Recursos e Ferramentas Necessárias
*   **Hardware/Software:** Computador com Docker Desktop instalado.
*   **Clientes SQL:** DBeaver, pgAdmin 4 ou terminal `psql`.
*   **Linguagens auxiliares (Opcional para Seed):** Python (com biblioteca `Faker`) ou scripts SQL nativos com `generate_series`.
*   **Material do Instrutor:** Repositório Git com o *docker-compose.yml* base e o *script de seed* (como fallback).

---

### 3. Cronograma e Metodologia (Passo a Passo)

#### BLOCO 1: TEORIA *Foco: Fundamentação e Modelagem de Negócio*

*   **O Paradigma Relacional e o Teorema ACID**
    *   Breve histórico (Edgar F. Codd) e o conceito de tuplas/relações.
    *   **ACID na prática:**
        *   *Atomicity:* "Tudo ou nada" (ex: debitar conta e creditar outra).
        *   *Consistency:* O banco vai de um estado válido para outro (regras de negócio).
        *   *Isolation:* Transações concorrentes não interferem umas nas outras.
        *   *Durability:* O que foi commitado, sobrevive a quedas de energia (WAL - Write Ahead Log).
*   **Modelagem ER para Logística (Cenário SwiftTrack)**
    *   Mapeamento das entidades: `customers` (quem paga), `drivers` (quem executa), `vehicles` (frota), `deliveries` (o evento), `invoices` (o faturamento).
    *   Cardinalidade e Relacionamentos (1:N, N:N).
*   **Quando o Relacional é OBRIGATÓRIO?**
    *   Discussão: Por que não usar NoSQL para faturamento? 
        -  Consistência forte é mandatória para evitar *double billing*.
        -  Transações financeiras exigem rollback e atomicidade.
        -  Auditoria e rastreabilidade são requisitos legais.
        -  Cenários de alta concorrência e integridade de dados.
    *   Conceitos de Auditoria, SLA, Contratos e Dinheiro. O custo do *data loss* ou *double billing*.
        -   Exemplo de falha: Se uma entrega é faturada duas vezes, o cliente pode processar a empresa judicialmente.
        -   Exemplo de falha: Se uma entrega é faturada e o motorista não recebe, ele pode entrar com ação trabalhista.
        -  Exemplo de falha: Se o sistema não consegue garantir que uma transação foi concluída, a empresa perde credibilidade.
        - Exemplo de falha: Se o sistema não consegue garantir que uma transação foi concluída, a empresa perde credibilidade.
*   **Dúvidas e Transição para a Prática**
    *   Apresentação do diagrama ER final que será codificado.

#### BLOCO 2: PRÁTICA - Setup e DDL 

*Foco: Infraestrutura e Estrutura de Dados*

*   **Setup do PostgreSQL 16 (Docker)**
    *   Subindo o container:
      ```bash
      docker run --name swifttrack-pg -e POSTGRES_PASSWORD=secret -e POSTGRES_DB=swifttrack_core -p 5432:5432 -d postgres:16
      ```
    *   Conexão via DBeaver/pgAdmin e criação do schema `swifttrack_core`.
*   **Criação do Schema (DDL) e Constraints**
    *   Criação das tabelas com tipos de dados adequados (ex: `NUMERIC(10,2)` para valores financeiros, `TIMESTAMPTZ` para datas).
    *   **Desafio de Constraints:**
        *   `CHECK (total_value > 0)` na tabela de faturas.
        *   `CHECK (status IN ('PENDING', 'IN_TRANSIT', 'DELIVERED', 'CANCELED'))` em entregas.
    *   **Índices B-Tree:** Criação de índices nas Foreign Keys e em colunas de filtro frequente (ex: `idx_deliveries_status`, `idx_invoices_customer_id`). *Explicar brevemente como o B-Tree funciona.*

#### BLOCO 3: PRÁTICA - Transações e o Desafio ACID
*Foco: Manipulação de Dados e Resiliência*

*   **Inserção de Dados e Relacionamentos**
    *   Inserir manualmente um Cliente, um Motorista, um Veículo e uma Entrega.
*   **O GRANDE DESAFIO: Simulação de Faturamento com Rollback**
    *   *Cenário:* O sistema de billing tentará criar uma Fatura e mudar o status da Entrega para "FATURADO".
    *   *Execução Bem-Sucedida:*
        ```sql
        BEGIN;
        INSERT INTO invoices (delivery_id, customer_id, total_value, status) VALUES (1, 1, 150.00, 'ISSUED');
        UPDATE deliveries SET status = 'BILLED' WHERE id = 1;
        COMMIT;
        ```
    *   *Simulação de Falha (O Pulo do Gato):* Tentar faturar uma entrega que já foi cancelada ou com valor negativo, forçando o banco a rejeitar a constraint.
        ```sql
        BEGIN;
        INSERT INTO invoices (delivery_id, customer_id, total_value, status) VALUES (2, 1, -50.00, 'ISSUED'); -- Vai falhar no CHECK!
        UPDATE deliveries SET status = 'BILLED' WHERE id = 2;
        -- O aluno deve perceber que precisa dar ROLLBACK; para não deixar a transação pendente/bloqueada.
        ROLLBACK;
        ```

#### BLOCO 4: PRÁTICA - Seed de Dados e Encerramento
*Foco: Escala, Automação e Entregável*

*   **Geração do Seed (1.000 Entregas)**
    *   Os alunos devem criar um script para popular o banco.
    *   *Sugestão de abordagem nativa (SQL):* Usar `generate_series` e `random()` para criar clientes, motoristas e as 1.000 entregas cruzando as tabelas.
    *   *Sugestão de abordagem Python:* Script usando `psycopg2` e `Faker` para gerar dados realistas (nomes, placas, endereços).
*   **Validação, Dúvidas Finais e Submissão**
    *   Verificar se os índices estão sendo usados (introduzir o comando `EXPLAIN ANALYZE SELECT...`).
    *   Explicar como o entregável deve ser formatado e submetido.
