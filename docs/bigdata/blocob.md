# Prática 1: Modelo Colunar (55 min)

> Notebook de referência: [`bigdata/colunar/colunar.ipynb`](bigdata/colunar/colunar.ipynb)

---

## 1. Geração / Leitura dos Dados de Log (10 min)

**O que fazer:** abrir o notebook e executar a célula de geração de dados sintéticos.

```python
import pandas as pd
import numpy as np

data = {
    "UserID":      np.random.randint(1, 1000, 100_000),
    "Timestamp":   pd.date_range(start="2023-01-01", periods=100_000, freq="s"),
    "URLVisitada": [f"pagina_{i % 10}" for i in range(100_000)],
    "TempoSessao": np.random.randint(10, 300, 100_000),
}
df = pd.DataFrame(data)
df.to_csv("dados_logs.csv", index=False)
```

**Pontos a destacar para a turma:**

- 100 000 linhas × 4 colunas → representa um dia de log de um site de médio porte.
- Todos os campos têm o **mesmo tipo em todas as linhas** → dado estruturado.
- O CSV armazena **linha por linha**, incluindo os nomes das colunas repetidos implicitamente em cada registro.

---

## 2. Conversão CSV → Parquet (10 min)

```python
import pandas as pd

df = pd.read_csv("dados_logs.csv")
df.to_parquet("dados_logs.parquet", engine="pyarrow")
```

**O que observar imediatamente após a conversão:**

```python
import os

csv_kb     = os.path.getsize("dados_logs.csv")     / 1024
parquet_kb = os.path.getsize("dados_logs.parquet") / 1024

print(f"CSV:     {csv_kb:.1f} KB")
print(f"Parquet: {parquet_kb:.1f} KB")
print(f"Redução: {(1 - parquet_kb/csv_kb)*100:.1f}%")
```

> **Pergunta para a turma antes de rodar:** *"Parquet vai ser maior ou menor que o CSV? Por quê?"*  
> Registrar os palpites — revelar o resultado após a execução.

---

## 3. Consulta SQL com DuckDB (15 min)

```python
import duckdb

con = duckdb.connect()
con.execute("CREATE TABLE logs AS SELECT * FROM read_parquet('dados_logs.parquet')")

# Contagem de visitas por página
result = con.execute("""
    SELECT URLVisitada, COUNT(*) AS TotalVisitas
    FROM logs
    GROUP BY URLVisitada
    ORDER BY TotalVisitas DESC
""").fetchall()
print(result)

# Média de tempo de sessão por usuário
result2 = con.execute("""
    SELECT UserID, AVG(TempoSessao) AS MediaTempoSessao
    FROM logs
    GROUP BY UserID
    ORDER BY MediaTempoSessao DESC
""").fetchall()
print(result2)
```

**Destaques didáticos:**
- DuckDB executa SQL diretamente sobre o arquivo Parquet **sem servidor**.
- Internamente lê **apenas as colunas** pedidas no `SELECT` — as demais nem são descomprimidas.

---

## 4. Coleta de Evidências Objetivas (10 min)

### 4.1 Tamanho dos arquivos

| Arquivo | Tamanho (KB) |
|---|---|
| `dados_logs.csv` | *(preencher após executar)* |
| `dados_logs.parquet` | *(preencher após executar)* |

### 4.2 Tempo de leitura e consulta

```python
import time

# --- CSV ---
t0 = time.time()
df_csv = pd.read_csv("dados_logs.csv")
df_csv.groupby("URLVisitada").size().reset_index(name="TotalVisitas")
t_csv = time.time() - t0

# --- Parquet ---
t0 = time.time()
df_pq = pd.read_parquet("dados_logs.parquet")
df_pq.groupby("URLVisitada").size().reset_index(name="TotalVisitas")
t_parquet = time.time() - t0

print(f"CSV:     {t_csv:.4f}s")
print(f"Parquet: {t_parquet:.4f}s")
print(f"Speedup: {t_csv/t_parquet:.1f}×")
```

---

## 5. Discussão Guiada (8 min)

### Por que a leitura de colunas reduz I/O?

| Modelo | O que é lido para `AVG(TempoSessao)` |
|---|---|
| **Linha (CSV / row-store)** | **todas** as colunas de todas as linhas são lidas do disco, mesmo que só `TempoSessao` seja usada |
| **Colunar (Parquet)** | apenas os blocos da coluna `TempoSessao` são lidos; `UserID`, `Timestamp` e `URLVisitada` nem são tocados |

**Analogia:** imagine um livro onde cada capítulo agrupa **todos os dados de um tipo** (ex.: capítulo só de datas, capítulo só de durações). Para saber a média de duração, você lê um capítulo, não o livro inteiro.

### Em quais cenários o ganho cresce?

| Fator | Por que amplifica o ganho |
|---|---|
| Mais colunas na tabela | Proporção de colunas ignoradas aumenta |
| Colunas com alta cardinalidade | Compressão por dicionário é mais eficaz |
| Queries que agregam poucas colunas | I/O economizado é maior |
| Dataset em disco frio (SSD/HDD) | Latência de I/O domina; ler menos páginas é crítico |
| Dados na nuvem (S3, GCS) | Custo por byte trafegado — Parquet reduz egress |

### Quando o ganho é menor (ou nulo)?

- Queries do tipo `SELECT *` (todas as colunas são necessárias).
- Tabelas muito pequenas (cabe inteiro no cache de SO).
- Workloads com muitos UPDATEs pontuais — bancos colunares não são otimizados para escrita granular.

---

## 6. Entrega Rápida do Bloco (2 min)

Cada aluno preenche e entrega (chat, formulário ou quadro):

| Métrica | CSV | Parquet | Diferença (%) |
|---|---|---|---|
| Tamanho do arquivo (KB) | | | |
| Tempo de leitura/consulta (s) | | | |

> **Critério de conclusão:** tabela preenchida com valores reais e diferença percentual calculada.

---

## 7. Transição para o Bloco C

> *"Parquet é ótimo para logs estruturados. Mas e quando o perfil de cada usuário tem campos diferentes — um tem endereço, outro tem lista de pedidos, outro não tem nada disso? Como modelar isso sem desperdiçar colunas nulas?"*

➡ Próximo passo: abrir [`bigdata/orientadodocumento/odoc.ipynb`](bigdata/orientadodocumento/odoc.ipynb) e executar o Bloco C.
