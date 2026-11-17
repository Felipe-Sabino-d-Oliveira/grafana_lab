# Seleciona a imagem a ser usada no container (recomendação: Python + Alpine)
FROM

# Define o ambiente de trabalho dentro do container
WORKDIR /app

# Instalar dependências do sistema operacional (se necessário)
RUN apk add --no-cache \
    gcc \
    musl-dev \
    python3-dev

# Copiar a lista de dependências Python para o container
COPY

# Instalar as bibliotecas necessárias para a aplicação Python
# (presentes no arquivo requirements.txt)
RUN

# Copiar o restante do código-fonte para o container
COPY

# Criar o diretório para armazenamento dos logs
RUN

# Define a porta utilizada pela aplicação
EXPOSE

# Iniciar a aplicação
CMD
