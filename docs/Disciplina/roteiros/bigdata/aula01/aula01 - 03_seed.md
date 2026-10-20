# Script de Seed — 1.000 entregas

Este material demonstra a geração de dados sintéticos em escala usando SQL nativo do PostgreSQL. O script foi organizado em **sete cenas executáveis**, cada uma em um arquivo SQL separado, para facilitar a execução e a avaliação dos resultados.

## Estratégia de geração

| Tabela | Quantidade esperada | Objetivo |
| :--- | :---: | :--- |
| `customers` | 80 | Base de clientes B2B |
| `drivers` | 25 | Motoristas da frota |
| `vehicles` | 12 | Veículos da frota |
| `deliveries` | 1.000 | Meta principal da aula |
| `invoices` | Aproximadamente 700 | Faturas de entregas concluídas |

A distribuição de status das entregas é probabilística, com proporções aproximadas de 70% `DELIVERED`, 15% `IN_TRANSIT`, 10% `PENDING` e 5% `CANCELED`. Portanto, as contagens variam a cada execução.

## Cenas

Os arquivos estão na pasta [`03_seed/`](./03_seed/).

| Cena | Arquivo | O que faz | Pré-requisito |
| :---: | :--- | :--- | :--- |
| 1 | [`01_customers.sql`](./03_seed/01_customers.sql) | Cria as funções auxiliares e insere clientes | Schema `swifttrack_core` criado |
| 2 | [`02_drivers.sql`](./03_seed/02_drivers.sql) | Insere motoristas | Schema criado |
| 3 | [`03_vehicles.sql`](./03_seed/03_vehicles.sql) | Insere veículos | Schema criado |
| 4 | [`04_deliveries.sql`](./03_seed/04_deliveries.sql) | Insere 1.000 entregas | Cenas 1, 2 e 3 |
| 5 | [`05_invoices.sql`](./03_seed/05_invoices.sql) | Emite faturas para entregas concluídas | Cena 4 |
| 6 | [`06_cleanup.sql`](./03_seed/06_cleanup.sql) | Remove as funções auxiliares | Cenas 1 e 4 |
| 7 | [`07_validation.sql`](./03_seed/07_validation.sql) | Mostra contagens, status, resumo financeiro e integridade referencial | Cenas 1 a 5 |

Todos os arquivos definem o `search_path` no início. Assim, cada cena pode ser executada em uma conexão `psql` separada, sem depender de configurações da sessão anterior. As cenas 2 e 3 podem ser executadas em qualquer ordem depois da criação do schema; a ordem indicada facilita a avaliação.

## Como executar

Execute a partir da pasta `aula01`, com o container `swifttrack-pg` em funcionamento e o schema criado pelo roteiro [`aula01 - 01.md`](./aula01%20-%2001.md). Os exemplos abaixo usam Bash:

```bash
cat 03_seed/01_customers.sql | docker exec -i swifttrack-pg psql -U postgres -d swifttrack_core
cat 03_seed/02_drivers.sql | docker exec -i swifttrack-pg psql -U postgres -d swifttrack_core
cat 03_seed/03_vehicles.sql | docker exec -i swifttrack-pg psql -U postgres -d swifttrack_core
cat 03_seed/04_deliveries.sql | docker exec -i swifttrack-pg psql -U postgres -d swifttrack_core
cat 03_seed/05_invoices.sql | docker exec -i swifttrack-pg psql -U postgres -d swifttrack_core
cat 03_seed/06_cleanup.sql | docker exec -i swifttrack-pg psql -U postgres -d swifttrack_core
cat 03_seed/07_validation.sql | docker exec -i swifttrack-pg psql -U postgres -d swifttrack_core
```

Para avaliar uma cena isoladamente, prepare o banco e execute também as cenas listadas como pré-requisito na tabela. A cena 7 pode ser repetida para consultar os resultados sem alterar os dados.

## Resultados para avaliar

Na saída da cena 7, confira:

- `deliveries`: 1.000 registros.
- `customers`, `drivers` e `vehicles`: 80, 25 e 12 registros, respectivamente, em uma execução inicial.
- `invoices`: uma fatura para cada entrega `DELIVERED` que possua `delivered_at`; a quantidade varia conforme a geração aleatória.
- As quatro contagens de chaves estrangeiras órfãs: todas devem ser zero.
- A distribuição de status: próxima das proporções definidas, mas não necessariamente igual a cada execução.

As contagens de clientes, motoristas, veículos e faturas também incluem quaisquer registros que já existiam. Para comparar com os valores esperados, use um banco limpo ou recrie o schema conforme as instruções do roteiro de criação do schema antes de executar as cenas.

## Técnicas didáticas exploradas

| Técnica | Uso |
| :--- | :--- |
| `generate_series(1, N)` | Gera as linhas para inserção em lote |
| `random()`, `floor()` e arrays | Sorteiam valores e simulam distribuições |
| `NOW() - INTERVAL` | Distribui datas no passado |
| Subconsultas para chaves estrangeiras | Escolhem IDs existentes e preservam a integridade |
| `CREATE OR REPLACE FUNCTION` | Encapsula a geração de dados auxiliares |

## Problemas comuns

| Erro | Causa provável | O que verificar |
| :--- | :--- | :--- |
| `duplicate key value violates unique constraint` | As cenas de inserção foram executadas mais de uma vez | Recrie o schema em um ambiente de teste ou limpe os dados antes de repetir |
| `null value in column "customer_id" violates not-null constraint` | A tabela de clientes está vazia | Execute a cena 1 e confirme que o schema contém os dados |
| `violates check constraint` | Um valor inserido não respeita uma regra do schema | Confira o schema e os dados retornados pela cena correspondente |

## Checklist de entrega

- [ ] Executar as sete cenas na ordem indicada.
- [ ] Confirmar 1.000 entregas no relatório de validação.
- [ ] Confirmar que as contagens de FKs órfãs são zero.
- [ ] Registrar ou entregar a saída da cena 7.
- [ ] (Bônus) Explicar uma técnica de geração usada nos scripts.

## Gancho para a Semana 2

Com o seed executado, a base pode ser usada para investigar o desempenho de consultas, índices e junções em conjuntos de dados maiores.
