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
}

// Global vars:
char aClient[MAXPLAYERS];
char aTarget[MAXPLAYERS];
int aTargetI[MAXPLAYERS];

public Action Command_RPS(int client, int args)
{	
	DisplayPlayerMenu(client);
	
	return Plugin_Handled;
}

public int MenuHandler_Player(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[64];
		if (!menu.GetItem(param2, info, sizeof(info)))
    		return;
		aTargetI[param1] = GetClientOfUserId(StringToInt(info));
		
		if (aTargetI[param1] == 0)
			return;
		
		DisplayRPSMenu(param1);
		DisplayRPSMenu(aTargetI[param1]);
		
	}
	else if (action == MenuAction_End)
		delete menu;
}

public int MenuHandler_RPS(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char buffer[32];
		menu.GetItem(param2, buffer, sizeof(buffer));
		aClient[param1] = buffer[0];
		char info[64];
		
		if (!menu.GetItem(param2, info, sizeof(info)))
    		return;
		if(param1 == aTargetI[param1])
			menu.GetItem(param2, info, sizeof(info), _, aClient[param1], sizeof(aClient[]));
		else
			menu.GetItem(param2, info, sizeof(info), _, aTarget[param1], sizeof(aTarget[]));
		
		// Printing the results:
		if ( !(StrEqual(aClient[param1], "") ) && !(StrEqual(aTarget[param1], "" ) ) )  // if both players chose rock, paper or scissors
		{
			char target[32];
			GetClientName(aTargetI[param1], target, sizeof(target));
			char name[32];
			GetClientName(param1, name, sizeof(name));
			char rps1[9];
			char rps2[9];
			
			charToString(aClient[param1], rps1);
			charToString(aTarget[param1], rps2);
			
			int result = Check(rps1, rps2);
			
			if (result == 0) // tie
			{
				PrintToChat(param1, "%s You picked %s, %s picked %s. It's a tie!", prefix, aClient[param1], target, aTarget[param1]);
				PrintToChat(aTargetI[param1], "%s You picked %s, %s picked %s. It's a tie!", prefix, aTarget[param1], name, aClient[param1]);
			}
			else if (result == 1 ) // client win
			{
				PrintToChat(param1, "%s You picked %s, %s picked %s. You won!", prefix, aClient[param1], target, aTarget[param1]);
				PrintToChat(aTargetI[param1], "%s You picked %s, %s picked %s. You lost!", prefix, aTarget[param1], name, aClient[param1]);
			}
			else if (result == 2 ) // target win
			{
				PrintToChat(param1, "%s You picked %s, %s picked %s. You lost!", prefix, aClient[param1], target, aTarget[param1]);
				PrintToChat(aTargetI[param1], "%s You picked %s, %s picked %s. You won!", prefix, aTarget[param1], name, aClient[param1]);
			}
		}
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

public int Check(char[] r1, char[] r2)
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

void charToString( char r, char rps[9])
{
	if (r == 'r')
		rps = "Rock";
	else if (r == 'p')
		rps = "Paper";
	else
		rps = "Scissors";
}
