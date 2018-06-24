// include:
#include <sourcemod>
#include <sdktools>
#include <cstrike>

public Plugin myinfo =
{
        name = "Ratio Plugin",
        author = "CmAnT",
        description = "Prevents the players from breaking ratio.",
        version = "1.0.0",
        url = "tangoworldwide.net"
};

// global vars:
int round;

// define:
#define prefix "[\x02Ratio\x01]"

public void OnPluginStart()
{
	HookEvent("player_team", Event_Swap, EventHookMode_Pre);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_Post);
}

// when someone swaps to CT:
public Action Event_Swap(Event event, const char[] name, bool dontBroadcast) // event template
{
	int team = GetEventInt(event, "team");
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (team == CS_TEAM_CT)
	{
		if (GetTeamClientCount(CS_TEAM_T) == 0)
		{
			PrintToChat(client, "%s Ratio is still broken. You have been swapped back to T.", prefix);
			ChangeClientTeam(client, CS_TEAM_T)
		}
	
		else if (BreaksRatio())
		{
			PrintToChat(client, "%s Ratio is still broken. You have been swapped back to T.", prefix);
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}


public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if ( GameRules_GetProp("m_bWarmupPeriod") != 1 ) // IF ITS NOT A WARMUP
    {
    	round++;
    }

	if ( BreaksRatio() )
	{
		int minScore, client;
		
		for (int i = 1; i <= MaxClients; i++ ) // to get the lowest score on the CT team
		{
			if (isValidClient(i))
			{
				if ((GetClientTeam(i) == CS_TEAM_CT ) && (CS_GetClientContributionScore(i) < minScore))
				{
					minScore = CS_GetClientContributionScore(i);
					client = i;
				}
			}	
		}
		
		if ( round > 2 )
		{
			PrintToChat(client, "%s You have been swapped due to having the lowest score on the CT team.", prefix);
			ChangeClientTeam(client, 2)
		}
	}
	
	return Plugin_Continue;
}

public bool BreaksRatio()
{
	return ((GetTeamClientCount(CS_TEAM_T) - 1 / GetTeamClientCount(CS_TEAM_CT) + 1) < 2);
}

public void OnMapStart()
{
    round = -1;
}

public bool isValidClient(int client)
{
	return (IsClientConnected(client) && !(IsFakeClient(client)));
}
