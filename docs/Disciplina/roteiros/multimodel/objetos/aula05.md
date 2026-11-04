Aqui está o **passo a passo detalhado e executável** para o **BLOCO 2 — Lab 1: Infraestrutura (35 min)**, formatado como um roteiro de laboratório pronto para ser distribuído aos alunos ou seguido pelo instrutor.

---

# 🛠️ ROTEIRO DE LABORATÓRIO: Semana 5, Bloco 2 (35 min)
**Objetivo:** Provisionar um ambiente de Object Storage (MinIO) seguro, com segregação de camadas (quente/fria) e simulação de CDN, preparando a base para o armazenamento de comprovantes de entrega.

---

## ⏱️ Passo 1: Preparação do Ambiente e Startup (10 min)

**1.1. Crie a estrutura de diretórios do projeto:**
```bash
mkdir -p swifttrack-week5/cdn
cd swifttrack-week5
```

**1.2. Crie o arquivo `docker-compose.week5.yml`:**
*(Copie e cole o conteúdo abaixo. Note que a versão do MinIO está travada para garantir a UI completa do Console em sala de aula).*
```yaml
services:
  minio-hot:
    image: minio/minio:RELEASE.2025-04-22T22-12-26Z
    container_name: swift-minio-hot
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: ${MINIO_ROOT_USER:-swiftadmin}
      MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD:-swiftsecret123}
    ports: ["9000:9000", "9001:9001"]
    volumes: ["minio_hot:/data"]
    healthcheck:
      test: ["CMD", "mc", "ready", "local"]
      interval: 5s
      retries: 10

  minio-cold: # Camada "Glacier" simulada para tiering
    image: minio/minio:RELEASE.2025-04-22T22-12-26Z
    container_name: swift-minio-cold
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: coldadmin
      MINIO_ROOT_PASSWORD: coldsecret123
    ports: ["9100:9000", "9101:9001"]
    volumes: ["minio_cold:/data"]

  cdn: # CDN simulada (edge cache)
    image: nginx:1.27-alpine
    ports: ["8080:80"]
    volumes:
      - ./cdn/nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - cdn_cache:/var/cache/nginx
    depends_on: [minio-hot]

volumes: 
  minio_hot: {}
  minio_cold: {}
  cdn_cache: {}
```

**1.3. Crie um `nginx.conf` básico para evitar falha no startup do container CDN:**
```bash
cat << 'EOF' > cdn/nginx.conf
server {
    listen 80;
    server_name localhost;
    location / {
        # Configuração base será refinada no Bloco 5
        proxy_pass http://minio-hot:9000;
        proxy_set_header Host $http_host;
    }
}
EOF
```

**1.4. Inicie os serviços:**
```bash
docker compose -f docker-compose.week5.yml up -d
```
> 💡 **Dica do instrutor:** Peça aos alunos para rodar `docker compose ps` e aguardar até que o `swift-minio-hot` mostre `healthy` (leva ~10-15 segundos).

---

## ⏱️ Passo 2: Configuração do MinIO Client (`mc`) e Buckets (10 min)

**2.1. Configure o alias do MinIO Client (`mc`) dentro do container:**
```bash
docker exec -it swift-minio-hot mc alias set local http://localhost:9000 swiftadmin swiftsecret123
```
*(Confirmação esperada: `Added 'local' successfully.`)*

**2.2. Crie os buckets segregados por domínio de negócio:**
```bash
for b in swifttrack-proof-of-delivery swifttrack-documents swifttrack-static; do
  docker exec -it swift-minio-hot mc mb --ignore-existing local/$b
done
```
> 🧠 **Conceito rápido:** Explique que buckets são containers de *primeiro nível*. Não se cria "pasta" aqui, a hierarquia vem na chave do objeto.

---

## ⏱️ Passo 3: Segurança e Versionamento (10 min)

**3.1. Habilite o versionamento (Obrigatório para Tiering e Prova de Entrega):**
```bash
docker exec -it swift-minio-hot mc version enable local/swifttrack-proof-of-delivery
docker exec -it swift-minio-hot mc version enable local/swifttrack-documents
```
*(Confirmação esperada: `Versioning is enabled on 'local/swifttrack-proof-of-delivery'`)*

**3.2. Defina as políticas de acesso anônimo (Regra de Ouro: Privado por padrão):**
```bash
# Bucket de ativos públicos (logos, JS do app)
docker exec -it swift-minio-hot mc anonymous set download local/swifttrack-static

# Bucket de comprovantes: acesso estritamente NEGADO ao público
docker exec -it swift-minio-hot mc anonymous set none local/swifttrack-proof-of-delivery
```

---

## ⏱️ Passo 4: Checkpoint 1 (Obrigatório) e Discussão (5 min)

**4.1. Teste de invasão/segurança:**
Peça a todos os alunos para executarem este comando no terminal do host:
```bash
curl -I http://localhost:9000/swifttrack-proof-of-delivery/qualquer.jpg
```

**4.2. Validação:**
- ✅ **Sucesso:** O retorno deve ser `HTTP/1.1 403 Forbidden` (ou `404 Not Found` se o bucket existir mas a política estiver correta, dependendo da versão do MinIO, mas **nunca** 200 OK sem autenticação).
- ❌ **Falha Crítica:** Se retornar `200 OK`, o aluno **não avança**. Pare a turma.

**4.3. Discussão Socrática (se houver falha ou para reforço):**
> *"Se este endpoint retornasse 200, o que um bot de scraping poderia fazer com os comprovantes de entrega da SwiftTrack? Cite pelo menos dois artigos da LGPD que estariam sendo violados."*
*(Respostas esperadas: Violação de confidencialidade, exposição de endereço e assinatura do cliente, violação dos princípios de segurança e minimização da LGPD).*

---

## ⏱️ Passo 5: Convenção de Chaves (Decisão de Projeto)

Apresente no quadro ou compartilhe na tela os padrões de nomenclatura de chaves (keys) que serão usados no código (Bloco 3):

```text
pod/{ano}/{mes}/{dia}/{delivery_id}/{uuid}.jpg
doc/{tipo}/{ano}/{mes}/{cnpj_cliente}/{uuid}.pdf
static/{app}/{versao}/{arquivo}
```

**🗣️ Justificativa para a plenária (Instrutor):**
> "Atenção: o prefixo temporal (`{ano}/{mes}/{dia}`) **não é organizacional** (não é para 'ficar bonito' no console). Ele é **operacional**. 
> 1. Ele habilita *partition pruning* (corte de partição) quando consultarmos esses metadados via Athena/Trino na Semana 7.
> 2. Ele permite que as regras de ILM (Information Lifecycle Management) filtrem e movam para o storage frio apenas objetos de um prefixo específico, sem varrer o bucket inteiro.
> Esta é a semente do layout Bronze/Silver/Gold do nosso Data Lakehouse."

---

### 🚦 Checklist de Conclusão do Bloco 2
- [ ] Containers `minio-hot`, `minio-cold` e `cdn` rodando (`docker ps`).
- [ ] 3 buckets criados e visíveis no Console (`http://localhost:9001`).
- [ ] Versionamento ativo nos buckets `proof-of-delivery` e `documents`.
- [ ] `curl` no bucket de comprovantes retorna erro de permissão (403/404).
- [ ] Alunos compreenderam a lógica do prefixo temporal nas chaves.

*Próximo passo: Avançar para o **Bloco 3 (Lab 2: boto3)** para realizar o upload programático e geração de URLs pré-assinadas.*