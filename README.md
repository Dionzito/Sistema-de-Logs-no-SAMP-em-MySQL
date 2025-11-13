# Sistema de Logs para SA-MP

Este módulo fornece um sistema moderno de **logs com MySQL** para servidores SA-MP. Ele registra ações do servidor e dos jogadores em um banco de dados, permitindo consulta aos registros dentro do proprio jogo.

---

## 🚀 Funcionalidades

* Registro de logs de **servidor** e **jogadores**.
* Estrutura única e moderna de banco de dados.
* Função única para escrita de logs: `EscreverLog`.
* Paginação para visualização de logs dentro do jogo.
* Pesquisa de Registros por palavras especificas

---

## 📦 Dependências

Certifique-se de que seu servidor SA-MP possui os seguintes includes/plugins:

* [mysql](https://github.com/pBlueG/SA-MP-MySQL)
* [sscanf2](https://github.com/maddinat0r/sscanf)
* [foreach](https://github.com/karimcambridge/samp-foreach)
* [streamer](https://github.com/samp-incognito/samp-streamer-plugin)
* [CTime](https://github.com/Southclaws/pawn-ctime)

**Obs. O Processador de comandos utilizado é o Pawn.CMD, mas você pode escolher outro de sua preferência. Eu utilizei esse pois é o processador mais rápido [Pawn.CMD-Wiki](https://sampforum.blast.hk/showthread.php?tid=608474)**

---

## 🗄️ Estrutura do Banco de Dados

Crie a `DataBase` no seu MySQL com o nome que preferir, mas lembre de alterar o nome dentro do sistema em
```pawn
#define BaseDados   "databaselogs"
```

Não é necessário se preocupar com o modelo das tabelas, pois o sistema cria automaticamente. Mais detalhes na aba de `Instalação`.

---

## 📚 Guia de Funções

- `ConnectMysql`: Realiza a conexão do seu Servidor com o Banco de Dados MySQL

- `EscreverLogs(const log[], const source[])`: Escreve o registro(`source`) no Banco de Dados na tabela definida em `log`

- `LerLog(playerid,const logname[],const logfiltro[])`: Realiza a consulta no Banco de Dados MySQL.
    - *Parâmetros*
     `playerid`: Envia o ID do jogador que realizou a consulta
     `logname`: Envia o nome da tabela onde a busca será feita
     `logfiltro`: Envia o filtro de busca (caso esteja vazio, retorna a tabela completa)

- `PesquisarLog(playerid, logname[], filtro[])`: Exibe o resultado da consulta feita anteriormente
    - *Parâmetros*
     `playerid`: Envia o ID do jogador que realizou a consulta
     `logname`: Envia o nome da tabela onde a busca foi realizada
     `filtro`: Envia o filtro que foi utilizado na busca (Se vazio, retorna a tabela completa)

- `ConvertUnixLogs(tempo)`: Faz a conversão do TimeStamp presente no banco de dados para o formato de horário real (Include e Plugin CTime necessários)

---

## ⚙️ Instalação

1. Configure os dados de conexão no arquivo `SistemaLogs.pwn`:

   ```pawn
   #define host        "127.0.0.1" // Host do Seu MySQL
    #define User        "root" // Usuario
    #define Pass         "" // Senha
    #define BaseDados   "databaselogs" // Nome da DataBase
   ```

2. Inclua o `SistemaLogs.pwn` no seu gamemode.

3. Compile o gamemode.

4. Adicione as tabelas que você deseja verificar em:
    ```pawn
    new LogsServidor[][] = {
        {"Login"},
        {"Conexao"},
        {"Ban"},
        {"Kick"},
        {"GMX"}
    };
    ```
5. Essas tabelas serão criadas automaticamente na função `ConnectMysql`

     **Obs. Você deve adicionar essa função no seu `OnGameModeInit`**

---

## 🖊️ Como Registrar Logs

Use a função `EscreverLogs`:

```pawn
// Exemplo direto:
EscreverLogs("Kick","O Administrador Dionzito_Staff kickou o jogador Teste do Servidor");

// Exemplo Formatado:
format(stringZCMD,sizeof(stringZCMD),"O Administrador %s expulsou o jogador %s do Servidor, motivo: %s",NomeAdmin, NomePlayer, MotivoKick);
EscreverLogs("Kick",stringZCMD);
```

---

## 🔎 Visualizar Logs no Jogo

O Sistema já vem incluido com o comando `/verlogs`, basta alterar suas variaveis de verificação de Administrador e definir qual nivel de administrador vai ter acesso aos Logs.

O Sistema conta com paginação (Opção de Adiantar e Voltar páginas) e Sistema de pesquisa por palavras especificas.

---

## 🖼️ Imagens

[![Imagem 1](http://github.com/Dionzito/Sistema-de-Logs-no-SAMP-em-MySQL/blob/main/imagens/verlogs.png "Exemplo do /verlogs")](https://raw.githubusercontent.com/Dionzito/Sistema-de-Logs-no-SAMP-em-MySQL/refs/heads/main/imagens/verlogs.png)

[![Imagem 2](https://github.com/Dionzito/Sistema-de-Logs-no-SAMP-em-MySQL/blob/main/imagens/pesquisa%20logs.png "Pesquisa de Logs")
](https://github.com/Dionzito/Sistema-de-Logs-no-SAMP-em-MySQL/blob/main/imagens/pesquisa%20logs.png?raw=true)

[![Imagem 3](https://github.com/Dionzito/Sistema-de-Logs-no-SAMP-em-MySQL/blob/main/imagens/opcoes%20logs.png "Opções dos Logs")](https://github.com/Dionzito/Sistema-de-Logs-no-SAMP-em-MySQL/blob/main/imagens/opcoes%20logs.png?raw=true)

[![Imagem 4](https://github.com/Dionzito/Sistema-de-Logs-no-SAMP-em-MySQL/blob/main/imagens/opcoes%20logs.png "Exemplo de Exibição dos Logs")](https://github.com/Dionzito/Sistema-de-Logs-no-SAMP-em-MySQL/blob/main/imagens/exemplo%20logs.png?raw=true)

[![Imagem 5](https://github.com/Dionzito/Sistema-de-Logs-no-SAMP-em-MySQL/blob/main/imagens/exemplo%202%20logs.png "Exemplo 2 de Exibição dos Logs")](https://github.com/Dionzito/Sistema-de-Logs-no-SAMP-em-MySQL/blob/main/imagens/exemplo%202%20logs.png?raw=true)

---

## 📜 Licença

Este sistema é distribuído sob a **MIT License**. Você pode usar, modificar e distribuir livremente, desde que mantenha os créditos do autor.

---

✍️ Desenvolvido e modernizado para facilitar a auditoria de servidores SA-MP.
