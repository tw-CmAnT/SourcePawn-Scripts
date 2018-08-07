// include:
#include <sourcemod>
#include <sdktools>
#include <adminmenu> // for AddTarget function

// define:
#define prefix "[\x07RPS\x01]"

public Plugin myinfo =
{
	name = "RPS",
	author = "CmAnT",
    description = "You can play rock, paper, scissors with your friends!",
	version = "1.0.0",
	url = "tangoworldwide.net"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_rps", Command_RPS);
	RegConsoleCmd("sm_rpsyes", Command_Accept);
	RegConsoleCmd("sm_rpsno", Command_Decline);
}

// Global vars:
int g_iChoice[MAXPLAYERS + 1]; // Client's choice (display)
int g_iOpponent[MAXPLAYERS + 1]; // Opponent's index
char g_sChoice[MAXPLAYERS + 1][9]; // Client's choice 
bool g_bListening[MAXPLAYERS + 1]; // true to listen to player's chat
bool g_bAccept[MAXPLAYERS + 1]; // true if accepted RPS challenge, else false
bool g_bInGame[MAXPLAYERS + 1]; // true if player is in a game


public Action Command_RPS(int client, int args)
{	
	if (g_bInGame[client])
	{
		PrintToChat(client, "%s You're already in a game.", prefix);
		return Plugin_Handled;
	}
	
	ClearArrays(client);
	DisplayPlayerMenu(client);
	
	return Plugin_Handled;
}

public Action Command_Accept(int client, int args)
{
	if (g_bListening[client])
	{
		g_bAccept[client] = true;
		g_bInGame[client] = true;
		g_bInGame[g_iOpponent[client]] = true;
		g_iChoice[client] = -1;
		g_iChoice[g_iOpponent[client]] = -1;
		DisplayRPSMenu(client);
		DisplayRPSMenu(g_iOpponent[client]);
	}
	return Plugin_Handled;
}

public Action Command_Decline(int client, int args)
{
	if (g_bListening[client])
	{
		g_bAccept[client] = false;
		ClearArrays(g_iOpponent[client]);
		PrintToChat(client, "%s You have \x0Fdeclined\x01 the request.", prefix);
		PrintToChat(g_iOpponent[client], "%s Your opponent has \x0Fdeclined\x01 your request.", prefix);
		ClearArrays(client);
	}
	return Plugin_Handled;
}

public int MenuHandler_Player(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		
		char info[64];
		if (!menu.GetItem(param2, info, sizeof(info)))
    		return;
    	
		g_iOpponent[param1] = GetClientOfUserId(StringToInt(info));
		// Check if player is already in a rps game
		if (g_bInGame[g_iOpponent[param1]])
		{
			PrintToChat(param1, "%s Player is already in a RPS game. Request \x0Fdeclined\x01.", prefix);
			ClearArrays(param1);
			return;
		}
		
		g_iOpponent[g_iOpponent[param1]] = param1;
		
		if (g_iOpponent[param1] == 0)
			return;
		
		char targetName[MAX_NAME_LENGTH];
		GetClientName(g_iOpponent[param1], targetName, sizeof(targetName)); // target's name
	
		char clientName[MAX_NAME_LENGTH];
		GetClientName(param1, clientName, sizeof(clientName)); // client's name
		
		// check if player accepted, else ClearArrays
		PrintToChat(param1, "%s Sent a request to \x04%s\x01.", prefix, targetName);
		PrintToChat(g_iOpponent[param1], "%s %s wants to play RPS with you, type \x04!rpsyes\x01 to play, and \x0F!rpsno\x01 to decline.", prefix, clientName);
		g_bListening[g_iOpponent[param1]] = true;
		
		CreateTimer(30.0, TerminateChallenge, GetClientUserId(param1));
		
		return;
		
	}
	else if (action == MenuAction_End)
		delete menu;
}

public int MenuHandler_RPS(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char buffer[MAX_NAME_LENGTH];
		menu.GetItem(param2, buffer, sizeof(buffer));
		g_iChoice[param1] = buffer[0];
		char info[64];
		
		if (!menu.GetItem(param2, info, sizeof(info)))
    		return;
		
		menu.GetItem(param2, info, sizeof(info), _, buffer, sizeof(buffer));
		g_iChoice[param1] = param2;
		
		if (g_iChoice[param1] != -1 && g_iChoice[g_iOpponent[param1]] != -1)
		{
			DisplayResults(param1, g_iOpponent[param1]);
		}
	}
	else if (action == MenuAction_End)
	{
		ClearArrays(g_iOpponent[param1]);
		ClearArrays(param1);
		delete menu;
	}
}

void DisplayRPSMenu(int client)
{
	Menu rps = new Menu(MenuHandler_RPS);
	rps.SetTitle("Choose!");
	rps.AddItem("r", "Rock");
	rps.AddItem("p", "Paper");
	rps.AddItem("s", "Scissors");
	rps.Display(client, MENU_TIME_FOREVER);
}

void DisplayPlayerMenu(int client)
{
	Menu player = new Menu(MenuHandler_Player)
	player.SetTitle("Pick a player to play with!");
	AddTargetsToMenu2(player, 0, COMMAND_FILTER_NO_BOTS);
	player.ExitBackButton = true;
	player.Display(client, MENU_TIME_FOREVER);
}

int Check(char[] r1, char[] r2)
{
	if (StrEqual(r1, r2))
		return 0;
	else
	{
		if ( ( StrEqual(r1, "Rock") && StrEqual(r2, "Scissors") ) || ( StrEqual(r1, "Paper") && StrEqual(r2, "Rock") ) || ( StrEqual(r1, "Scissors") && StrEqual(r2, "Paper") ) )
			return 1;
		else 
			return 2;
	}
}

void GetChoices(int r, char[] rps, int maxlen)
{
	if (r == 0)
		strcopy(rps, maxlen, "Rock");
	else if (r == 1)
		strcopy(rps, maxlen, "Paper");
	else if (r == 2)
		strcopy(rps, maxlen, "Scissors");
}

void DisplayResults(int client, int target)
{
	char targetName[MAX_NAME_LENGTH];
	GetClientName(target, targetName, sizeof(targetName)); // target's name
	
	char clientName[MAX_NAME_LENGTH];
	GetClientName(client, clientName, sizeof(clientName)); // client's name

	GetChoices(g_iChoice[client], g_sChoice[client], sizeof(g_sChoice[]));
	GetChoices(g_iChoice[target], g_sChoice[target], sizeof(g_sChoice[]));
	
	int result = Check(g_sChoice[client], g_sChoice[target]);
	
	if (result == 0) // tie
	{
		PrintToChat(client, "%s You picked %s, %s picked %s. It's a tie!", prefix, g_sChoice[client], targetName, g_sChoice[target]);
		PrintToChat(target, "%s You picked %s, %s picked %s. It's a tie!", prefix, g_sChoice[target], clientName, g_sChoice[client]);
	}
	else if (result == 1 ) // client win
	{
		PrintToChat(client, "%s You picked %s, %s picked %s. You won!", prefix, g_sChoice[client], targetName, g_sChoice[target]);
		PrintToChat(target, "%s You picked %s, %s picked %s. You lost!", prefix, g_sChoice[target], clientName, g_sChoice[client]);
	}
	else if (result == 2 ) // target win
	{
		PrintToChat(client, "%s You picked %s, %s picked %s. You lost!", prefix, g_sChoice[client], targetName, g_sChoice[target]);
		PrintToChat(target, "%s You picked %s, %s picked %s. You won!", prefix, g_sChoice[target], clientName, g_sChoice[client]);
	}
	
	ClearArrays(client);
	ClearArrays(target);
}

public void OnClientDisconnect(int client)
{
	if (g_bInGame[client])
	{
		PrintToChat(g_iOpponent[client], "%s Your opponent has disconnected.", prefix);
		ClearArrays(g_iOpponent[client]);
	}
	ClearArrays(client);
}

void ClearArrays(int client)
{
	g_sChoice[client] = " ";
	g_iChoice[client] = -1;
	g_iOpponent[client] = -1;
	g_bAccept[client] = false;
	g_bListening[client] = false;
	g_bInGame[client] = false;
}

public Action TerminateChallenge(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	
	if (!g_bAccept[client] || !g_bInGame[client])
	{
		ClearArrays(g_iOpponent[client]);
		PrintToChat(g_iOpponent[client], "%s You have \x0Fdeclined\x01 the request.", prefix);
		PrintToChat(client, "%s Your opponent has \x0Fdeclined\x01 your request.", prefix);
		ClearArrays(client);
	}
}
