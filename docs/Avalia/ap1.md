# AP1

## Objetivo 

Adicionar duas classes relativas ao aplicativo Django Rest sendo planejado na disciplina de Projeto de Cloud com relação ao TEMA, e realizar o deploy do projeto na AWS utilizando o Elastic Beanstalk com o arquivo `app.zip` segundo roteiro de aula.

### Entrega

- Repositório Github - Código-fonte do projeto atualizado, incluindo as novas classes e as APIs relacionadas professor adicionado como colaborador.
- **Não é necessário a presença do Grupo no Lab 212**, se até o início da aula o projeto já estiver atualizado e o deploy realizado. O envio deve ser feito adicionando o professor ao repositório, e no readme do projeto deve conter o link da API publicada. 
- Retire o app e a classe produtos
- Crie um app conforme o Tema que conterá as duas classes desenvolvidas
- Readme atualizado. 
- Instruções claras sobre como configurar e executar o projeto localmente, bem como detalhes sobre as alterações realizadas.
- Documentação das etapas realizadas para a implementação e deploy.
- Link para o projeto deployado na AWS Elastic Beanstalk.
- O App.zip para o deploy pode ser baseado no fornecido em aula com as devidas alterações no app django adicionado e os models, valendo 80% da nota.
- Para o 100% é necessário que o nome do projeto django e o app estejam no contexto do Tema do Projeto de Cloud
- Crie o superusuário(admin) para operar na interface do Django-Admin


### Cenário

Você possui um projeto Django Rest com uma classe `Produto`. Seu objetivo é criar duas novas classes referentes ao Tema da disciplina de Projeto de Cloude e garantir que os endpoints da APIs estejam funcionando corretamente. Após as alterações, faça o deploy do projeto na AWS Elastic Beanstalk utilizando um arquivo `app.zip`. Você deverá alterar os arquivos de configuração necessários para garantir que o deploy seja bem-sucedido, seguindo o roteiro de aula fornecido acrescentando as instruções específicas para a configuração do ambiente para a criação do usuário admin(root), para que seja possivel logar no django-admin com administrador.

### Referências

- [Documentação Django Rest Framework](https://www.django-rest-framework.org/)
- [Deploy de aplicações Python no AWS Elastic Beanstalk](https://docs.aws.amazon.com/pt_br/elasticbeanstalk/latest/dg/create-deploy-python-django.html)
- [Roteiro de aula para deploy na AWS Elastic Beanstalk](https://jonh-carvalho.github.io/BDCC_CDIA_26.1_8001/Disciplina/roteiros/07%20-%20eb/)
- [Repositório do Roteiro de sala de aula](https://github.com/jonh-carvalho/RestEB)

## Critérios de Correção

- Implementação correta das duas novas classes e relacionamento
- admin(Django Admin)
- Projeto e Models (Projeto Cloud)
- APIs funcionando conforme esperado
- Deploy realizado com sucesso na AWS Elastic Beanstalk usando `app.zip`
- Documentação clara das etapas realizadas
