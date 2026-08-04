# Ambiente de Desenvolvimento

## Visual Studio Code

* Solução mais simples de instalar, usar o VSCode do Ms Store
* Instalar a extensão Python

## Python - Linux e Windows [Mais fácil de instalar e usar]

* **Instalar**
    - Python3 (também disponível no Ms Store)
* **Ambiente Virtual** - com o ctrl + shift + p - clicar em **Python Create Enviroment** para criar uma pasta "isolada" com as bibliotecas usadas na disciplina
* **Instalar dependências:**
    - OPENGL: !pip install pyopengl
    - GLFW: !pip install glfw

Testar com os códigos-base da Aula 3.

## C - Windows

* Instalar o ambiente Mingw [[http://mingw-w64.org/](http://mingw-w64.org/)].
* Fazer download do GLFW e copiar os arquivos nos diretórios (bin, include, lib, etc) nos respectivos diretórios do Mingw [[https://www.glfw.org/download.html](https://www.glfw.org/download.html)].
* Fazer download do GLEW e copiar os arquivos nos diretórios (bin, include, lib, etc) nos respectivos diretórios do Mingw [[http://glew.sourceforge.net/](http://glew.sourceforge.net/)].
* Adicionar
  o diretório bin do Mingw no PATH do seu sistema operacional. Desta
  forma, o comando "gcc" estará disponível a partir de um prompt de
  comando.
* Para compilar: gcc main.c -lglfw3dll -lglew32 -lopengl32
* Observação 1: um ambiente pré-peparado está disponível em [http://websensors.net.br/projects/scc0250icmc/mingw64-opengl.zip](http://websensors.net.br/projects/scc0250icmc/mingw64-opengl.zip)
* Observação
  2: se no momento de execução do programa for solicitado dll do GLFW e
  GLEW, copie eles do Mingw para o mesmo diretório do seu executável.
* Testar com os códigos-base da Aula 3.

## C - Linux (Debian e Ubuntu)

* Instalar os pacotes libglfw3-dev, mesa-common-dev, libglew-dev.
* Instalar o ambiente GCC (pacote build-essential).
* Para compilar: gcc main.c -lglfw -lGL -lGLEW -lm
* Testar com os códigos-base da Aula 3.

## Java - Linux e Windows

* Instalar o Java JDK mais recente ([https://www.oracle.com/java/technologies/javase-downloads.html](https://www.oracle.com/java/technologies/javase-downloads.html)).
* Utilizar o código-base de exemplo disponibilizado na Aula 3 (possui as bibliotecas OpenGL e GLFW).
