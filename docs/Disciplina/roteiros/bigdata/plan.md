## Cenário: SwiftTrack IoT — Logística Last-Mile

**Carga Horária:** 40 horas (10 semanas × 4h/semana)
**Público-Alvo:** Desenvolvedores, Cientistas de Dados, Engenheiros de Dados e Arquitetos de Software
**Metodologia:** Projeto Integrador Contínuo — os alunos constroem a arquitetura de dados do *SwiftTrack IoT* ao longo das 10 semanas.

---

## Fio Condutor do Curso

O *SwiftTrack IoT* é uma empresa de logística last-mile que monitora milhares de veículos em tempo real. Os alunos atuarão como **arquitetos de dados** responsáveis por desenhar a camada de persistência e processamento que sustenta:

- O **faturamento e gestão administrativa** (transacional, ACID);
- O **catálogo flexível de serviços e manifestos de entrega** (documento);
- A **rede de rotas, hubs e motoristas** (grafo);
- A **busca inteligente por endereços e padrões de entrega** (vetorial/IA);
- Os **comprovantes, fotos e documentos digitalizados** (objetos);
- A **telemetria GPS massiva dos veículos** (Big Data).

A filosofia arquitetural adotada é a do **"PostgreSQL Multimodelo + Data Lakehouse"**: um único motor de banco (Postgres + extensões) orquestrando todos os paradigmas, com o MinIO/S3 como repositório físico de objetos e arquivos analíticos (Parquet).

---

##  Cronograma Semanal Detalhado

### **MÓDULO 1 — A Base Transacional e a Flexibilidade (Semanas 1-3)**

#### **Semana 1: O Núcleo Relacional — Faturamento e Gestão**
**Tema:** PostgreSQL nativo, ACID, modelagem transacional
- **Teoria (1h):**
  - O paradigma relacional e o teorema ACID.
  - Modelagem ER para logística: clientes, motoristas, veículos, entregas, faturamento.
  - Quando o relacional é *obrigatório* (dinheiro, contratos, SLA).
- **Prática (3h):**
  - Setup do PostgreSQL 16 (Docker).
  - Criação do schema `swifttrack_core`: tabelas `customers`, `drivers`, `vehicles`, `deliveries`, `invoices`.
  - Constraints, chaves estrangeiras, índices B-Tree.
  - **Desafio:** Simular uma transação de faturamento com rollback em caso de falha.
- **Entregável:** Schema relacional rodando, com dados seed de 1.000 entregas.

---

#### **Semana 2: O Paradigma Documento — Catálogos Flexíveis**
**Tema:** JSONB, schema-on-read, índices GIN
- **Teoria (1h):**
  - Limites do relacional para dados semiestruturados.
  - Manifestos de entrega variáveis (um delivery de comida tem itens perecíveis; um de documentos tem peso volumétrico).
  - JSONB no Postgres: armazenamento binário, operadores `@>`, `?`, `?|`.
- **Prática (3h):**
  - Criação da tabela `delivery_manifests` com coluna `payload JSONB`.
  - Inserção de manifestos heterogêneos (food, documents, fragile, oversized).
  - Criação de índice GIN para buscas dentro do JSON.
  - **Desafio:** Query que encontra todas as entregas com item "frágil" acima de 5kg, extraído do JSON.
- **Entregável:** Catálogo flexível rodando com índices GIN otimizados.

---

#### **Semana 3: O Paradigma de Grafos — Rede Logística**
**Tema:** Apache AGE, Cypher, modelagem de redes
- **Teoria (1h):**
  - Por que JOINs em SQL são ineficientes para redes profundas (ex: "qual a rota mais curta entre Hub A e Cliente B passando por 5 hubs?").
  - Teoria dos grafos aplicada à logística: nós (hubs, motoristas, clientes), arestas (rotas, entregas realizadas).
  - Introdução à extensão Apache AGE.
- **Prática (3h):**
  - Instalação e configuração do Apache AGE.
  - Criação do grafo `logistics_network`.
  - Modelagem: `(Hub)-[:CONNECTS_TO {distance: km}]->(Hub)`, `(Driver)-[:ASSIGNED_TO]->(Vehicle)`, `(Driver)-[:DELIVERED]->(Customer)`.
  - **Desafio:** Query Cypher para encontrar todos os motoristas que entregaram em um raio de 3 hops de um hub específico.
- **Entregável:** Grafo logístico populado com queries Cypher funcionais.

---

### **MÓDULO 2 — IA, Objetos e o Lago de Dados (Semanas 4-6)**

#### **Semana 4: O Paradigma Vetorial — IA e Busca Semântica**
**Tema:** pgvector, embeddings, busca por similaridade
- **Teoria (1h):**
  - O que são embeddings e por que eles revolucionam a busca (endereços, descrições de incidentes, padrões de entrega).
  - pgvector: tipos `vector`, operadores de distância (L2, cosine, inner product).
  - Casos de uso em logística: busca fuzzy de endereços, detecção de anomalias em rotas.
- **Prática (3h):**
  - Instalação da extensão pgvector.
  - Criação da tabela `address_embeddings` com vetores de 1536 dimensões (simulando OpenAI embeddings).
  - Inserção de embeddings de endereços e descrições de incidentes.
  - **Desafio:** Query KNN (k-nearest neighbors) para encontrar os 5 endereços mais similares a um endereço digitado com erro.
  - Criação de índice IVFFlat para acelerar buscas.
- **Entregável:** Sistema de busca semântica de endereços rodando.

---

#### **Semana 5: O Paradigma de Objetos — Comprovantes e Mídias**
**Tema:** MinIO (S3-compatible), armazenamento de arquivos, CDN
- **Teoria (1h):**
  - Por que não armazenar arquivos em banco de dados (BLOBs são um anti-padrão em escala).
  - O conceito de Object Storage: buckets, objetos, metadados, políticas de ciclo de vida.
  - MinIO como alternativa open-source ao AWS S3.
  - Integração com CDN (CloudFront ou equivalente) para entrega de mídias.
- **Prática (3h):**
  - Setup do MinIO via Docker.
  - Criação de buckets: `swifttrack-proof-of-delivery`, `swifttrack-documents`, `swifttrack-static`.
  - Upload de fotos de comprovantes de entrega via `boto3` (Python).
  - Geração de URLs pré-assinadas para acesso temporário.
  - **Desafio:** Criar uma política de lifecycle que move arquivosolder que 90 dias para storage de baixo custo (simulado).
- **Entregável:** Data Lake de objetos rodando, com uploads e downloads funcionais.

---

#### **Semana 6: Big Data — Telemetria GPS e o Conceito de Data Lake**
**Tema:** Hadoop/HDFS, formatos colunares (Parquet, ORC), particionamento
- **Teoria (2h):**
  - O desafio da telemetria: milhares de veículos enviando GPS a cada 5 segundos = milhões de eventos/dia.
  - O ecossistema Hadoop: HDFS, NameNode/DataNode, blocos, replicação.
  - Por que o HDFS está sendo substituído por Object Storage (S3/MinIO) na era cloud.
  - Formatos de arquivo analíticos: Parquet (colunar, compressão, predicate pushdown) vs. CSV/JSON.
  - Estrutura de camadas do Data Lake: Bronze (raw), Silver (clean), Gold (aggregated).
- **Prática (2h):**
  - Geração de dados sintéticos de telemetria GPS (1 milhão de eventos).
  - Conversão de CSV para Parquet usando PyArrow.
  - Upload dos arquivos Parquet particionados no MinIO: `/telemetry/bronze/year=2026/month=10/day=03/`.
  - **Desafio:** Comparar o tempo de leitura de um filtro de data entre CSV e Parquet.
- **Entregável:** Data Lake estruturado em camadas com arquivos Parquet particionados.

---

### **MÓDULO 3 — Processamento, Ingestão e Integração (Semanas 7-9)**

#### **Semana 7: Processamento Distribuído — Spark ou pg_parquet?**
**Tema:** Apache Spark (PySpark) vs. leitura direta via Postgres FDW
- **Teoria (1h):**
  - Arquitetura do Spark: Driver, Executors, Cluster Manager, DAG, Lazy Evaluation.
  - Por que o MapReduce ficou para trás (processamento em memória).
  - A alternativa "Post-Modern": ler Parquet do MinIO diretamente via Postgres (pg_parquet, aws_s3 FDW).
  - Trade-offs: quando usar Spark (10TB+) vs. pg_parquet (100GB-1TB).
- **Prática (3h):**
  - **Opção A (Spark):** Setup do PySpark, leitura dos arquivos Parquet do MinIO, agregação de rotas (km rodados por motorista/dia).
  - **Opção B (pg_parquet):** Criação de Foreign Table no Postgres apontando para o MinIO, query SQL nativa sobre os dados do Data Lake.
  - **Desafio:** Calcular o "Tempo Médio de Entrega por Região" usando ambas as abordagens e comparar performance.
- **Entregável:** Pipeline de processamento analítico funcional (Spark ou pg_parquet).

---

#### **Semana 8: Ingestão Serverless — Alta Concorrência de Telemetria**
**Tema:** AWS Lambda + API Gateway (ou alternativas open-source)
- **Teoria (1h):**
  - O problema da ingestão de alta concorrência: 10.000 veículos enviando GPS simultaneamente.
  - Arquitetura orientada a eventos: API Gateway → Lambda → SQS/Kinesis → Data Lake.
  - Por que não escrever direto no Postgres (gargalo de conexões, custo de IOPS).
  - Padrão "Write-Ahead Log": ingerir rápido em fila/buffer, processar depois.
- **Prática (3h):**
  - Setup de uma função Lambda (Python) que recebe payloads GPS via API Gateway.
  - A função escreve os dados em um buffer (SQS ou Kinesis Data Streams simulado).
  - Um worker (ou Step Function) consome a fila e grava no Data Lake (MinIO/Parquet).
  - **Desafio:** Simular 1.000 requisições concorrentes e medir a latência de ingestão.
- **Entregável:** Pipeline de ingestão serverless funcional, com buffer e gravação assíncrona.

---

#### **Semana 9: Integração Arquitetural — O Lakehouse Unificado**
**Tema:** Padrões de arquitetura, medallion, governança
- **Teoria (1h):**
  - O conceito de Data Lakehouse: unir a governança do Data Warehouse com a escalabilidade do Data Lake.
  - Camadas Medallion: Bronze (raw), Silver (cleaned/conformed), Gold (business-level aggregates).
  - Delta Lake / Apache Iceberg: ACID em Data Lakes (conceito).
  - Catálogo de dados: como o Postgres atua como "cérebro" que orquestra tudo.
- **Prática (3h):**
  - Construção do pipeline completo do SwiftTrack:
    1.  Telemetria bruta → Bronze (MinIO/Parquet).
    2.  Limpeza e validação → Silver (MinIO/Parquet).
    3.  Agregação de KPIs (km rodados, tempo médio, entregas por região) → Gold (MinIO/Parquet).
    4.  Exposição dos dados Gold via Foreign Table no Postgres para dashboards.
  - **Desafio:** Criar um dashboard (Streamlit ou similar) que consome os dados Gold diretamente do Postgres.
- **Entregável:** Pipeline ETL completo com 3 camadas e dashboard funcional.

---

### **MÓDULO 4 — Consolidação e Projeto Final (Semana 10)**

#### **Semana 10: Projeto Final — "SwiftTrack IoT em Produção"**
**Tema:** Integração de todos os paradigmas, defesa arquitetural
- **Atividade (4h):**
  - Os alunos devem entregar um **documento de arquitetura** + **demonstração funcional** que integre:
    1.  **Relacional:** Faturamento de entregas no Postgres.
    2.  **Documento:** Manifestos flexíveis em JSONB.
    3.  **Grafo:** Rede de rotas e motoristas no Apache AGE.
    4.  **Vetorial:** Busca semântica de endereços com pgvector.
    5.  **Objetos:** Comprovantes de entrega no MinIO.
    6.  **Big Data:** Telemetria GPS processada no Data Lake (Parquet no MinIO, lida via pg_parquet ou Spark).
  - **Defesa Arquitetural:** Cada grupo apresenta suas escolhas e responde a perguntas do professor:
    - "Por que você usou JSONB aqui e não uma tabela relacional?"
    - "Em que momento o Postgres vai colapsar e você precisará migrar para Spark nativo?"
    - "Como você garante a consistência entre o grafo e o relacional?"
- **Entregável:** Arquitetura completa rodando + documento de defesa técnica.

---

## Stack Tecnológica Sugerida

| Camada | Tecnologia | Justificativa |
| :--- | :--- | :--- |
| **Motor Central** | PostgreSQL 16 + extensões (AGE, pgvector, pg_parquet) | Multimodelo: relacional + documento + grafo + vetorial + analítico |
| **Object Storage** | MinIO (S3-compatible) | Data Lake físico, comprovantes, backups |
| **Ingestão Serverless** | AWS Lambda + API Gateway (ou LocalStack para labs locais) | Alta concorrência de telemetria |
| **Processamento** | Apache Spark (PySpark) **ou** pg_parquet | Análise de telemetria massiva |
| **API Administrativa** | Django REST Framework (Python) | CRUD de faturamento, clientes, rotas |
| **Orquestração** | Docker Compose | Facilita o setup local de todos os serviços |
| **Monitoramento** | CloudWatch (AWS) ou Prometheus + Grafana (local) | Métricas de performance e custo |
