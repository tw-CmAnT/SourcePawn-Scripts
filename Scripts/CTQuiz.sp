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
 
public void OnPluginStart()
{
    HookEvent("player_team", Event_SwapTeam, EventHookMode_Pre);
   
    BuildPath(Path_SM, g_sQuestionPath, sizeof(g_sQuestionPath), "configs/ctquiz_questions.cfg");
    g_alQuestions = CreateArray();
    
    g_cvBanTime = CreateConVar("ctquiz_ctban_time", "10", "For how long the client is going to be ctbanned after answering incorrectly.", _,true, 1.0);
    AutoExecConfig(true, "ctquiz");
    
    if (!LoadQuestions())
    {
        SetFailState("Unable to locate Questions.cfg at %s", g_sQuestionPath);
    }
}
 
public Action Event_SwapTeam(Event event, const char[] name, bool dontBroadcast)
{
    int team = event.GetInt("team");
    if (team == CS_TEAM_CT)
    {
        int client = GetClientOfUserId(event.GetInt("userid"));
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

        if (StrEqual(info, "correct", false))
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
    	if (param2 == MenuCancel_Timeout)
   		{
   			Punish(param1);
   		}
    	else if (param2 == MenuCancel_Interrupted)
    	{
    		PrintToChat(param1, "%s You have opened another menu. You have been swapped back to T.", PLUGIN_PREFIX);
    		ForcePlayerSuicide(param1);
    		CS_SwitchTeam(param1, CS_TEAM_T);
  		}
  	}
    else if (action == MenuAction_End)
    {
        delete menu;
    }
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
