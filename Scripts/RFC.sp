// include:
#include <sourcemod>
#include <sdktools>

//define:
#define prefix "[\x04RFC\x01]"


public Plugin myinfo = 
{
	name = "RFC",
	author = "CmAnT",
	description = "trynna make the tango rfc plugin",
	version = "1.0",
	url = "tangoworldwide.net"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_rfc", Command_RFC);
}

public Action Command_RFC(int client, int args)
{
	DisplayRfcMenu(client);
	return Plugin_Handled;
}

public int MenuHandler_rfc(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		int client = param1;
		char buffer[3];
		if (!menu.GetItem(param2, buffer, sizeof(buffer)))
			return;
		int random = GetRandomInt(1, 5);
		int number = StringToInt(buffer)
		PrintToChat(client, "%s You choose \x0F%d\x01, the chosen number was \x0F%d\x01.", prefix, number, random);
		if (number == random)
			PrintToChat(client, "%s You \x04win\x01!", prefix);
		else
			PrintToChat(client, "%s You \x0FLose\x01!", prefix)
	}
}

void DisplayRfcMenu(int client)
{
	Menu menu = new Menu(MenuHandler_rfc);
	menu.SetTitle("Choose a number!");
	menu.AddItem("1", "1");
	menu.AddItem("2", "2");
	menu.AddItem("3", "3");
	menu.AddItem("4", "4");
	menu.AddItem("5", "5");
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}
