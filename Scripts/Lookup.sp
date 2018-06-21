#include <sourcemod>
#include <sdktools>

public Plugin myinfo = 
{
	name = "Lookup",
  	author = "CmAnT",
    description = "Prints some info about the SteamID that you put.",
   	version = "1.0.0",
   	url = "tangoworldwide.net"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_lookup", Command_Lookup, ADMFLAG_SLAY );
}

public Action Command_Lookup(int Client, int Args)
{
	char nAuth[64];
	GetCmdArg(1, nAuth, sizeof(nAuth));
	
	for (int i = 1; i <= MaxClients; i++){
		char auth[64];
		GetClientAuthId(i, AuthId_Steam2, auth,sizeof(auth))
		if(StrEqual(nAuth , auth))
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(i, name, sizeof(name));
			int frags = GetClientFrags(i);
			int deaths = GetClientDeaths(i);
			int hp = GetClientHealth(i);
			
			PrintToChat(i, "Name: %s", name);
			PrintToChat(i, "SteamID: %s", auth);
			PrintToChat(i, "Kills: %d", frags);
			PrintToChat(i, "Deaths: %d", deaths);
			PrintToChat(i, "Health: %d", hp);
			
			return Plugin_Handled;
		}
	}
	PrintToChat(Client, "no match found!");
	return Plugin_Handled;
}
