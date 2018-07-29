// include:
#include <sourcemod>
#include <sdktools>

// define:
#define prefix "[\x04Freeze\x01]"

public Plugin myinfo = 
{
	name = "freeze",
	author = "CmAnT",
	description = "freezes people",
	version = "1.0",
	url = ""
};

// global vars:
int g_iTime[MAXPLAYERS + 1]; // Freeze time
int g_iCount[MAXPLAYERS + 1]; // Freeze countdown

public void OnPluginStart()
{
	RegConsoleCmd("sm_ffreeze", Command_Freeze);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
}

public Action Command_Freeze(int client, int args)
{
	if (args < 2)
	{
		PrintToChat(client, "%s Usage: sm_ffreeze <player> <time>", prefix);
		return Plugin_Handled;
	}
	
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
	
	char buffer[5];
	GetCmdArg(2, buffer, sizeof(buffer));
	
	for (int i = 0; i < targetsFound; i++)
	{
		g_iTime[targets[i]] = StringToInt(buffer);
		g_iCount[targets[i]] = g_iTime[targets[i]];
		SetEntityMoveType(targets[i], MOVETYPE_NONE);
		CreateTimer(1.0, Unfreeze, targets[i], TIMER_REPEAT);
	}
	
	PrintToChatAll("%s Froze \x0F%s\x01 for \x04%d\x01 seconds.", prefix, targetName, g_iTime[targets[0]]);
	
	return Plugin_Handled;
}

Action Unfreeze(Handle timer, any client)
{
	PrintHintText(client, "You will be unfrozen in %d seconds.", g_iCount[client]);
	g_iCount[client]--;
	
	if (g_iCount[client] == 0)
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
		delete timer;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	ClearArrays(client);
	
	return Plugin_Handled;
}

public void OnClientDisconnect(int client)
{
	ClearArrays(client);
}

void ClearArrays(int client)
{
	g_iTime[client] = 0;
	g_iCount[client] = 0;
}
