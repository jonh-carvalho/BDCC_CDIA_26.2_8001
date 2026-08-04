
# Criação de MySQL no AWS Aurora

## 1. Criar Cluster Aurora

1. Acesse o console AWS RDS
2. Clique em "Create database"
4. Escolha "MySQL" 
5. Configure:
    - Free tier
    - **DB cluster identifier**: `aula-cluster`
    - **Master username**: `admin`
    - **Master password**: defina uma senha
6. Clique em "Create database"

## 2. Aguardar Disponibilidade

- Espere o status mudar para "Available" (5-10 minutos)
- Copie o **endpoint** da instância

## 3. Conectar ao Banco (por onde?)

Você pode conectar de **3 lugares**:

1. **AWS CloudShell** (mais fácil, sem instalar nada)


> Antes de conectar, no **Security Group** do Aurora, libere a porta **3306** para a origem correta (EC2, CloudShell ou seu IP).

```bash
mysql -h aula-cluster.cuj2q0ya6uad.us-east-1.rds.amazonaws.com -u admin -p
```

Se o comando não funcionar, instale o cliente MySQL:

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y mysql-client

# Amazon Linux
sudo dnf install -y mariadb105
```

## 4. Criar Tabela

```sql
CREATE DATABASE meubanco;
USE meubanco;

CREATE TABLE usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100),
  email VARCHAR(100)
);
```

## 5. Operações Básicas

**Inserir dados:**
```sql
INSERT INTO usuarios (nome, email) VALUES ('João', 'joao@email.com');
```

**Consultar dados:**
```sql
SELECT * FROM usuarios;
```

**Atualizar:**
```sql
UPDATE usuarios SET nome='João Silva' WHERE id=1;
```

**Deletar:**
```sql
DELETE FROM usuarios WHERE id=1;
```

2. **EC2 na mesma VPC** do Aurora (recomendado para laboratório)
  
   **Passo a passo (via EC2):**
   1. Acesse a instância:
      ```bash
      ssh -i sua-chave.pem ec2-user@IP_PUBLICO_DA_EC2
      ```
      > Em Ubuntu, o usuário costuma ser `ubuntu`.

   2. Instale o cliente MySQL (se necessário):
      ```bash
      # Amazon Linux
      sudo dnf install -y mariadb105
      ```

   3. Conecte no Aurora usando o endpoint do cluster:
      ```bash
      mysql -h <endpoint-do-aurora> -u admin -p
      ```

   4. Teste a conexão:
      ```sql
      SHOW DATABASES;
      ```

   > Se falhar, valide o Security Group: porta **3306** liberada da EC2 para o Aurora.
  


3. **Seu computador local** (se liberar acesso no Security Group)
  
   **Passo a passo (via computador local):**
   1. Instale o cliente MySQL:
      ```bash
      # Amazon Linux
      sudo dnf install -y mariadb105

      # macOS (Homebrew)
      brew install mysql-client

      # Windows (winget)
      winget install Oracle.MySQL
      ```

   2. No Aurora, confirme:
      - **Public access** habilitado (se for acesso direto pela internet)
      - **Security Group** com porta **3306** liberada para **seu IP público** (`x.x.x.x/32`)

   3. Conecte usando o endpoint do cluster:
      ```bash
      mysql -h <endpoint-do-aurora> -P 3306 -u admin -p
      ```

   4. Teste:
      ```sql
      SHOW DATABASES;
      ```

   > Se não conectar, valide VPC/Subnet, rota/NACL e se o endpoint está correto.