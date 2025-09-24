#include <a_samp>
#include <Pawn.CMD>
#include <a_mysql>
#include <sscanf2>
#include <foreach>
#include <streamer>
#include <string>
#include <CTime>

#define   FUNCAO::%0(%1) 	   	forward %0(%1);\
							public %0(%1)

//_¸.·´¯`·.¸_Acesso MySQL_¸.·´¯`·.¸_//

#define host        "127.0.0.1"
#define User        "root"
#define Pass         ""
#define BaseDados   "databaselogs"
new MySQL:MySQL_logs;

#define MAX_LOGS     25

//Sistema de logs
new LogMin[MAX_PLAYERS];
new LogMax[MAX_PLAYERS];
new PaginaLog[MAX_PLAYERS];
new ArmazenarIDConta[MAX_PLAYERS];
new ArmazenarNick[24][MAX_PLAYERS];
new ArmazenarNome[200][MAX_PLAYERS];
new ArmazenarFiltro[200][MAX_PLAYERS];

new LogsServidor[][] = {
	{"Login"},
    {"Conexao"},
	{"Ban"},
	{"Kick"},
	{"GMX"}
};

FUNCAO::ConnectMysql()
{
    printf("==| Estabelecendo conexão com o banco de dados |==");
    MySQL_logs = mysql_connect(host, User, Pass, BaseDados);
    mysql_log(ERROR | WARNING);
    if(mysql_errno(MySQL_logs) != 0)
    {
        printf("Falha ao se conectar na banco de dados dos logs.");
        return false;
    }
	for(new i; i < sizeof(LogsServidor); i ++)
    {
        format(stringZCMD,sizeof(stringZCMD),"CREATE TABLE IF NOT EXISTS `%s`(`log_data` int(13) NOT NULL DEFAULT '0',`log_info` varchar(256) NOT NULL DEFAULT '---');", LogsServidor[i]);
        mysql_tquery(MySQL_logs,stringZCMD);
	}
	printf("==| Conexão bem sucedida |==");
    return true;
}

new MEGAString[4096];
new stringZCMD[4096];
						
FUNCAO::EscreverLogs(const log[], const source[])
{
    mysql_format(MySQL_logs, MEGAString, sizeof MEGAString, "INSERT INTO `%e`(`log_data`, `log_info`) VALUES(%d, '%e');", log, gettime(), source);
    mysql_tquery(MySQL_logs, MEGAString);
}
FUNCAO::PesquisarLog(playerid, logname[], filtro[])
{
    new row;
    cache_get_row_count(row);
    new GrandeBuffer[500], Data;
	MEGAString[0] = EOS;
	new titulolog[128];
    strmid(ArmazenarNome[playerid], logname, 0, strlen(logname), 255);
    strmid(ArmazenarFiltro[playerid], filtro, 0, strlen(filtro), 255);
    if(row)
    {
        if(!isnull(filtro))
        {
        	format(stringZCMD,sizeof(stringZCMD),"{FFFFFF}Resultado da Pesquisa: {f06d36}%s -{FFFFFF} No Log: {f06d36}%s\n",filtro,logname);
        	strcat(MEGAString,stringZCMD);
        	format(stringZCMD,sizeof(stringZCMD),"{FFFFFF}Foram encontrados {f06d36}%d resultados {FFFFFF}\n\n",row);
        	strcat(MEGAString,stringZCMD);
		}
  		for(new index; index < row; index ++)
        {
       		cache_get_value_int(index, "log_data", Data);
       		cache_get_value(index, "log_info", GrandeBuffer, sizeof GrandeBuffer);
			if(index % 2 == 0)
			{
    			format(stringZCMD,sizeof(stringZCMD),"{FFFFFF}%s - %s\n", ConverterUnixLogs(Data), GrandeBuffer);
			}
			else
			{
				format(stringZCMD,sizeof(stringZCMD),"{8edcab}%s - %s\n", ConverterUnixLogs(Data), GrandeBuffer);
			}
	     	strcat(MEGAString, stringZCMD);
  		}
		format(titulolog,128,"{FFFFFF}Arquivo de Log({f06d36}%s{FFFFFF}) Pagina %d", logname, PaginaLog[playerid]);
        ShowPlayerDialog(playerid, 35, DIALOG_STYLE_MSGBOX, titulolog, MEGAString, "Opções", "Fechar");
    }
    else
        SendClientMessage(playerid,COR_LIGHTRED,"Não encontramos nada referente a isso em nosso Banco de Dados");
}
FUNCAO::LerLog(playerid,const logname[],const logfiltro[])
{
	if(isnull(logfiltro))
	{
		format(stringZCMD,sizeof(stringZCMD),"SELECT * FROM `%s` ORDER BY `log_data` DESC LIMIT %d,%d;", logname, LogMin[playerid], MAX_LOGS);
		mysql_tquery(MySQL_logs, stringZCMD, "PesquisarLog", "dss", playerid, logname,"");
	}
	else
	{
		format(stringZCMD,sizeof(stringZCMD),"SELECT * FROM `%s` WHERE `log_info` LIKE '%%%s%%' ORDER BY `log_data` DESC LIMIT %d,%d;", logname, logfiltro, LogMin[playerid], MAX_LOGS);
		mysql_tquery(MySQL_logs, stringZCMD, "PesquisarLog", "dss", playerid, logname, logfiltro);
	}
	return 1;
}

stock ConvertUnixLogs(tempo)
{
    new string[31];
    if(tempo <= 0)
        format(string, sizeof string, "00/00/0000 - 00:00:00");
    else
    {
        new tm<tmTime>;
        localtime(Time:tempo, tmTime);
        strftime(string, sizeof(string), "%d/%m/%Y - %H:%M:%S", tmTime);
    }
    return string;
}

CMD:verlogs(playerid)
{
    if(PlayerStatus[playerid][LAdmin] < 1337)
	{
		SEM_AUTORIZACAO
		return true;
	}
    MEGAString[0] = EOS;
    new contarlogs, titulologs[128];
    for(new i; i < sizeof(LogsServidor); i ++)
    {
        format(stringZCMD,sizeof(stringZCMD),"{f06d36}[LOG]{ffffff} %s\n",LogsServidor[i]);
        strcat(MEGAString, stringZCMD);
        contarlogs++;
    }
    format(titulologs,128,"{FFFFFF}Logs Disponiveis: {f06d36}%d",contarlogs);
    ShowPlayerDialog(playerid, 34, DIALOG_STYLE_LIST, titulologs, MEGAString, "Selecionar", "Fechar");
    return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, const inputtext[])
{
    if(dialogid == 34)
    {
        if(response)
        {
			LogMin[playerid] = 0;
			LogMax[playerid] = LogMin[playerid]+25;
			PaginaLog[playerid] = 0;
			LerLog(playerid,LogsServidor[listitem],"");
		}
	}
	else if(dialogid == 35)
	{
		if(response)
		{
			MEGAString[0] = EOS;
			format(stringZCMD, sizeof(stringZCMD), "{FFFFFF}Proxima Pagina (>>>)\n");
			strcat(MEGAString,stringZCMD);
			format(stringZCMD, sizeof(stringZCMD), "{FFFFFF}Voltar Pagina (<<<)\n");
			strcat(MEGAString,stringZCMD);
			format(stringZCMD, sizeof(stringZCMD), "{A0A0A0}Pesquisar Por Palavra\n");
			strcat(MEGAString,stringZCMD);
			format(stringZCMD, sizeof(stringZCMD), "{FF0000}Fechar\n");
			strcat(MEGAString,stringZCMD);
			ShowPlayerDialog(playerid, 36, DIALOG_STYLE_LIST, "Logs", MEGAString, "Selecionar", "Sair");
		}
	}
	else if(dialogid == 36)
	{
	    if(response)
	    {
			if(listitem == 0)
            {
				if(LogMax[playerid] >= 25)
				{
					LogMin[playerid] += 25;
					LogMax[playerid] += 25;
				}
				PaginaLog[playerid] += 1;
				LerLog(playerid,ArmazenarNome[playerid],ArmazenarFiltro[playerid]);
	        }
			else if(listitem == 1)
	        {
		        if(LogMin[playerid] == 0)
		        {
		           	PaginaLog[playerid] = 0;
					return 0;
				}
				else if(LogMin[playerid] >= 25)
				{
					LogMin[playerid] -= 25;
					LogMax[playerid] -= 25;
				}
	            PaginaLog[playerid] -= 1;
	            LerLog(playerid,ArmazenarNome[playerid],ArmazenarFiltro[playerid]);
	        }
	        else if(listitem == 2)
	        {
            	MEGAString[0] = EOS;
	          	format(stringZCMD, sizeof(stringZCMD), "\n{FFFFFF}Sistema de Busca de Palavras em tabela no Banco de Dados: {f06d36}%s",ArmazenarNome[playerid]);
	          	strcat(MEGAString,stringZCMD);
              	strcat(MEGAString,"\n\n{FE642E}Obs: {848484}A Palavra-Chave da busca deve conter entre 2 e 30 caracteres");
              	strcat(MEGAString,"\n\n{848484}Digite abaixo a palavra que deseja buscar:");
              	new titulo[122];
		      	format(titulo, sizeof(titulo), "{FFFFFF}Pesquisa de Logs ({f06d36}%s{FFFFFF})",ArmazenarNome[playerid]);
		      	ShowPlayerDialog(playerid,37,DIALOG_STYLE_INPUT, titulo, MEGAString, "Procurar", "Cancelar");
	        }
		}
	}
	else if(dialogid == 37)
	{
        if(response)
		{

			if(strlen(inputtext) < 2 || strlen(inputtext) > 30)
			    return SendClientMessage(playerid, 0xBEBEBEAA, "Deve inserir 2 a 30 Letras.");

			LogMin[playerid] = 0;
			LogMax[playerid] = LogMin[playerid]+25;
			PaginaLog[playerid] = 0;
			LerLog(playerid,ArmazenarNome[playerid],inputtext);
			return 1;
        }
    }
    return 1;
}