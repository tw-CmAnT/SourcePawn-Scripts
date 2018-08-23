#include <sourcemod>
#include <sdktools>

#define PLUGIN_PREFIX "[\x04FunRounds\x01]"

public Plugin myinfo = 
{
	name = "Fun Rounds",
	author = "CmAnT",
	description = "Allow a fun round to be a possibility after rounds 5.",
	version = "1.0",
	url = "git.tangoworldwide.net/cmant"
};

int g_iRoundCount;
bool g_bFirstFDay; // True if first day Fun Day already happened.


public void OnPluginStart()
{
	HookEvent("round_start", Event_RoundStart, EventHookMode_Post);
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bFirstFDay)
	{
		if (GameRules_GetProp("m_bWarmupPeriod") != 1)
    	{
   		 	g_iRoundCount++;
    	}
		if (g_iRoundCount >= 5)
    	{
    		if (GetRandomInt(1, 3) == 1)
    		{
    			g_iRoundCount = 0;
    			g_bFirstFDay = true;
    			GetRandomDay();
    		}
    	}
   	}
  	else
  	{
  		if (GetRandomInt(1, 5) == 1)
  		{
  			GetRandomDay();
  		}
 	}
  	
  	return Plugin_Continue;
}

public void OnMapEnd()
{
	g_iRoundCount = -1;
}

Action GetRandomDay()
{
	PrintToChatAll("%s Today is a fun round!", PLUGIN_PREFIX);
	int random = GetRandomInt(1, 3);
	switch (random)
	{
		case 1:
		{
			SpeedDay();
		}
		case 2:
		{
			GravityDay();
		}
		case 3:
		{
			HealthDay();
		}
	}
	return Plugin_Handled;
}

void SpeedDay()
{
	float speed = 2.0;
	PrintToChatAll("%s All players now have \x04Double Speed\x01!", PLUGIN_PREFIX);
	for (int i = 1; i <= MaxClients; i++)
    {
		SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", speed);
	}
}

void GravityDay()
{
	float gravity = 0.5;
	PrintToChatAll("%s All players now have \x04Low Gravity\x01!", PLUGIN_PREFIX);
	for (int i = 1; i <= MaxClients; i++)
    {
		SetEntityGravity(i, gravity);
	}
}

void HealthDay()
{
	int health = 150;
	PrintToChatAll("%s All players now have \x04150 Health\x01!", PLUGIN_PREFIX);
	for (int i = 1; i <= MaxClients; i++)
    {
		SetEntityHealth(i, health);
	}
}
