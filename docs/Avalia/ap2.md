# AP2 - APRESENTAÇÃO no LABORATÓRIO { style="background-color:#FF0000; color:white;" }
### Apresentação destacando os principais pontos do Deploy/Aplicação - importante um slide  com os destaques e todos membros do grupo devem apresentar algum aspectos. { style="background-color:#FF6600; color:white;" }
### Prazo de Entrega: 11/06/2026 { style="background-color:#FFFF00; color:black;" }

**Envio pelo GitHub no mesmo repositório da AP1**

## Objetivo

Evoluir o projeto da AP1 (Django Rest + deploy em Elastic Beanstalk) para uma arquitetura em nuvem mais próxima de produção, com:

- Banco de dados gerenciado no **AWS RDS PostgreSQL**
- Armazenamento de arquivos de mídia dos produtos em **AWS S3**

## Introdução

Na AP1, você criou uma nova classe no projeto e publicou a API na AWS. Nesta AP2, o foco é tornar a solução mais robusta e escalável, separando responsabilidades:

- **Dados relacionais** no PostgreSQL (RDS)
- **Mídia estática dos produtos** (imagens/arquivos) no S3

Você deverá manter a API funcional, atualizar configurações de ambiente e comprovar o funcionamento fim a fim.

## Cenário

Você já possui um projeto Django Rest com as entidades da AP1 (incluindo `Produto` e a nova classe criada). Agora deve:

1. Evoluir para um pequeno e-commerce com carrinho de compras(Pedido, itens do Pedido, etc.), integrando o modelo de dados existente.
2. Configurar o projeto para usar **PostgreSQL no AWS RDS** em vez de SQLite.
3. Criar um **bucket S3** e configurar o Django para salvar e servir os arquivos de mídia dos produtos no bucket.
4. Validar a aplicação deployada no Elastic Beanstalk com as novas integrações.

## Requisitos Técnicos Mínimos

- Projeto Django Rest atualizado para PostgreSQL (RDS)
- Uso de variáveis de ambiente para dados sensíveis (host, usuário, senha, nome do banco, bucket, chaves)
- Upload de mídia de produto persistindo no S3
- Endpoints da API funcionando no ambiente AWS
- Django Admin funcionando com usuário administrador (root)

## Entregáveis

1. **Código-fonte no GitHub** com todas as alterações da AP2.
2. **README atualizado** com:
	- Arquitetura da solução (AP1 -> AP2)
	- Passo a passo para execução local
	- Passo a passo de deploy
	- Link da API em produção
	- Evidências de uso do RDS e do S3
3. **Documentação da AP2** (neste repositório) contendo:
	- Etapas realizadas
	- Principais decisões técnicas
	- Dificuldades e soluções
4. **Link da aplicação/API no ar**.

## Roteiro Sugerido (Incremental)

### Parte 1 - Preparação

1. Partir do projeto funcional da AP1.
2. Criar branch específica para AP2.
3. Garantir que o projeto rode localmente antes de iniciar as mudanças.

### Parte 2 - Banco AWS RDS PostgreSQL

1. Criar instância PostgreSQL no RDS.
2. Configurar segurança de rede (security groups) para permitir conexão da aplicação.
3. Ajustar `settings.py` para ler configurações do banco via variáveis de ambiente.
4. Executar migrações no novo banco.
5. Criar superusuário admin(root) no ambiente correto.

### Parte 3 - Bucket AWS S3 para mídia

1. Criar bucket S3 para arquivos de mídia dos produtos.
2. Configurar permissões/política conforme necessidade do projeto.
3. Integrar Django ao S3 para `MEDIA` (upload e URL).
4. Testar upload de imagem/arquivo em `Produto` e validar persistência no bucket.

### Parte 4 - Deploy e validação

1. Atualizar ambiente do Elastic Beanstalk com as novas variáveis.
2. Gerar pacote `app.zip` e realizar deploy.
3. Validar:
	- Endpoints GET/POST/PUT/DELETE
	- Acesso ao Django Admin
	- Upload e leitura de mídia no S3
	- Conectividade com RDS

### Parte 5 - Extensão opcional: JSONB com JSONField

Objetivo: aplicar um aspecto orientado a documento dentro do PostgreSQL para atributos variáveis do e-commerce.

1. Adicionar no modelo `Produto` (ou modelo relacionado) um campo `JSONField` para metadados dinâmicos.
2. Persistir esse campo no PostgreSQL (tipo `JSONB`).
3. Implementar ao menos 2 consultas filtrando dados dentro do JSON (ex.: marca, RAM, cor, tamanho, especificações técnicas).
4. Demonstrar um caso combinado de filtro relacional + JSON (ex.: categoria + atributo do JSON).

Exemplo de estrutura esperada para o campo JSON:

```json
{
	"marca": "Dell",
	"ram_gb": 16,
	"cor": "preto",
	"especificacoes": {
		"cpu": "i7",
		"armazenamento": "512GB SSD"
	}
}
```

Evidências desta parte opcional:

- Print de um registro salvo com JSONField preenchido.
- Print de ao menos 2 consultas com filtros no JSON.
- Breve explicação no README sobre quando usar campo relacional e quando usar JSONField.

## Evidências Obrigatórias

- URL pública da API funcionando
- Prints (ou GIFs) de:
  - Console RDS (instância ativa)
  - Console S3 (arquivos de mídia enviados)
  - Requisição da API criando/atualizando produto com mídia
  - Django Admin com login de administrador

## Critérios de Correção

- Configuração correta e funcional do RDS PostgreSQL
- Configuração correta e funcional do S3 para mídia
- Integração da API com banco e mídia em nuvem
- Uso adequado de variáveis de ambiente e boas práticas de configuração
- Deploy funcional no Elastic Beanstalk com `app.zip`
- Clareza da documentação técnica e reprodutibilidade

## Rubrica de Pontuação (10,0 pontos)

1. **Modelagem e integração com RDS PostgreSQL (2,5 pontos)**
	- 2,5: integração completa e funcional no ambiente AWS
	- 1,5: integração parcial, com inconsistências ou ajustes pendentes
	- 0,5: tentativa sem funcionamento estável

2. **Integração com S3 para mídia de produtos (2,5 pontos)**
	- 2,5: upload, armazenamento e acesso aos arquivos funcionando corretamente
	- 1,5: upload funcional com falhas de configuração/acesso
	- 0,5: tentativa sem fluxo completo

3. **Deploy e operação no Elastic Beanstalk (2,0 pontos)**
	- 2,0: aplicação publicada e operando com banco + mídia integrados
	- 1,0: aplicação no ar com funcionamento parcial
	- 0,5: deploy com erros recorrentes

4. **Boas práticas de configuração e segurança (1,5 ponto)**
	- 1,5: variáveis de ambiente e segredos tratados corretamente
	- 1,0: boas práticas aplicadas parcialmente
	- 0,5: configuração expõe riscos ou está incompleta

5. **Documentação e evidências (1,5 ponto)**
	- 1,5: documentação clara, reprodutível e com evidências completas
	- 1,0: documentação suficiente, mas com lacunas
	- 0,5: documentação incompleta

### Observações de Avaliação

- Trabalhos sem link da API em produção terão desconto mínimo de 2,0 pontos.
- Trabalhos sem evidências de RDS e S3 terão desconto mínimo de 2,0 pontos.
- A ausência de instruções para criação do usuário admin(root) poderá reduzir até 1,0 ponto.

## Diferenciais (Bônus)

- Organização de ambientes (`dev` e `prod`)
- Tratamento de erros de upload e validações adicionais
- Checklist de troubleshooting no README
- Script/comando de bootstrap para facilitar setup local
- Uso de `JSONField` no Django com consultas em `JSONB` no PostgreSQL (até +1,0 ponto)

## Referências

- [Documentação Django Rest Framework](https://www.django-rest-framework.org/)
- [Deploy Python/Django no AWS Elastic Beanstalk](https://docs.aws.amazon.com/pt_br/elasticbeanstalk/latest/dg/create-deploy-python-django.html)
- [Amazon RDS para PostgreSQL](https://docs.aws.amazon.com/pt_br/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html)
- [Amazon S3](https://docs.aws.amazon.com/pt_br/AmazonS3/latest/userguide/Welcome.html)
- [Roteiro de aula - Elastic Beanstalk](https://jonh-carvalho.github.io/BDCC_CDIA_26.1_8001/Disciplina/roteiros/07%20-%20eb/)

