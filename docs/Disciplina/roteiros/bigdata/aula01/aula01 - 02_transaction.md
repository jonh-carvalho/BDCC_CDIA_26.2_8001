## Script de Transações ACID — cenas separadas

Este conjunto de scripts demonstra como o PostgreSQL garante Atomicidade, Consistência, Isolamento e Durabilidade — e o que acontece quando uma operação falha.

## Estrutura

As cenas foram separadas em arquivos SQL para que cada etapa possa ser executada e avaliada individualmente:

| Cena | Arquivo | Objetivo | Resultado esperado |
| :--- | :--- | :--- | :--- |
| **1** | `02_transactions/01_setup.sql` | Preparar cliente, motorista, veículo e três entregas | Duas entregas pendentes e uma cancelada |
| **2** | `02_transactions/02_commit.sql` | Faturar uma entrega em uma transação bem-sucedida | Entrega `DELIVERED` e uma fatura persistida |
| **3** | `02_transactions/03_rollback_constraint.sql` | Tentar inserir uma fatura com valor negativo | A constraint rejeita a fatura e o `ROLLBACK` restaura a entrega para `PENDING` |
| **4** | `02_transactions/04_rollback_business_rule.sql` | Tentar faturar uma entrega cancelada | A regra de negócio gera erro; o `ROLLBACK` mantém a entrega `CANCELED` |
| **5** | `02_transactions/05_verification.sql` | Conferir o estado consolidado da demonstração | Três entregas: uma `DELIVERED`, uma `PENDING`, uma `CANCELED`; uma fatura |

Os scripts 2–5 localizam os registros da demonstração pelos dados de negócio, em vez de depender de variáveis `psql` criadas em outra sessão. Assim, cada arquivo pode ser executado em uma conexão separada, desde que a Cena 1 tenha sido preparada.

## Como executar

Execute os arquivos em ordem, a partir da pasta `aula01`. Cada comando abre uma sessão `psql` própria:

```bash
cat 02_transactions/01_setup.sql | docker exec -i swifttrack-pg psql -U postgres -d swifttrack_core
cat 02_transactions/02_commit.sql | docker exec -i swifttrack-pg psql -U postgres -d swifttrack_core
cat 02_transactions/03_rollback_constraint.sql | docker exec -i swifttrack-pg psql -U postgres -d swifttrack_core
cat 02_transactions/04_rollback_business_rule.sql | docker exec -i swifttrack-pg psql -U postgres -d swifttrack_core
cat 02_transactions/05_verification.sql | docker exec -i swifttrack-pg psql -U postgres -d swifttrack_core
```

A Cena 1 pode ser executada novamente para recriar os dados de demonstração e limpar as faturas associadas a eles. Para avaliar uma cena isoladamente, execute primeiro a Cena 1 e depois o arquivo desejado. As Cenas 3 e 4 exibem erros intencionais; deixe o `psql` continuar a execução para que o `ROLLBACK` seja executado.

## O que observar

### 1. Atomicidade em ação

Na Cena 3, o `UPDATE` da entrega acontece antes do `INSERT` da fatura. A constraint `chk_invoices_total_value` rejeita o valor negativo; o `ROLLBACK` desfaz também o `UPDATE`, e a entrega permanece `PENDING`.

### 2. Estado de erro da transação

Quando uma constraint ou regra gera erro dentro de um `BEGIN`, o PostgreSQL marca a transação como abortada. Nesse estado:

- Não é possível executar outros comandos nem confirmar a transação com `COMMIT`.
- É necessário executar `ROLLBACK` para encerrar a transação.

Se o `ROLLBACK` for removido da Cena 3, um comando posterior na mesma sessão mostrará:

```text
ERROR: current transaction is aborted, commands ignored until end of transaction block
```

### 3. Diferença entre `COMMIT` e `ROLLBACK`

| Comando | Efeito | Quando usar |
| :--- | :--- | :--- |
| `COMMIT` | Torna permanentes as alterações da transação | Quando todas as operações deram certo |
| `ROLLBACK` | Desfaz as alterações feitas desde o `BEGIN` | Quando alguma operação falhou |

### 4. Poder das constraints

As constraints `CHECK` criadas no script de schema são a última linha de defesa do banco: mesmo que a aplicação envie um valor negativo por engano, o PostgreSQL rejeita a gravação. Isso demonstra Consistência.

## Testes de variações

### Variação 1: mostrar o estado de erro

Peça aos alunos que removam temporariamente o `ROLLBACK` da Cena 3 e tentem executar outro comando na mesma transação. A sessão mostrará o erro de transação abortada.

### Variação 2: transação com `SAVEPOINT`

Use `SAVEPOINT` para desfazer apenas parte de uma transação:

```sql
BEGIN;
INSERT INTO invoices (...) VALUES (...);
SAVEPOINT sp_invoice;
INSERT INTO invoices (...) VALUES (...);  -- falha
ROLLBACK TO SAVEPOINT sp_invoice;         -- desfaz apenas o segundo INSERT
COMMIT;                                   -- mantém o primeiro INSERT
```

### Variação 3: simular concorrência

Abra dois terminais conectados ao mesmo banco. No Terminal 1, execute `BEGIN; UPDATE deliveries ...` sem `COMMIT`. No Terminal 2, tente consultar ou atualizar a mesma linha e observe o comportamento de isolamento.
