#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define prefix "[\x0FSM\x01]"

bool hasGodMode[MAXPLAYERS + 1]; // checks if the client is hooked.
char name[32];

public Plugin myinfo =
{
        name = "sm_health, sm_god, and sm_tp",
        author = "CmAnT",
        description = "Adds these 3 different commands to the server.",
        version = "1.0.0",
        url = "tangoworldwide.net"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_health", Command_Health);
	RegConsoleCmd("sm_tp", Command_Teleport);
	RegConsoleCmd("sm_god", Command_God);
}

public Action Command_Health(int Client, int Args)
{
	char target[32];
	char amountN[5];
	int amount;
	int targetI;
	// recieving the args:
	if(Args < 1)
	{
		PrintToChat(Client, "%s Usage: sm_health <name> <hp_amount>", prefix);
		return Plugin_Handled;
	}
	else if (Args == 1) // if the client is targetting himself
	{
		GetCmdArg(1, amountN, sizeof(amountN));
		targetI = Client;
	}
	else // if the client is targetting someone else
	{
		GetCmdArg(1, target, sizeof(target));
		GetCmdArg(2, amountN, sizeof(amountN));
		targetI = FindTarget(Client, target); // TargetI is the index of the name "target"
	}
	
	amount = StringToInt(amountN); // casts from string to int
	
	// setting hp:
	if(isExist(targetI)) // if client isnt a bot and is on the server
	{
		if(isAlive(targetI)) // if client is alive
		{
			if(amount > 0)
			{
				GetClientName(targetI, name, sizeof(name));
				SetEntityHealth(targetI, amount);
				PrintToChatAll("%s Set %s's health to %d", prefix, name , amount); 
			}
			else
				PrintToChat(Client, "%s Health must be above 0.", prefix);
		}
		else
			PrintToChat(Client, "%s Cannot target dead clients.", prefix);
	}
	else
		PrintToChat(Client, "%s User not found.", prefix);
	
	return Plugin_Handled;
}

public Action Command_Teleport(int Client, int Args)
{
	int target1I;
	int target2I;
	char target1[32];
	char target2[32];
	
	// finding Args:
	if(Args < 1)
		PrintToChat(Client, "%s Usage: sm_tp <user1> <user2>", prefix);
	else if(Args == 1)
	{
		GetCmdArg(1, target2, sizeof(target2));
		target1I = Client;
		return Plugin_Handled;
	}
	else
	{
		GetCmdArg(1, target1, sizeof(target1));
		GetCmdArg(2, target2, sizeof(target2));
		target1I = FindTarget(Client, target1);
		target2I = FindTarget(Client, target2);
	}
	
	// Teleporting:
	if(isExist(target1I))
	{
		if(isAlive(target1I))
		{
			float position[3];
			float aim[3];
			GetClientAbsAngles(target2I, position);
			GetClientEyeAngles(target2I, aim);
			TeleportEntity(target1I, position, aim, NULL_VECTOR);
			GetClientName(target1I, name, sizeof(name));
			PrintToChatAll("%s Teleported %s to %s.", prefix, name, target2);
		}
		else
			PrintToChat(Client, "%s Cannot target dead clients.", prefix);
	}
	else
		PrintToChat(Client, "%s User not found.", prefix);
	return Plugin_Handled;
}
	
public Action Command_God(int Client, int Args)
{
	char target[32];
	int targetI;
	
	// Recieving args:
	if(Args < 1)
	{
		targetI = Client;
		return Plugin_Handled;
	}
	else
	{
		GetCmdArg(1, target, sizeof(target));
		targetI = FindTarget(Client, target);
	}
	
	// Toggle god mode:
	if(isExist(targetI))
	{
		if(isAlive(targetI))
		{
			ToggleGodMode(targetI);
			GetClientName(targetI, name, sizeof(name));
			PrintToChatAll("%s %s has toggled GodMode.", prefix, name);
		}
		else
			PrintToChat(Client, "%s Cannot target dead clients.", prefix);
	}
	else
		PrintToChat(Client, "%s User not found.", prefix);
	
	
	
	
	return Plugin_Handled;
}

public void ToggleGodMode(int Client)
{
	if(hasGodMode[Client])
		SDKUnhook(Client, SDKHook_OnTakeDamage, OnTakeDamage);
	else
		SDKHook(Client, SDKHook_OnTakeDamage, OnTakeDamage);
	hasGodMode[Client] = !hasGodMode[Client];
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom) 
{
	damage = 0.0;
	return Plugin_Continue;
}

public void OnClientDisconnect(int Client)
{
	if(hasGodMode[Client])
	{
		hasGodMode[Client] = false;
		SDKUnhook(Client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

public bool isExist(int Client)
{
	if (IsClientConnected(Client))
		return true;
	return false;
}

public bool isAlive(int Client)
{
	 return isExist(Client) && IsPlayerAlive(Client);
		
}
