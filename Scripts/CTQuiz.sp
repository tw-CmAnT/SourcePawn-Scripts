#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <ctban>

#define PLUGIN_PREFIX "[\x0FCTQuiz\x01]"

public Plugin myinfo =
{
    name = "CTQuiz",
    author = "CmAnT",
    description = "Asks a question when someone swaps to CT in order to reduce the amount of rule breakers on CT.",
    version = "1.0",
    url = "git.tangoworldwide.net/cmant"
};

ConVar g_cvBanTime;
char g_sQuestionPath[PLATFORM_MAX_PATH];
ArrayList g_alQuestions;
bool g_bConfirmed[MAXPLAYERS + 1];
char g_cChoice[MAXPLAYERS + 1][8];
 
public void OnPluginStart()
{
    HookEvent("player_team", Event_SwapTeam, EventHookMode_Pre);
    
    if (IsLateNight())
  	{
  		BuildPath(Path_SM, g_sQuestionPath, sizeof(g_sQuestionPath), "configs/ctquiz/ctquiz_questions_latenight.cfg");
  	}
    else
	{
		BuildPath(Path_SM, g_sQuestionPath, sizeof(g_sQuestionPath), "configs/ctquiz/ctquiz_questions_regular.cfg");
	}
	g_alQuestions = CreateArray();
	
	g_cvBanTime = CreateConVar("ctquiz_ctban_time", "10", "For how long the client is going to be ctbanned after answering incorrectly.", _,true, 1.0);
	AutoExecConfig(true, "ctquiz");
	
	if (!LoadQuestions())
    {
        SetFailState("Unable to locate ctquiz_questions.cfg at %s", g_sQuestionPath);
    }
}
 
public Action Event_SwapTeam(Event event, const char[] name, bool dontBroadcast)
{
    int team = event.GetInt("team");
    if (team == CS_TEAM_CT)
    {
        int client = GetClientOfUserId(event.GetInt("userid"));
        PrintToChat(client, "%s In order to join CT, you must answer the question given to you.", PLUGIN_PREFIX);
        ShowQuestionMenu(client);
    }
}
 
public int MenuHandler_Question(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        char info[64];
        char display[64];
        if (!menu.GetItem(param2, info, sizeof(info), _, display, sizeof(display)))
        {
            return;
        }
        
        strcopy(g_cChoice[param1], sizeof(g_cChoice[]), info);
        ShowConfirmMenu(param1);
    }
    else if (action == MenuAction_Cancel)
    {
    	if (param2 == MenuCancel_Timeout)
   		{
   			Punish(param1);
   		}
    	else if (param2 == MenuCancel_Interrupted)
    	{
    		PrintToChat(param1, "%s You have opened another menu. You have been swapped back to T.", PLUGIN_PREFIX);
    		SwapClient(param1);
  		}
  	}
    else if (action == MenuAction_End)
    {
        delete menu;
    }
}

public int MenuHandler_Confirm(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        char info[10];
        char display[10];
        if (!menu.GetItem(param2, info, sizeof(info), _, display, sizeof(display)))
        {
            return;
        }
        
        if (StrEqual(info, "y", false))
        {
            g_bConfirmed[param1] = true;
        }
        else
        {
            SwapClient(param1);
            g_bConfirmed[param1] = false;
            PrintToChat(param1, "%s You have been swapped back to T.", PLUGIN_PREFIX);
            return;
        }
        
        if (StrEqual(g_cChoice[param1], "correct", false))
        {
            PrintToChat(param1, "%s You're \x04correct\x01, you may join CT now.", PLUGIN_PREFIX);
        }
        else
        {
            Punish(param1);
        }
    }
    else if (action == MenuAction_Cancel)
    {
    	SwapClient(param1);
    	g_bConfirmed[param1] = false;
  	}
    else if (action == MenuAction_End)
    {
        delete menu;
    }
}

void ShowConfirmMenu(int client)
{
	Menu menu = new Menu(MenuHandler_Confirm);
	menu.SetTitle("Are you sure thats the right answer?");
	menu.AddItem("y", "Yes");
	menu.AddItem("n", "No");
	menu.ExitButton = false;
	menu.Display(client, 20);
}

void ShowQuestionMenu(int client)
{
    StringMap sm = GetRandomQuestion();
    char title[128];
    sm.GetString("question", title, sizeof(title));
   
    Menu menu = new Menu(MenuHandler_Question);
    menu.SetTitle(title);
    
    char incorrect[3][128], correct[64];
    sm.GetString("correct", correct, sizeof(correct));
   	
    for (int i = 0; i < 3; i++)
    {
        char key[2];
        IntToString(i, key, sizeof(key));
        sm.GetString(key, incorrect[i], 128);
        menu.AddItem("incorrect", incorrect[i]);
    }
   
    int random = GetRandomInt(0, 3);
    if (random == 3)
    {
        menu.AddItem("correct", correct);
    }
    else
    {
        menu.InsertItem(random, "correct", correct);
    }
    
    menu.ExitButton = false;
    menu.Display(client, 20);
}
 
bool LoadQuestions()
{
    bool exists = false;
    if (FileExists(g_sQuestionPath))
    {
        exists = true;
        KeyValues kvQuestion = new KeyValues("Questions");
       
        // Import the key values from the config
        kvQuestion.ImportFromFile(g_sQuestionPath);
       
        // Read the questions + answers from g_sQuestionPath
        if (kvQuestion.GotoFirstSubKey(true))
        {
            do
            {
                StringMap map = CreateTrie();
                kvQuestion.SavePosition();
                char question[128];
                kvQuestion.GetSectionName(question, sizeof(question));
                map.SetString("question", question);
                if (kvQuestion.GotoFirstSubKey(false))
                {
                    do
                    {
                        char info[10], answer[64];
                        kvQuestion.GetSectionName(info, sizeof(info));
                        kvQuestion.GetString(NULL_STRING, answer, sizeof(answer), "NULL");
                        map.SetString(info, answer);
                    } while (kvQuestion.GotoNextKey(false));
                    g_alQuestions.Push(map);
                }
                kvQuestion.GoBack();
            } while (kvQuestion.GotoNextKey(false));
        }
        delete kvQuestion;
       
    }
    return exists;
}
 
StringMap GetRandomQuestion()
{
    return g_alQuestions.Get(GetRandomInt(0, g_alQuestions.Length - 1));
}
 
void Punish(int client)
{
    PrintToChat(client, "%s You answered \x02Incorrectly\x01. You can try to join CT again in %d mins.", PLUGIN_PREFIX, g_cvBanTime.IntValue);
    CTBan_Client(client, g_cvBanTime.IntValue, _, "CT Quiz - Failed quiz");
}

bool IsLateNight()
{
	char timeBuf[4];
	FormatTime(timeBuf, sizeof(timeBuf), "%H");
	int hour = StringToInt(timeBuf);

	return hour > 20 && hour < 5;
}

void SwapClient(int client)
{
	ForcePlayerSuicide(client);
	CS_SwitchTeam(client, CS_TEAM_T);
	g_bConfirmed[client] = false;
}
