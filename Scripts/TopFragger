#include <sourcemod>
#include <cstrike>

public Plugin myinfo =
{
	name = "Top Frags",
	description = "Shows the current top fragger.",
	author = "CmAnT",
	version = "1.0.0",
	url = "tangoworldwide.net"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_frags", Command_Frags, "Shows who the current top fragger is.", 0);
}

public Action Command_Frags(int Client, int Args)
{
	int Max = 0;
	char name[32];
	int currentClient = 1;
	while (currentClient <= MaxClients)
	{
		if (IsClientConnected(currentClient))
		{
			if (GetClientFrags(currentClient) > Max)
			{
				Max = GetClientFrags(currentClient);
				GetClientName(currentClient, name, 32);
				currentClient++;
			}
			currentClient++;
		}
		currentClient++;
	}
	
	if(Max > 0)
		PrintToChat(Client,"%s has the most frags this game!! (%d frags) ", name, Max);
	else
		PrintToChat(Client, "No one has got a kill yet.");
	
	return Plugin_Handled;
}

