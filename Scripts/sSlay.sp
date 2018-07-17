// include:
#include <sourcemod>
#include <sdktools>

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
	LoadTranslations("common.phrases.txt")
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
	
	char pattern[32];
	GetCmdArg(1, pattern, sizeof(pattern));
	
	char targetName[32];
	int targets[MAXPLAYERS];
	bool tn_is_ml;
	
	int targetsFound = ProcessTargetString(pattern, client, targets, sizeof(targets), COMMAND_FILTER_ALIVE, targetName, sizeof(targetName), tn_is_ml);
	
	if (targetsFound <= COMMAND_TARGET_NONE)
	{
		ReplyToTargetError(client, targetsFound);
		return Plugin_Handled;
	}
	
	char reason[32];
	GetCmdArg(2, reason, sizeof(reason));
	
	PrintToChatAll("%s \x0F%s\x01 slayed \x0F%s\x01 for \x04%s\x01.", prefix, clientName, pattern, reason);
	ForcePlayerSuicide(targetsFound);
	
	return Plugin_Handled;
	
}
