Perfeito! A substituição por **Python/Django REST Framework** e o foco na **AWS** são escolhas excelentes, pois alinham a disciplina com um dos ecossistemas mais populares e demandados do mercado para Ciência de Dados.

Segue o plano de ensino reelaborado com essas especificações.

---

### **PLANO DE ENSINO (REELABORADO - PYTHON/DJANGO & AWS)**

| **Curso:** Ciência de Dados e Inteligência Artificial | **Disciplina:** Big Data e Cloud Computing |
|---|---|
| **Carga Horária:** 80h | **Período:** 5º Período (recomendado) |
| **Professor:** [Nome do Professor] | **Ano/Semestre:** [Ano/Semestre] |

---

### **1. EMENTA**

Introdução à Computação em Nuvem com foco em **Amazon Web Services (AWS)** e ecossistema de Big Data. Modelos de serviço em nuvem (IaaS, PaaS, SaaS) e sua implementação na AWS. Principais serviços AWS: computação (**EC2**), armazenamento (**S3**), banco de dados (**RDS**), API Gateway e computação serverless (**AWS Lambda**). Criação e deploy de uma **API REST com Django REST Framework** em ambiente AWS. Fundamentos e modelos de bancos de dados para Big Data (colunar, tabular e documental) com foco em serviços AWS. Introdução aos serviços gerenciados de Big Data e processamento distribuído na AWS (**EMR**, **Athena**, **Glue**).

### **2. OBJETIVOS GERAIS**

Capacitar o aluno a compreender os fundamentos da computação em nuvem **AWS** e do ecossistema de Big Data, habilitando-o a projetar, implementar e implantar soluções escaláveis que utilizem serviços AWS para processamento e armazenamento de grandes volumes de dados, utilizando **Python e Django** como principal ferramenta de desenvolvimento.

### **3. OBJETIVOS ESPECÍFICOS**

- Distinguir os modelos de serviço (IaaS, PaaS, SaaS) e implantação (pública, privada, híbrida) em nuvem, com exemplos práticos na **AWS**.
- Conhecer e utilizar os principais serviços da AWS: **EC2** (computação), **S3** (armazenamento), **RDS** (banco de dados relacional), **Lambda** (serverless) e **API Gateway**.
- Compreender os fundamentos e a arquitetura de sistemas de Big Data.
- Diferenciar modelos de banco de dados para Big Data: colunar (**Redshift**), orientado a documentos (**DynamoDB**, **MongoDB Atlas**) e tabular.
- Implementar uma aplicação back-end (API Rest) utilizando **Python, Django e Django REST Framework (DRF)**.
- Realizar o deploy automatizado de uma aplicação Django em um ambiente AWS (**Elastic Beanstalk**) ou manual em instância **EC2**.
- Explorar serviços gerenciados de Big Data na AWS para processamento e análise de dados: **Amazon EMR** (Hadoop/Spark), **AWS Glue** (ETL e catalogação) e **Amazon Athena** (consultas SQL em S3).

### **4. CONTEÚDO PROGRAMÁTICO**

O conteúdo está organizado em 20 semanas, com 4 horas de aula por semana (total de 80h).

| **Semana** | **Módulo** | **Tópicos** | **Atividades/Práticas (Foco em AWS & Python)** |
|---|---|---|---|
| **1** | **Fundamentos de Cloud Computing** | Introdução à Computação em Nuvem: definição, vantagens, modelos de implantação. CapEx vs. OpEx. Visão geral da **AWS**: regiões, zonas de disponibilidade, modelos de responsabilidade compartilhada. | Discussão sobre casos de uso. **Laboratório:** Criar uma conta na **AWS Free Tier** e explorar o Console de Gerenciamento. |
| **2** | **Modelos de Serviço em Nuvem** | Detalhamento de IaaS, PaaS e SaaS com exemplos na AWS: **EC2** (IaaS), **Elastic Beanstalk** (PaaS) e serviços como **Amazon WorkSpaces** (SaaS). | **Laboratório:** Provisionar uma instância **Amazon EC2** (Linux) e conectar-se via SSH. |
| **3** | **Principais Serviços AWS** | Computação (**EC2**, Auto Scaling), Armazenamento (**Amazon S3** - buckets, objetos, versões) e Redes (**VPC**, subnets, Security Groups). | **Laboratório:** Criar um bucket **S3** para armazenar e servir arquivos estáticos. Configurar um **Security Group** para a instância EC2. |
| **4** | **Introdução ao Big Data** | Definição de Big Data: 5 V's. Desafios do processamento de dados em larga escala. O papel da nuvem no Big Data. | Estudo de caso: Análise de um problema real de Big Data (ex: logs de servidor, dados de IoT) e como a AWS poderia solucioná-lo. |
| **5** | **Ecossistema de Big Data** | Visão geral do ecossistema Hadoop: HDFS e MapReduce. Introdução ao Apache Spark (processamento em memória). **Amazon EMR** como serviço gerenciado para clusters Hadoop/Spark. | **Laboratório:** Usar o **Amazon EMR** para subir um cluster Spark e executar um job simples de contagem de palavras. |
| **6** | **Bancos de Dados para Big Data I** | Modelos de bancos de dados NoSQL: Orientado a Documentos (MongoDB). Características, casos de uso. Opções na AWS: **Amazon DocumentDB** (compatível com MongoDB) e MongoDB Atlas. | **Laboratório:** Criar um cluster **MongoDB Atlas** (nível gratuito) e realizar operações CRUD básicas a partir de um script Python (`pymongo`). |
| **7** | **Bancos de Dados para Big Data II** | Modelos NoSQL: Colunar (**Amazon Redshift** - Data Warehouse) e Chave-Valor (**Amazon DynamoDB** - banco NoSQL gerenciado). Bancos de dados tabulares. | **Laboratório:** Criar uma tabela no **Amazon DynamoDB** e interagir com ela usando **boto3** (biblioteca Python da AWS). |
| **8** | **AVALIAÇÃO 1 (P1)** | Prova teórico-prática abordando os conteúdos das semanas 1 a 7. | **Avaliação Individual** |
| **9** | **APIs com Python e Django** | Conceitos de API Rest. Revisão de Python e introdução ao **Django**. Criação de um projeto Django. Conceitos de models, views e URLs. | **Laboratório:** Criar um projeto Django básico e configurar o ambiente virtual. |
| **10** | **Django REST Framework (DRF)** | Introdução ao **Django REST Framework**. Serializers, ViewSets e Routers. Criação de uma API simples com operações de CRUD. | **Laboratório:** Implementar uma API para gerenciamento de uma entidade (ex: Produtos, Livros) usando DRF, com suporte a banco de dados SQLite. |
| **11** | **Serverless com AWS Lambda** | Conceito de computação serverless. Criação de funções **AWS Lambda** em Python. Gatilhos (triggers) para execução (ex: upload no S3, chamada HTTP). | **Laboratório:** Criar uma função **Lambda** em Python que é executada automaticamente quando um arquivo é enviado para um bucket **S3** (ex: redimensionar uma imagem). |
| **12** | **API Gateway e Integração** | Uso do **Amazon API Gateway** para criar, publicar e gerenciar APIs. Integração do API Gateway com funções **Lambda** para criar um back-end serverless. | **Laboratório:** Criar uma API REST no **API Gateway** que invoca uma função **Lambda** para processar requisições. Testar a API. |
| **13** | **Bancos de Dados Gerenciados na AWS** | Aprofundamento no **Amazon RDS** (Relational Database Service) para bancos relacionais (PostgreSQL, MySQL). Como conectar uma aplicação Django ao RDS. | **Laboratório:** Provisionar uma instância **Amazon RDS** (PostgreSQL) e configurar uma aplicação Django local para se conectar a ela. |
| **14** | **Deploy de Aplicações Django na AWS** | Estratégias de deploy. Opção 1 (Gerenciada): **AWS Elastic Beanstalk** para Django. Opção 2 (Manual): Configuração de um servidor web (Nginx + Gunicorn) em uma instância **EC2**. | **Laboratório:** Realizar o deploy da API Django desenvolvida nas semanas 9-10 no **AWS Elastic Beanstalk**. |
| **15** | **Serviços Analíticos AWS** | **Amazon Athena:** Consultas SQL interativas diretamente em dados armazenados no **S3**. **AWS Glue:** Catálogo de dados e jobs de ETL (Extract, Transform, Load) serverless. | **Laboratório:** Usar o **Amazon Athena** para consultar um arquivo CSV ou JSON armazenado em um bucket **S3**, sem precisar de um banco de dados tradicional. |
| **16** | **Orientação para o Projeto Final** | Definição dos grupos e escopo do projeto final: **Implementação de uma solução completa**. Exemplo: Uma API Django que coleta dados, armazena no S3/RDS, processa com Lambda/Glue e disponibiliza resultados via API Gateway, com todo o deploy na AWS. | Discussão de ideias e definição dos requisitos do projeto com os grupos. |
| **17** | **Acompanhamento de Projetos** | Sessão de mentoria e acompanhamento do desenvolvimento dos projetos finais. Esclarecimento de dúvidas técnicas sobre Django, DRF e serviços AWS. | Desenvolvimento do projeto. |
| **18** | **Entrega e Apresentação de Projetos** | Apresentação e defesa dos projetos finais pelos grupos. Demonstração da solução implementada na **AWS**. | **Avaliação de Projeto** |
| **19** | **AVALIAÇÃO 2 (P2)** | Prova abordando os conteúdos das semanas 9 a 15, com foco no desenvolvimento de API com Django e serviços AWS. | **Avaliação Individual** |
| **20** | **AVALIAÇÃO SUPLEMENTAR (SUB)** | Prova abrangendo todo o conteúdo do semestre para alunos que não atingiram a média. | **Avaliação Individual (Recuperação)** |

### **5. PROCEDIMENTOS METODOLÓGICOS**

A disciplina adotará uma abordagem **teórico-prática**, com forte ênfase em atividades de laboratório e desenvolvimento de projetos. As aulas serão expositivas-dialogadas para introdução dos conceitos, seguidas de atividades práticas em laboratório de informática, onde os alunos poderão aplicar os conceitos utilizando a **AWS**.

**Recursos:**
- Laboratório de informática com acesso à internet.
- Contas de estudante no programa **AWS Educate**.
- Softwares: Python, Django, DRF, Postman/Insomnia, Git, AWS CLI.
- Ambiente Virtual de Aprendizagem (AVA) para disponibilização de materiais, entregas de trabalhos e fóruns.

### **6. AVALIAÇÃO DA APRENDIZAGEM**

A avaliação será contínua e processual, composta por três notas principais, conforme o calendário acadêmico:

- **Avaliação 1 (P1) - Peso:** [Inserir peso, ex: 30%]
    - Prova individual teórico-prática sobre os fundamentos de Cloud e Big Data.

- **Avaliação 2 (P2) - Peso:** [Inserir peso, ex: 40%]
    - Projeto prático em grupo (desenvolvimento e apresentação) e/ou prova individual sobre desenvolvimento de API com Django e serviços AWS.

- **Trabalhos e Atividades Práticas (T) - Peso:** [Inserir peso, ex: 30%]
    - Entrega de atividades e relatórios dos laboratórios realizados ao longo do semestre.

**Média Final = (P1 * PesoP1) + (P2 * PesoP2) + (T * PesoT)**

- **Avaliação Suplementar (SUB):** Prova individual abrangendo todo o conteúdo do semestre para os alunos que não alcançarem a média final para aprovação (geralmente 6,0). A nota da SUB substituirá a menor nota entre P1 e P2 para o recálculo da média final.

### **7. BIBLIOGRAFIA**

#### **Bibliografia Básica:**

- **SANTOS, R.R.** Fundamentos de Big Data. Porto Alegre: Sagah Educação, 2021.
- **PEREIRA, M.A.** Framework de Big Data. Porto Alegre: Sagah Educação, 2019.
- **SILVA, A.; TANURE, A.; FREITAS, A.; MUNIZ, A.** Jornada Cloud Native: do zero ao avançado somando conceitos e práticas. Rio de Janeiro: Brasport, 2023. (Abrange conceitos aplicáveis à AWS)

#### **Bibliografia Complementar:**

- **WITTIG, Andreas; WITTIG, Michael.** Amazon Web Services in Action. Manning Publications, 2018. (Leitura essencial para aprofundamento na AWS).
- **LACERDA, P.S.P.** Programação em Big Data com R. Porto Alegre: Sagah Educação, 2021.
- **GOMES, E.** Inteligência Competitiva em Tempos de Big Data. Rio de Janeiro: Alta Books, 2017.
- **FREEMAN, E.** DevOps para Leigos. Rio de Janeiro: Alta Books, 2021.
- **DATE, C.** Introdução a Sistemas de Banco de Dados. Rio de Janeiro: GEN LTC, 2004. (Para fundamentos de BD, base para os modelos NoSQL).
- **Documentação Oficial do Django e Django REST Framework.** (disponível online)