# 📘 Roteiro Introdutório ao MinIO
**Pré-requisito zero para a Semana 5 — Leitura de 15 minutos**

> **Objetivo:** você vai sair deste roteiro tendo rodado um Object Storage na sua máquina, criado um bucket, subido um arquivo e baixado de volta — duas vezes: pelo Console Web e pela linha de comando.

---

## 1. O que é MinIO em 30 segundos

MinIO é um servidor de **Object Storage** compatível com a API do Amazon S3.

Pense nele como um "pendrive gigante na rede", mas com três diferenças cruciais em relação a um sistema de arquivos comum:

| Sistema de arquivos | Object Storage (MinIO/S3) |
|---|---|
| Pastas e subpastas hierárquicas | **Namespace plano** — "pastas" são ilusão do console |
| Você edita arquivos no lugar | Objetos são **imutáveis** (sobrescrever = nova versão) |
| Montado no seu SO | Acessado via **HTTP/REST** (API) |

**Por que isso importa para a SwiftTrack?**
Porque fotos de comprovante, PDFs de manifesto e arquivos estáticos do app **não são dados relacionais**. Eles são objetos — grandes, imutáveis, acessados por URL. Colocar isso dentro do Postgres (como BLOB) é um anti-padrão em escala. O MinIO resolve isso.

---

## 2. Glossário mínimo (5 termos)

Decore estes. Eles voltam em todos os labs:

| Termo | O que é | Analogia |
|---|---|---|
| **Bucket** | Container de primeiro nível (obrigatório) | Uma "pasta raiz" |
| **Object** | O arquivo em si (bytes + metadados) | O arquivo |
| **Key** | O "nome" do objeto dentro do bucket (`pod/2026/11/10/foto.jpg`) | O caminho |
| **Metadata** | Pares chave-valor anexados ao objeto (`driver-id=102`) | Etiquetas |
| **Version ID** | Identificador de uma versão específica do objeto | Histórico do Google Docs |

---

## 3. Rodando o MinIO em 1 comando

### 3.1. Pré-requisito
Ter o Docker instalado e rodando.

### 3.2. Subir o servidor
Copie e cole no terminal:

docker run -d  -p 9000:9000 -p 9001:9001 --name minio -e "MINIO_ROOT_USER=minioadmin" -e "MINIO_ROOT_PASSWORD=minioadmin" -v ~/minio/data:/data quay.io/minio/minio server /data --console-address ":9001"


```bash
# Inicia o MinIO em segundo plano, com console web e credenciais de administrador.
docker run -d --name minio-intro -p 9000:9000 -p 9001:9001 -e MINIO_ROOT_USER=admin -e MINIO_ROOT_PASSWORD=admin12345 cgr.dev/chainguard/minio:latest server /data --console-address ":9001"
```


**O que acabou de acontecer:**
- `-p 9000:9000` → porta da **API** (onde o `boto3` vai bater)
- `-p 9001:9001` → porta do **Console Web** (interface gráfica)
- `MINIO_ROOT_USER/PASSWORD` → credenciais de administrador
- `--console-address ":9001"` → diz ao MinIO para servir a UI na porta 9001

### 3.3. Verificar se está saudável
```bash
docker logs minio-intro --tail 5
```
Você deve ver algo como:
```
API: http://172.17.0.2:9000
Console: http://172.17.0.2:9001
```

---

## 4. Primeira interação: pelo Console Web (5 min)

### 4.1. Acessar
Abra no navegador: **http://localhost:9001**

Login:
- Usuário: `admin`
- Senha: `admin12345`

### 4.2. Criar seu primeiro bucket
1. Clique em **"Buckets"** no menu lateral
2. Clique em **"Create Bucket"**
3. Nome: `meu-primeiro-bucket`
4. Deixe as outras opções em padrão
5. Clique em **"Create Bucket"**

✅ **Checkpoint:** o bucket aparece na lista.

### 4.3. Subir um arquivo
1. Crie um arquivo de texto qualquer no seu computador:
   ```bash
   echo "Olá SwiftTrack!" > teste.txt
   ```
2. No Console, clique no bucket `meu-primeiro-bucket`
3. Clique em **"Upload"** → **"Upload file"**
4. Selecione `teste.txt`
5. Clique em **"Start"**

✅ **Checkpoint:** o arquivo aparece na lista com tamanho, data e um ícone de "olho" para preview.

### 4.4. Baixar o arquivo
1. Clique no nome `teste.txt`
2. Clique no botão **"Download"** (ícone de seta para baixo)

✅ **Checkpoint:** o arquivo é baixado para sua pasta de downloads com o conteúdo original.

### 4.5. Explorar metadados
1. Ainda na tela do arquivo, clique na aba **"Metadata"**
2. Você verá metadados padrão como `Content-Type: text/plain`

> 💡 **Insight:** note que não existe "pasta". O arquivo está **diretamente** no bucket. Se você subir `pasta1/pasta2/foto.jpg`, isso é apenas uma **key** com barras no nome — não uma estrutura de diretórios real.

---

## 5. Segunda interação: pela linha de comando com `mc` (5 min)

O Console é ótimo para explorar. Mas em produção, você vai usar o **MinIO Client (`mc`)** — uma CLI equivalente ao `aws s3`.

### 5.1. Instalar o `mc`

**Linux:**
```bash
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
sudo mv mc /usr/local/bin/
```

**macOS:**
```bash
brew install minio/stable/mc
```

**Windows (PowerShell):**
```powershell
Invoke-WebRequest -Uri https://dl.min.io/client/mc/release/windows-amd64/mc.exe -OutFile mc.exe
```

**Alternativa sem instalação (via Docker):**
```bash
docker exec -it minio-intro mc --help
```

### 5.2. Configurar o alias
```bash
mc alias set meu-minio http://localhost:9000 admin admin12345
```
Saída esperada:
```
Added 'meu-minio' successfully.
```

### 5.3. Listar buckets
```bash
mc ls meu-minio
```
Saída esperada:
```
[2026-11-10 14:23:45 UTC] 0B STANDARD meu-primeiro-bucket/
```

### 5.4. Subir um arquivo via CLI
```bash
echo "Upload via CLI" > cli-teste.txt
mc cp cli-teste.txt meu-minio/meu-primeiro-bucket/
```
Saída esperada:
```
cli-teste.txt: 15 B / 15 B ┃████████████████████████████████████████┃ 100.00% 1.23 MiB/s 0s
```

### 5.5. Listar objetos do bucket
```bash
mc ls meu-minio/meu-primeiro-bucket/
```
Saída esperada:
```
[2026-11-10 14:30:12 UTC] 15B STANDARD cli-teste.txt
[2026-11-10 14:25:33 UTC] 16B STANDARD teste.txt
```

✅ **Checkpoint:** os dois arquivos (um subido pelo Console, outro pela CLI) aparecem juntos.

### 5.6. Baixar um arquivo via CLI
```bash
mc cp meu-minio/meu-primeiro-bucket/teste.txt ./baixado.txt
cat baixado.txt
```
Saída esperada:
```
Olá SwiftTrack!
```

### 5.7. Ver metadados de um objeto
```bash
mc stat meu-minio/meu-primeiro-bucket/teste.txt
```
Você verá: tamanho, ETag, Content-Type, data de modificação.

---

## 6. O experimento da "chave com barras"

Este é o conceito mais importante para a Semana 5. Vamos provar que "pastas" não existem.

### 6.1. Subir um arquivo com "caminho"
```bash
echo "foto do motorista" > foto.jpg
mc cp foto.jpg meu-minio/meu-primeiro-bucket/pod/2026/11/10/foto.jpg
```

### 6.2. Listar
```bash
mc ls meu-minio/meu-primeiro-bucket/
```
Saída:
```
[2026-11-10 14:35:00 UTC] 20B STANDARD pod/2026/11/10/foto.jpg
```

Note: **não há subpastas**. Há **um único objeto** cuja key é `pod/2026/11/10/foto.jpg`. As barras são apenas caracteres do nome.

### 6.3. Por que isso importa?
- No Console, parece uma hierarquia de pastas → ilusão visual
- Na API, é uma string plana → filtro por prefixo é rápido
- Nas regras de lifecycle (Semana 5, Bloco 5), você move **por prefixo**, não por pasta

> 🧠 **Analogia mental:** pense em Object Storage como um **dicionário gigante** (chave → valor), não como uma árvore de diretórios.

---

## 7. Limpando tudo

Quando terminar de explorar:

```bash
# Remover objetos
mc rm --recursive meu-minio/meu-primeiro-bucket/

# Remover bucket
mc rb meu-minio/meu-primeiro-bucket/

# Parar o container
docker stop minio-intro
docker rm minio-intro
```

---

## 8. Checklist de conclusão

Antes de avançar para o **Lab 1 da Semana 5**, você deve conseguir responder "sim" para todas:

- [ ] Sei rodar o MinIO com um `docker run`
- [ ] Sei acessar o Console Web e criar um bucket
- [ ] Sei subir e baixar arquivos pelo Console
- [ ] Sei instalar/configurar o `mc` e criar um alias
- [ ] Sei subir, listar, baixar e inspecionar metadados via `mc`
- [ ] Entendo que "pastas" não existem — só keys com barras
- [ ] Consigo explicar a diferença entre porta 9000 (API) e 9001 (Console)

---

## 9. O que vem a seguir

No **Lab 1** da Semana 5, você vai:
- Subir **dois** MinIOs (hot + cold) simulando camadas de storage
- Criar **três buckets segregados** por domínio de negócio
- Configurar **versionamento** e **políticas de acesso**
- Subir uma **CDN simulada** com Nginx

No **Lab 2**, você vai:
- Usar `boto3` (Python) para fazer upload programático
- Calcular checksum SHA-256 e anexar metadados
- Gerar **URLs pré-assinadas** para upload/download sem credenciais

No **Lab 3**, você vai:
- Conectar o MinIO ao PostgreSQL
- Implementar o contrato de metadados entre banco e storage
- Construir o "Reaper" que limpa arquivos órfãos

**Tudo isso parte dos conceitos que você acabou de praticar.** Se este roteiro ficou claro, os Labs vão fluir. Se alguma coisa ficou confusa, releia a seção correspondente antes de avançar.

---

### 🎯 Dúvidas frequentes antecipadas

**P: Posso usar a última versão do MinIO em vez da `RELEASE.2025-04-22`?**
R: Pode, mas versões recentes removeram muitas funções do Console Web comunitário. A versão fixada garante a UI completa para os labs.

**P: Por que duas portas (9000 e 9001)?**
R: Separação de responsabilidades. A porta 9000 é a API (usada por aplicações). A porta 9001 é a UI administrativa (usada por humanos). Em produção, a UI fica atrás de VPN/rede interna.

**P: O MinIO substitui o Postgres?**
R: Não. Eles trabalham juntos. Postgres guarda a **verdade sobre o objeto** (metadados, status, integridade). MinIO guarda **o objeto em si** (bytes). A Semana 5 é sobre como fazer os dois conversarem.

**P: Posso usar o AWS S3 em vez do MinIO?**
R: Sim, a API é a mesma. O `boto3` que você vai escrever no Lab 2 funciona nos dois. MinIO é a escolha didática (grátis, local, rápido) e operacional (on-premise, edge, híbrido).

---

**Próximo passo:** abra o **Lab 1 da Semana 5** e siga o passo a passo. Você já tem a base. 🚀