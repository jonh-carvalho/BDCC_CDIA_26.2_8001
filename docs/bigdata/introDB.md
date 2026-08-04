--- 

marp: true
theme: default
paginate: true

---

## Introdução a Databases na AWS

- A AWS oferece serviços de dados para cenários **relacionais**, **NoSQL**, **documento**, **cache** e **analytics**
- Modelo **gerenciado**: menos operação manual e mais foco em produto
- Escalabilidade, segurança e alta disponibilidade como padrão

---

## S3 no Contexto de Dados

- **Amazon S3** é armazenamento de objetos (não é banco relacional)
- Ideal para:
  - **Data Lake**
  - backups e arquivamento
  - arquivos brutos para ETL/ELT
- Integra com Athena, Glue, Redshift e serviços de ML

---

## Amazon RDS (SQL Gerenciado)

- Bancos relacionais gerenciados: MySQL, PostgreSQL, MariaDB, Oracle, SQL Server
- Recursos principais:
  - backup automático
  - Multi-AZ
  - réplicas de leitura
  - patching e monitoramento
- Uso típico: sistemas transacionais com relações complexas

---

## Amazon Aurora

- Compatível com MySQL/PostgreSQL
- Maior desempenho e disponibilidade que RDS tradicional em muitos cenários
- Armazenamento distribuído e recuperação rápida
- Opções: provisionado e Serverless

---

## Amazon DynamoDB (NoSQL)

- Banco chave-valor/documento totalmente serverless
- Latência de milissegundos em alta escala
- Recursos:
  - auto scaling
  - Global Tables
  - TTL
  - Streams
- Uso típico: apps web/mobile, IoT, sessão, catálogo

---

## Amazon DocumentDB (Documento - compatível com MongoDB)

- Banco de documentos gerenciado pela AWS
- Compatível com APIs e drivers do MongoDB (em versões suportadas)
- Recursos:
  - alta disponibilidade com replicação em múltiplas AZs
  - backups contínuos
  - criptografia integrada
  - escalabilidade de leitura com réplicas
- Uso típico: catálogos, perfis de usuário, CMS, aplicações com JSON flexível

---

## Outros Serviços de Banco de Dados na AWS

- **Amazon ElastiCache (Redis/Memcached)**: cache em memória para baixa latência
- **Amazon Redshift**: data warehouse para analytics em grande escala
- **Amazon Neptune**: banco de grafos para relacionamentos complexos
- **Amazon Keyspaces (for Apache Cassandra)**: wide-column serverless
- **Amazon Timestream**: séries temporais (IoT, métricas, observabilidade)
- **Amazon QLDB**: ledger imutável com trilha de auditoria

---

## Como Escolher o Serviço

| Necessidade | Serviço AWS |
|---|---|
| Transações SQL e JOINs | RDS / Aurora |
| Escala massiva com baixa latência | DynamoDB |
| Dados JSON com modelo flexível | DocumentDB |
| Armazenar arquivos/dados brutos | S3 |
| Cache de alta performance | ElastiCache |
| Data warehouse analítico | Redshift |
| Consultas em relacionamentos de grafo | Neptune |
| Séries temporais | Timestream |

---

## Arquitetura de Referência (Exemplo)

- **Frontend/API** → grava dados transacionais no **RDS/Aurora**
- Perfil e catálogo em JSON → **DocumentDB**
- Eventos em tempo real → **DynamoDB**
- Logs e dados históricos → **S3**
- Cache de leitura → **ElastiCache**
- BI e analytics → **Redshift/Athena** sobre dados no S3

---

## Boas Práticas Iniciais

- Criptografia em repouso e trânsito
- IAM com princípio de menor privilégio
- Monitoramento com CloudWatch e alarmes
- Estratégia de backup e retenção
- Revisão contínua de custos (Cost Explorer)

---

## Próximos Passos

1. Criar bucket S3 para camada bruta
2. Subir um RDS (free tier) e testar conexão
3. Criar tabela no DynamoDB com chave primária adequada
4. Testar cluster DocumentDB para dados JSON
5. Monitorar métricas e custo por 1 semana
6. Ajustar arquitetura com base em uso real
