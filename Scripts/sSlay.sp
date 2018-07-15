// include:
#include <sourcemod>
#include <sdktools>
#include <commandfilters>

// define:
#define prefix "[\x0FSlay\x01]"

public Plugin myinfo = 
{
	name = "sslay",
	author = "CmAnT",
	description = "slays people with a reason",
	version = "1.0",
	url = "tangoworldwide.net"
};

// global vars:

public void OnPluginStart()
{
	RegAdminCmd("sm_sslay", Command_sSlay, ADMFLAG_SLAY);
	LoadTranslations("common.phrases")
}

public Action Command_sSlay(int client, int args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "%s Usage: sm_slay <name> <reason>", prefix);
		return Plugin_Handled;
	}
	
	char clientName[32];
	GetClientName(client, clientName, sizeof(clientName));
	
	char buffer[32];
	GetCmdArg(1, buffer, sizeof(buffer));
	
	int target = FindTarget(client, buffer, false, true);
	
	char reason[32];
	GetCmdArg(2, reason, sizeof(reason));
	
	PrintToChatAll("%s \x0F%s\x01 slayed \x0F%s\x01 for \x04%s\x01.", prefix, clientName, buffer, reason);
	ForcePlayerSuicide(target);
	
	return Plugin_Handled;
	
}
