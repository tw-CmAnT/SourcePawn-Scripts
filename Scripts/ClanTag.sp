#include <sourcemod>
#include <sdktools>
#include <cstrike>

public Plugin myinfo = 
{
	name = "ClanTag",
  	author = "CmAnT",
    description = "Sets your clan tag to whatever you want (has to be 3 chars long)",
   	version = "1.0.0",
   	url = "tangoworldwide.net"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_tag", Command_Tag);
}

public Action Command_Tag(int Client, int Args)
{
	char buffer[3];
	GetCmdArg(1, buffer, sizeof(buffer));
	
	char tag[5];
	Format(tag, sizeof(tag), "[%s]", buffer);
	CS_SetClientClanTag(Client, tag);
	PrintToChat(Client, "Your tag was set to %s", tag);
	
	return Plugin_Handled;
}
