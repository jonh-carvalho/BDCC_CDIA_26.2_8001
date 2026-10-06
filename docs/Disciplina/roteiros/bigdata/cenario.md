O grande "pulo do gato" deste caso é apresentar o conceito de **"Post-Modern Data Stack"** ou **"Data Lakehouse Unificado"**. Em vez de manter 6 tecnologias diferentes (Postgres, Mongo, Neo4j, MinIO, Hadoop, Spark). O desafio será provar que um **PostgreSQL altamente tunado e estendido** pode atuar como o motor único (o "Cérebro") que orquestra e processa todos esses paradigmas, lendo diretamente do Object Storage (MinIO) e substituindo clusters Spark para cargas analíticas de médio/grande porte.

---

# Case de Exemplo: Food Delivery & IA – "FoodDash AI"

**Desafio Detalhado:** O grupo atuará no redesenho da arquitetura de dados de uma plataforma de delivery de alimentos (estilo iFood/Uber Eats) que sofre com a "explosão de microserviços e bancos de dados" (Database Sprawl). A equipe de arquitetura de dados recebeu a missão de consolidar o ecossistema em uma arquitetura **Data Lakehouse Unificada**, utilizando o **PostgreSQL como motor multimodelo central**, capaz de substituir silos de Documentos, Grafos, Vetores (IA) e processamento Big Data, mantendo o Object Storage (MinIO) apenas como repositório físico de baixo custo.

**O Problema:** A arquitetura legada é fragmentada. O catálogo de pratos está no MongoDB, as rotas de entregadores no Neo4j, as fotos dos restaurantes no S3, e os logs de telemetria GPS são processados por um cluster Hadoop/Spark caro e complexo de manter. Essa fragmentação gera latência nas *queries* de recomendação (que precisam cruzar grafo + documento + histórico), estouro no orçamento de nuvem e dificuldade extrema para a equipe de Ciência de Dados implementar buscas semânticas por IA.

**Requisitos Técnicos:**
*   **Consolidação Multimodelo:** Capacidade de armazenar e consultar dados transacionais (ACID), catálogos flexíveis (JSON), redes de rotas (Grafo) e embeddings de IA (Vetores) em um único motor de banco de dados.
*   **Data Lakehouse (Substituição de Hadoop/Spark):** Ingestão de telemetria GPS massiva em formato colunar (Parquet) no Object Storage (MinIO), com capacidade de o banco de dados consultar esses arquivos diretamente via SQL, eliminando a necessidade de um cluster Spark dedicado para relatórios analíticos.
*   **IA e Busca Semântica:** Suporte nativo a vetores para permitir buscas do tipo "quero um prato parecido com esta foto/descrição" (Recomendação por Embeddings).
*   **Disponibilidade e Performance:** SLA de 99,9% para a API de pedidos e latência inferior a 50ms para consultas de recomendação no app.
*   **Segurança:** Isolamento de dados de cartões de crédito e conformidade com a LGPD para dados de entregadores e clientes.

**Restrição Financeira:** Orçamento operacional de infraestrutura de dados máximo estipulado em **US$ 1.200,00/mês** (focando na drástica redução de custo ao eliminar clusters Spark e bancos NoSQL dedicados).

**Serviços e Tecnologias Sugeridas para o DAS (Data Architecture Stack):**
*   **Motor Central Unificado:** **PostgreSQL 16+** atuando como banco transacional, documento (`JSONB`), grafo (`Apache AGE`), vetorial (`pgvector`) e motor analítico.
*   **Armazenamento de Objetos (Data Lake Físico):** **MinIO** (S3-compatible) para armazenar arquivos Parquet (telemetria GPS), imagens de pratos e backups.
*   **Conector Lakehouse (O "Substituto do Spark"):** Uso de **Foreign Data Wrappers (FDW)** e extensões como **`pg_parquet`** ou **`aws_s3`** para permitir que o Postgres leia/escreva arquivos Parquet do MinIO diretamente via SQL, utilizando o *Parallel Query* do Postgres para processamento analítico distribuído.
*   **Séries Temporais:** Extensão **TimescaleDB** (ou particionamento nativo) no Postgres para otimizar a escrita de milhões de pontos de GPS por segundo.
*   **API de Dados:** **FastAPI (Python)** servindo como camada de orquestração, conectando-se exclusivamente ao Postgres para buscar dados relacionais, vetores e ler o Data Lake.
*   **Segurança:** Criptografia em repouso (TDE / `pgcrypto`) e em trânsito (TLS 1.3).

---

1.  **O Paradigma Relacional (Semanas 1-2):** Pedidos, carteiras digitais e usuários no Postgres nativo.
2.  **O Paradigma Documento (Semana 3):** Cardápios complexos e aninhados (ex: Pizza com borda, adicionais, tamanhos) usando `JSONB` e índices GIN.
3.  **O Paradigma de Grafos (Semana 4):** Rede de proximidade e logística (`Cliente -> Bairro -> Restaurante -> Entregador`) usando a extensão `Apache AGE` e Cypher.
4.  **O Paradigma Vetorial / IA (Semana 5):** Embeddings de pratos e avaliações para busca semântica usando `pgvector`.
5.  **O Paradigma de Objetos e Big Data (Semanas 6-8):** O conceito de Data Lake. O MinIO guardando o dado bruto em Parquet. O uso do Postgres + `pg_parquet` para substituir o *Spark SQL*, lendo o Data Lake e agregando milhões de rotas de GPS sem sair do ecossistema SQL.

---

### O Documento de Visão

Este arquivo foi detalhado de ponta a ponta seguindo o padrão oficial do RUP/UP para a fase de Inception, estruturado da seguinte forma:

#### 1. Introdução
Define o propósito do projeto (consolidação de dados para delivery), delimita seu escopo técnico (arquitetura Lakehouse Unificada) e esclarece terminologias cruciais da nova era de dados (Data Lakehouse, Multi-Model Database, Vector Search, FDW, Parquet).

#### 2. Posicionamento de Mercado
Descreve as dores reais do setor de food delivery sob uma tabela de problema/impacto estruturada:
*   *Problema:* Recomendações genéricas baseadas apenas em histórico de compras (SQL).
*   *Impacto:* Baixa conversão e abandono de carrinho.
*   *Solução Moderna:* Busca vetorial (IA) cruzada com grafos de afinidade, tudo orquestrado por um único banco, reduzindo o TCO (Custo Total de Propriedade) em até 60% comparado a arquiteturas baseadas em Hadoop/Spark + NoSQL.

#### 3. Mapeamento de Stakeholders
Identifica as expectativas exatas de:
*   **CTO / Diretoria:** Redução drástica da fatura da AWS/Cloud (eliminando clusters Spark e instâncias de Neo4j/Mongo).
*   **Cientistas de Dados:** Acesso rápido a vetores (IA) e grafos sem precisar mover dados entre 4 bancos diferentes.
*   **Engenheiros de Dados / DBAs:** Facilidade de backup, monitoramento e governança mantendo apenas *um* ecossistema de banco de dados (Postgres).
*   **Corpo Docente de TI:** Avaliar a capacidade do aluno de entender *trade-offs* (quando o Postgres aguenta tudo vs. quando ele colapsa).

#### 4. Visão Geral da Solução
Apresenta a perspectiva do **"Super-Postgres"**. A arquitetura abandona a ideia de "um banco para cada tipo de dado" e adota o Postgres como um *Hub de Computação e Catálogo* que lê dados transacionais de suas próprias tabelas e dados analíticos massivos (Big Data) diretamente dos arquivos Parquet no MinIO.

#### 5. Recursos do Produto (Arquitetura de Dados Unificada)
Fornece uma tabela robusta que mapeia cada extensão/recurso do Postgres com o seu respectivo papel de negócio:

| Recurso / Extensão do Postgres | Papel na Arquitetura | Justificativa Técnica e de Negócio |
| :--- | :--- | :--- |
| **Postgres Nativo (Tabelas/ACID)** | Relacional (OLTP) | Garante a integridade financeira de pedidos, cupons e saldos de carteira. |
| **JSONB + Índices GIN** | Documento (NoSQL) | Permite que o cardápio do restaurante mude de estrutura (ex: adicionar "sabores de pizza") sem *downtime* ou migração de schema. |
| **Apache AGE** | Grafo (NoSQL) | Modela a rede logística. Permite queries em Cypher para achar o entregador mais próximo em redes complexas de mão-dupla. |
| **pgvector** | Vetorial (IA) | Armazena *embeddings* de pratos. Permite busca semântica ("quero algo doce e gelado") convertendo texto em vetores matemáticos. |
| **MinIO (S3) + pg_parquet / FDW** | Objetos & Big Data (Lakehouse) | Substitui o HDFS e o Spark. O Postgres lê arquivos Parquet do MinIO como se fossem tabelas SQL, usando processamento paralelo para relatórios de milhões de rotas. |
| **TimescaleDB / Particionamento** | Séries Temporais | Otimiza a ingestão de telemetria GPS de milhares de entregadores em movimento. |

#### 6. Restrições do Projeto
*   **Limites de Orçamento:** Máximo de US$ 1.200,00/mês (exige uso intensivo de *compute* vertical no Postgres em vez de *scale-out* horizontal caro).
*   **Prazo Acadêmico:** 10 semanas (40 horas).
*   **Stack Tecnológica Obrigatória:** O motor de processamento analítico e transacional **deve** ser o PostgreSQL (com suas extensões). O armazenamento de objetos **deve** ser compatível com S3 (MinIO).
*   **Segurança Corporativa:** Dados de cartões devem ser ofuscados (`pgcrypto`); auditoria de logs de acesso obrigatória.

#### 7. Atributos de Qualidade (SLA e SLO)
*   **Disponibilidade:** SLA de 99,9% para a API de pedidos (garantido via replicação de streaming do Postgres).
*   **Performance Analítica:** Consultas em arquivos Parquet no MinIO (via `pg_parquet`) devem responder em até 2 segundos para dashboards de BI.
*   **Performance de IA:** Busca por similaridade de pratos (Vetores) com latência menor que 30ms.
*   **Custo-eficiência:** A arquitetura deve provar, ao final do curso, que é mais barata que uma arquitetura equivalente usando MongoDB + Neo4j + Spark.

#### 8. Histórico de Versões
Bloco de controle documental para o ciclo de vida do projeto acadêmico.

---

### O "Plot Twist" da Semana 9

Este documento é perfeito para curso porque ele vende um "sonho" na Semana 1: **A simplicidade do Banco Único.** Os alunos vão amar a ideia de usar apenas Postgres para tudo.

No entanto, na **Semana 9 (Padrões de Arquitetura)**, você deve introduzir o **Choque de Realidade**:
*   *"E se o FoodDash crescer para 50 milhões de pedidos por dia? O que acontece quando o arquivo Parquet no MinIO tiver 10 Terabytes e o Postgres, mesmo lendo via FDW, começar a ficar lento porque o CPU da máquina física satura?"*
*   É nesse momento que observamos a diferença entre **Data Lakehouse Consolidado** (o caso do FoodDash atual) e **Arquiteturas Distribuídas Nativas** (onde o Spark e o Cassandra voltam a ser necessários). 

Isso transforma os desenvolvedores em **Arquitetos de Dados Sêniores**, capazes de defender a consolidação para economizar custos, mas sabendo exatamente qual é o "teto de vidro" dessa abordagem.