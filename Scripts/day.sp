#include <sourcemod>
#include <sdktools>
#include <warden>

#define prefix "[\x06Special-Day\x01]"

public Plugin myinfo =
{
        name = "Special Days",
        author = "CmAnT",
        description = "Makes special days better and easier to do",
        version = "1.1",
        url = "tangoworldwide.net"
};
 
int round = 0;
char sDay[32];
 
public void OnPluginStart()
{
    HookEvent("round_start", Event_RoundStart);
    RegConsoleCmd("sm_day", Command_Day);
    RegAdminCmd("sm_rday", Command_Reset, ADMFLAG_SLAY);
}
 
public Action Command_Day(int client, int Args)
{
	if (!Warden_Exists()) // if there's no warden taken
		PrintToChat(client, "%s Warden has not been taken!", prefix);
       
   	else if (warden_iswarden(client))
    {
        int timeLeft;
        GetMapTimeLeft(timeLeft);
        if (timeLeft > (9 * 60 + 25)) // if its before 9:25
        {
            if (IsAvailable())
            {      
                Menu menu = new Menu(SpecialDay);
                menu.SetTitle("Pick a special day!");
                menu.AddItem("purge", "Purge Day");
                menu.AddItem("panda", "Panda Freeday");
                menu.AddItem("zombie", "Zombie Freeday");
                menu.AddItem("ssd", "Super Strict Day");
                menu.AddItem("warday", "Warday");
                menu.AddItem("kangaroo", "Kangaroo Freeday");
                menu.Display(client, 10);
           
                round = 0;
            }
            else
            {
            	strcopy(sDay, sizeof(sDay), "Regular Day");
                int roundsLeft = 5 - round;
                PrintToChat(client, "%s You have to wait \x0F%d \x01more rounds to call a special day!", prefix, roundsLeft);
            }
        }
        else
        {
            PrintToChat(client, "%s You are not allowed to use this command after 9:25.", prefix);
        }
    }
   
   	else
    {
    	if (StrEqual(sDay, "")) // if sDay has no value
    		PrintToChat(client, "%s Warden has \x0Fnot\x01 picked a day yet.", prefix);
    	
    	else
        	PrintToChat(client, "%s Today is a \x0F%s\x01!", prefix, sDay);
    }
   
   	return Plugin_Handled;
}
 
public Action Command_Reset(int client, int args)
{
	if (round > 0)
		PrintToChat(client, "%s You can only use this command on a \x0Fspecial day\x01!", prefix);
	else if (round == 0)
	{
		round = 4;
		PrintToChatAll("%s Today is \x0Fno longer\x01 a special day!", prefix);
	}
	
	return Plugin_Handled;
}

public int SpecialDay(Menu menu, MenuAction action, int param1, int param2)
{
    if(action == MenuAction_Select)
    {
        char sInfo[8];
        if(!menu.GetItem(param2, sInfo, sizeof(sInfo),_, sDay, sizeof(sDay))) /* param2 is the place of the option (0 is option 1, 1 is optin 2...)
        sInfo is what item the clien chose, _ means skip this, sDay is the name of the day*/
            return;
       
        PrintToChatAll("%s Today is a \x0F%s!", prefix, sDay);
        PrintToChatAll("%s Today is a \x0F%s!", prefix, sDay);
        PrintToChatAll("%s	 Today is a \x0F%s!", prefix, sDay);
        PrintToChatAll("%s If you don't know what a \x0F%s\x01 is, make sure you do \x0F!dinfo", prefix, sDay);
        EmitSoundToAll("warden/enter.mp3"); 
    }
    else if(action == MenuAction_End)
    {
        delete menu;
    }
}

public bool IsAvailable()
{
    return round >= 5;
}
 
public void warden_OnWardenCreated(int warden)
{
	if(IsAvailable())
   			PrintToChat(warden, "%s You can call a special day this round by using sm_day ", prefix);
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (GameRules_GetProp("m_bWarmupPeriod") != 1) // IF ITS NOT A WARMUP
    {
    	round++;
    }
	
	return Plugin_Continue;
}
 
 
public void OnMapStart()
{
    round = -1;
}
 
public bool warden_exists()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && warden_iswarden(i))
        	return true;
    }
    return false;
}
