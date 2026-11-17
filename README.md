# Carnivorous Green House

![Carnivorous Green House](./static/index_image.png)

## Sobre o projeto

O **Carnivorous Green House** é uma aplicação web que simula uma estufa de plantas carnívoras. O projeto utiliza Flask para disponibilizar a aplicação, autenticação de usuários e atualização simulada de dados das plantas em tempo real.

O ambiente também demonstra centralização, consulta e visualização de logs com **Grafana Alloy**, **Grafana Loki** e **Grafana**.

- Grafana Alloy: agente responsável por coletar os logs gerados pela aplicação e encaminhá-los ao Loki.
- Grafana Loki: ferramenta responsável por receber, armazenar e permitir consultas aos logs.
- Grafana: plataforma de visualização que consulta o Loki e apresenta os registros em painéis e na interface Explore.

Como as ferramentas se conectam?

A aplicação Flask gera os logs em um arquivo. O Grafana Alloy coleta esses registros e os encaminha ao Grafana Loki, que os armazena. Por fim, o Grafana consulta o Loki e permite visualizar e analisar os logs.

Fluxo: Flask → Alloy → Loki → Grafana.

## Funcionalidades

- Simulação de uma estufa de plantas carnívoras.
- Cadastro e autenticação de usuários.
- Cadastro de plantas por usuário.
- Atualização simulada de dados das plantas via Socket.IO.
- Modo de falhas aleatórias para gerar eventos de erro.
- Registro de eventos da aplicação em arquivo de log.
- Coleta dos logs pelo Grafana Alloy.
- Armazenamento e consulta dos logs no Loki.
- Visualização dos logs no Grafana.

## Tecnologias

- Python 3.12
- Flask
- Flask-SocketIO
- Flask-SQLAlchemy
- SQLite
- Docker e Docker Compose
- Grafana Alloy
- Grafana Loki
- Grafana

## Arquitetura do ambiente Docker

O `docker-compose.yml` define quatro serviços:

| Serviço | Função | Porta publicada |
|---|---|---|
| `carnivorous-garden` | Aplicação Flask | 5005 |
| `alloy` | Coleta e encaminhamento dos logs | 12345 |
| `loki` | Armazenamento e consulta dos logs | 3100 |
| `grafana` | Painéis e exploração dos logs | 3000 |

Os serviços compartilham a rede Docker `loki`. O Alloy lê o arquivo `logs/app.log`, encaminha os registros para o Loki e o Grafana utiliza o Loki como fonte de dados.

## Pré-requisitos

Para executar o ambiente completo, instale:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- Docker Compose v2 (comando `docker compose`)

No Windows, abra o Docker Desktop e aguarde o Engine ficar disponível antes de executar os comandos.

Confira a instalação:

```powershell
docker version
docker-compose version
```

O comando `docker version` deve apresentar informações tanto do Client quanto do Server.

## Instalação e execução com Docker Compose

### 1. Clonar o repositório

```bash
git clone https://github.com/carlhenriquesantos/grafana_lab.git
cd grafana_lab
```

### 2. Construir e iniciar os serviços

```bash
docker compose up -d --build
```

O primeiro início pode demorar porque as imagens precisam ser baixadas e a imagem da aplicação precisa ser construída.

### 3. Verificar os containers

```bash
docker compose ps
```

Para acompanhar os logs de todos os serviços:

```bash
docker compose logs -f
```

Para acompanhar somente a aplicação:

```bash
docker compose logs -f carnivorous-garden
```

## Acessar os serviços

Depois que os containers estiverem em execução, utilize:

| Serviço | Endereço |
|---|---|
| Aplicação Carnivorous Green House | http://localhost:5005 |
| Grafana | http://localhost:3000 |
| Grafana Alloy (interface de gerenciamento) | http://localhost:12345 |
| Loki (endpoint HTTP) | http://localhost:3100 |

O Compose configura o Grafana com autenticação anônima habilitada e papel de administrador. Essa configuração é destinada a laboratório local, não a ambientes expostos à internet.

No Grafana, a fonte de dados Loki é provisionada automaticamente com o endereço interno `http://loki:3100`.

## Consultar os logs

A aplicação grava seus registros em:

```text
logs/app.log
```

Esse diretório é compartilhado entre a aplicação e o Alloy por meio de volumes Docker. O Alloy acompanha o arquivo e encaminha os registros para o Loki.

No Grafana:

1. Acesse http://localhost:3000.
2. Abra a área **Explore**.
3. Selecione a fonte de dados **Loki**.
4. Execute uma consulta, por exemplo:

```logql
{filename="/tmp/app-logs/app.log"}
```

Para consultar erros:

```logql
{level="ERROR"}
```

A configuração do Alloy extrai o nível de log a partir do formato dos registros da aplicação e o utiliza como label `level`. A disponibilidade das consultas depende de o Alloy estar coletando os registros e de o Loki estar recebendo os dados.

## Modo de falhas

A aplicação possui um mecanismo de falhas aleatórias que pode ser ativado pela interface. Ele permite gerar registros de erro e observar o fluxo de coleta e visualização:

```text
Aplicação Flask
      |
      v
logs/app.log
      |
      v
Grafana Alloy
      |
      v
Grafana Loki
      |
      v
Grafana Explore
```

Use esse recurso para testar a consulta de logs e acompanhar eventos de erro no Grafana.

## Comandos úteis

| Ação | Comando |
|---|---|
| Iniciar os serviços | `docker compose up -d` |
| Construir e iniciar | `docker compose up -d --build` |
| Parar os serviços | `docker compose stop` |
| Reiniciar os serviços | `docker compose restart` |
| Listar containers | `docker compose ps` |
| Exibir logs | `docker compose logs -f` |
| Exibir logs de um serviço | `docker compose logs -f alloy` |
| Parar e remover containers e rede | `docker compose down` |
| Reconstruir sem cache | `docker compose build --no-cache` |

Para remover também os volumes nomeados declarados no Compose, seria necessário utilizar `docker compose down -v`. Isso não substitui a remoção de arquivos armazenados em diretórios locais montados como bind mounts.

### Aplicação não abre no navegador

Confira o estado dos serviços e os logs:

```bash
docker compose ps
docker compose logs carnivorous-garden
```

Verifique se a porta 5005 está disponível no Windows.

## Pontos de atenção

- O SQLite é configurado pela aplicação, mas o Compose atual não declara um volume persistente específico para o banco. A persistência dos dados do banco entre a recriação dos containers não deve ser presumida.
- A chave de sessão está definida diretamente no código (`SECRET_KEY`). Antes de utilizar o projeto fora de um laboratório, mova esse segredo para uma variável de ambiente.
- O Grafana está configurado com acesso anônimo de administrador. Não exponha essa configuração em redes públicas.
- As imagens dos serviços utilizam a tag `latest`. Para reproduzir o ambiente com maior previsibilidade, fixe versões específicas das imagens.
- O projeto é uma demonstração educacional; não deve ser considerado uma configuração pronta para produção.

## Contribuição

1. Faça um fork do repositório.
2. Crie uma branch para sua alteração.
3. Implemente e teste a mudança.
4. Envie um commit com uma mensagem descritiva.
5. Abra um Pull Request.

