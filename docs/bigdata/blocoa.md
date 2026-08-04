# Abertura e Alinhamento

---

## 1. O Problema Central


> *"Se você precisasse guardar bilhões de registros de log de servidor e também o perfil completo de cada usuário com campos variáveis, usaria o mesmo banco de dados para os dois casos?"*

Cargas de trabalho distintas impõem requisitos diferentes:

| Característica | Carga transacional | Carga analítica |
|---|---|---|
| Operação dominante | INSERT / UPDATE por linha | SELECT agregando colunas |
| Volume típico de leitura | Poucas linhas por vez | Milhões/bilhões de linhas |
| Latência esperada | Milissegundos | Segundos a minutos (aceitável) |
| Exemplo de sistema | E-commerce, ERP, API REST | BI, Data Lake, ML pipeline |

**Conclusão do slide:** não existe um modelo único ideal — a escolha depende do padrão de acesso ao dado.

---

## 2. Conceitos-Chave (definições rápidas)

### 2.1 OLTP vs OLAP

**OLTP — Online Transaction Processing**
- Foco em **escrever e ler registros individuais** com alta frequência.
- Schema rígido, normalizado (3FN).
- Banco típico: PostgreSQL, MySQL, Oracle.
- Exemplo prático desta aula: cadastro de usuário → `dados_usuarios.json` / TinyDB.

**OLAP — Online Analytical Processing**
- Foco em **agregar grandes volumes** de dados para análise.
- Schema desnormalizado (star schema, wide table) ou sem schema fixo.
- Banco típico: DuckDB, Redshift, BigQuery, ClickHouse.
- Exemplo prático desta aula: logs de servidor → `dados_logs.parquet` / DuckDB.

> **Regra de bolso:** se a pergunta é *"qual o status do pedido 42?"* → OLTP.  
> Se a pergunta é *"qual a média de erros por hora no último mês?"* → OLAP.

---

### 2.2 Tipos de Dado

| Tipo | Definição | Exemplo nesta aula |
|---|---|---|
| **Estruturado** | Schema fixo, tabular, todos os campos iguais para cada registro | `dados_logs.csv` / `dados_logs.parquet` |
| **Semi-estruturado** | Schema flexível, chaves presentes mas não obrigatórias, formato chave-valor ou hierárquico | `dados_usuarios.json` |
| **Aninhado** | Campos que contêm outros objetos ou arrays dentro de si | Campo `enderecos` ou `pedidos` dentro de um documento de usuário |

**Por que isso importa?**
- Dados estruturados → armazenamento colunar (Parquet) é mais eficiente.
- Dados semi-estruturados e aninhados → bancos orientados a documentos (MongoDB, TinyDB) evitam JOINs custosos e suportam variação de schema.

---

## 3. Mapa da Pasta `bigdata`

```
bigdata/
├── roteiroplanodeaula.md          ← roteiro completo da aula
│
├── colunar/                       ← Bloco B (modelo colunar / OLAP)
│   ├── colunar.ipynb              ← notebook principal: CSV → Parquet → DuckDB
│   ├── dados_logs.csv             ← dataset de logs em formato linha
│   └── dados_logs.parquet         ← mesmo dataset em formato colunar
│
└── orientadodocumento/            ← Bloco C (modelo orientado a documentos / OLTP-flexível)
    ├── odoc.ipynb                 ← notebook principal: TinyDB / MongoDB
    ├── dados_usuarios.json        ← documentos semi-estruturados de usuários
    └── usuarios_tinydb.json       ← banco TinyDB persistido em arquivo
```

### O que cada pasta demonstra

| Pasta | Modelo | Tecnologia | Tipo de dado |
|---|---|---|---|
| `colunar/` | Colunar | Parquet + DuckDB | Estruturado |
| `orientadodocumento/` | Documento | TinyDB / MongoDB | Semi-estruturado / Aninhado |

---

## 4. Transição para o Bloco B


> *"Quantas vezes mais rápido vocês acham que o Parquet será em relação ao CSV para uma consulta de média em 1 milhão de linhas?"*

Registrar os palpites da turma no quadro — revisitar ao final do Bloco B com os números reais obtidos no notebook.

➡ Próximo passo: abrir [`bigdata/colunar/colunar.ipynb`](bigdata/colunar/colunar.ipynb) e executar o Bloco B.
