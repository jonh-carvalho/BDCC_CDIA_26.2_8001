--- 
id: aws
title: AWS
---  

### Tutorial Prático: Criando e Explorando sua Conta AWS (Sem Cartão de Crédito)

**Objetivo:** Ao final deste tutorial, o aluno terá criado uma conta no **AWS Educate** (que não requer cartão de crédito), feito login no Console de Gerenciamento da AWS e explorado os principais serviços, compreendendo a função de cada elemento da interface.

**Pré-requisitos:**
- Um computador com acesso à internet e um navegador web (Chrome, Firefox, Edge).
- Um endereço de e-mail válido (de preferência, o e-mail institucional da sua faculdade).



### **Parte 1**: Criando sua Conta no AWS Educate (Acesso sem Cartão de Crédito)

O AWS Educate é um programa global da Amazon que oferece créditos e acesso a serviços AWS para estudantes e educadores, sem a necessidade de um cartão de crédito. É a porta de entrada ideal para quem está começando.

**Passo 1:** Acesse o Portal do AWS Educate

1.  Abra o navegador e acesse o site oficial: **[https://aws.amazon.com/pt/education/awseducate/](https://aws.amazon.com/pt/education/awseducate/)** .
2.  Você verá uma página explicando o programa. Procure e clique no botão **"Junte-se ao AWS Educate"** (geralmente localizado no canto superior direito ou no centro da página).

**Passo 2:** Escolha seu Perfil e Preencha os Dados

1.  Na página de inscrição, selecione a opção **"Estudante"** .
2.  Você será redirecionado para um formulário de cadastro. Preencha todas as informações solicitadas com atenção:

    - **Informações de conta da AWS:** Crie um endereço de e-mail (use seu e-mail pessoal ou institucional) e uma senha forte. Esta será sua conta de login.
    - **Informações pessoais:** Preencha seu nome, sobrenome, país e data de nascimento.
    - **Informações educacionais:** Esta parte é crucial. Selecione seu país e o tipo de instituição (ex: "Universidade"). Comece a digitar o nome da sua faculdade e selecione-a na lista. Se não aparecer, você pode clicar em "Can't find your school?" e preencher manualmente o nome, cidade e site da instituição.
    - Selecione seu nível de estudo e a área de formação (ex: "Ciência da Computação").

3.\  Após preencher tudo, leia e aceite os termos e condições.

**Passo 3:** Verifique seu E-mail e Complete o Cadastro

1.  Após enviar o formulário, a AWS enviará um e-mail de verificação para o endereço que você forneceu.
2.  Acesse sua caixa de entrada. Se não encontrar o e-mail em alguns minutos, verifique a pasta de **Spam** ou **Lixo Eletrônico**.
3.  Abra o e-mail e clique no link de confirmação. Isso pode levar você de volta ao site do AWS Educate para finalizar algumas etapas de perfil.
4.  Complete as informações adicionais se solicitado.
5.  **Aguarde a aprovação.** O processo de aprovação do AWS Educate pode levar de algumas horas a alguns dias. Você receberá um e-mail de confirmação quando sua conta estiver ativa e pronta para uso.


### **Parte 2**: Fazendo Login e Conhecendo o Console

Com sua conta aprovada, você terá acesso ao Console de Gerenciamento da AWS, a interface web principal para interagir com os serviços .

**Passo 1: Acesse o Console**

1.  Vá para o site da AWS: **[https://aws.amazon.com/pt/](https://aws.amazon.com/pt/)**
2.  Clique no botão **"Fazer login no Console"** , localizado no canto superior direito.
3.  Selecione a opção **"Fazer login com a conta root do AWS Educate"** (ou uma opção similar que mencione o AWS Educate).
4.  Insira o e-mail e a senha que você criou no cadastro do AWS Educate.

**Passo 2: Tour Guiado pelo Console**

Ao fazer login, você verá o **Console Inicial (Console Home)** . Vamos explorar seus principais componentes, que são essenciais para a navegação .

*   **① Acesso aos Serviços:** No topo da página, há uma barra de menus. Clique no nome **"Serviços"** para abrir um menu suspenso com todos os serviços AWS, organizados por categoria (Computação, Armazenamento, Banco de Dados, etc.). Para encontrar um serviço rapidamente, você pode usar a **barra de pesquisa** ao lado do menu "Serviços". Digite, por exemplo, "EC2" ou "S3" e clique no resultado para ser levado diretamente à página daquele serviço .
*   **② Seleção de Região:** No canto superior direito, ao lado do seu nome de usuário, há um indicador de região (ex: "Oregon", "Ohio", "São Paulo"). A AWS tem data centers em várias partes do mundo. **Sempre verifique em qual região você está operando**, pois os recursos que você criar (como máquinas virtuais) residirão fisicamente naquela localidade. Para este tutorial, você pode manter a região "Oregon" (`us-west-2`), que é a padrão para muitas contas do AWS Educate.
*   **③ Seu Perfil e Conta:** No mesmo canto superior direito, clique no seu nome de usuário. Um menu suspenso oferece acesso a informações importantes como:
    - **"Minha conta"**: Para ver detalhes da sua conta e, futuramente, gerenciar preferências de faturamento (embora no AWS Educate isso seja gerenciado de forma diferente).
    - **"Minha cobrança"**: Para acessar o painel de custos e verificar seus créditos e gastos. **É uma boa prática verificar isso regularmente.**
    - **"Preferências"**: Para personalizar a aparência do console (ex: escolher o idioma).


#### **Parte 3:** Mão na Massa - Atividades Práticas de Exploração

Agora que você já sabe se locomover, vamos explorar alguns serviços fundamentais. O objetivo não é criar algo complexo, mas sim navegar pelas telas e entender as opções disponíveis .

**Atividade 1:** Conhecendo o EC2 (Máquinas Virtuais)

1.  Na barra de pesquisa, digite **"EC2"** e clique no resultado para ir ao painel do EC2.
2.  Explore o painel esquerdo. Você verá seções como "Instâncias", "Imagens", "Load Balancing" e "Armazenamento". Cada uma gerencia uma parte do serviço de computação.
3.  Clique em **"Instâncias"** e depois no botão laranja **"Executar instâncias"** .
4.  Você entrará em um assistente de criação. **Não crie a instância de fato!** Apenas explore as opções para ver a quantidade de sistemas operacionais disponíveis (Amazon Linux, Ubuntu, Windows Server), os diferentes tipos de máquina (t2.micro, t3.medium) e as configurações de rede e armazenamento. Essa exploração visual é fundamental para entender a complexidade e o poder do serviço .

**Atividade 2:** Conhecendo o S3 (Armazenamento de Objetos)

1.  Use a barra de pesquisa novamente e vá para o serviço **"S3"** .
2.  O painel do S3 mostra seus buckets (que são como "pastas" de armazenamento na nuvem). Como você ainda não tem nenhum, a tela estará vazia.
3.  Clique no botão **"Criar bucket"** .
4.  Explore o assistente de criação. Veja que é necessário dar um nome **globalmente único** ao bucket. Observe as opções de controle de versão, registro em log e permissões de acesso público. Novamente, **não finalize a criação**. Apenas explore as opções para ver a riqueza de detalhes envolvida em criar até mesmo um recurso "simples" como um bucket de armazenamento .

**Atividade 3:** Conhecendo o Lambda (Computação Serverless)

1.  Vá para o serviço **"Lambda"** .
2.  A página de funções Lambda será exibida. Clique em **"Criar função"** .
3.  Explore as opções: "Criar do zero", "Usar um blueprint" (modelos prontos) e "Repositório de aplicações sem servidor". Veja as diferentes linguagens de programação disponíveis (Python, Node.js, Java, etc.) para escrever sua função. É um exemplo perfeito de um serviço PaaS/serverless, onde você só se preocupa com o código, não com o servidor .

### **Parte 4:** Atividades de Fixação

1.  **Personalize seu Console:** Encontre o ícone de "pino" na barra de navegação superior. Clique nele e adicione atalhos para os serviços EC2, S3 e Lambda, para que eles apareçam fixados na sua barra de ferramentas para acesso rápido .
2.  **Encontre um Recurso de Aprendizado:** Na página inicial do Console, localize a seção **"Criar uma solução"** ou **"Aprenda a criar"** . Explore um dos tutoriais interativos ou links para documentação. Isso mostra como a própria AWS oferece recursos de aprendizado integrados ao console .
3.  **Verifique o Faturamento:** No menu do seu usuário (canto superior direito), clique em **"My Billing Dashboard"** (Meu painel de faturamento). Explore a página para ver se há algum custo incorrido (provavelmente zero, já que você só explorou) e como você poderia configurar alertas de orçamento no futuro para evitar surpresas.


**Lembre-se:**

- O **Console** é seu amigo para aprendizado e gerenciamento visual .
- Mais para frente, você vai conhecer a **CLI (Command Line Interface)** para automatizar tarefas e os **SDKs (Software Development Kits)** para integrar a AWS diretamente no código das suas aplicações .