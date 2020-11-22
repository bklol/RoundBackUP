#pragma semicolon 1

#include <sourcemod>
#include <cstrike>
#include <sdktools>

char FilePath[128];

public OnPluginStart()
{
	HookEvent("round_prestart", Event_RoundStart);
	BuildPath(Path_SM, FilePath, sizeof(FilePath), "data/nekomtachbackup");	
	if (!DirExists(FilePath))
		CreateDirectory(FilePath, 511);
	RegConsoleCmd("sm_r",OpenBackUpFile);
}

public Action OpenBackUpFile(int client,int ages)
{
	OP(client);
}


void OP(int client)
{
	Menu menu = new Menu(Handler_MainMenu);
	menu.SetTitle("选择回合来回档");
	char buffer[1024];	
	for (int i = 0; i < 16; i++)
	{
		Format(buffer,"%s/rounds%i.ini",FilePath,i)
		if (!FileExists(buffer))
			menu.AddItem("0", buffer);
	}
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_MainMenu(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		//....
		AnylizeAndRestart();
	}
}

void AnylizeAndRestart(char[] RoundFile)
{
	char lineBuffer[1280];
	char buffer[64][20];
	
	Handle fileHandle = OpenFile(RoundFile,"r");
	while(!IsEndOfFile(fileHandle) && ReadFileLine(RoundFile, lineBuffer, sizeof(lineBuffer)))
	{
		ExplodeString(lineBuffer,",",buffer,20,64);
		//......
	}
}

public Action Event_RoundStart(Event ev, const char[] name, bool dbc)
{
	if(GameRules_GetProp("m_bWarmupPeriod") != 1)
	{
		LogAllPlayer();
	}
}

stock void LogAllPlayer()
{
	int CT_SCORE = CS_GetTeamScore(CS_TEAM_CT);
	int T_SCORE = CS_GetTeamScore(CS_TEAM_T);
	char RoundFile[128];
	Format(RoundFile,128,"%s/rounds%i.ini",FilePath,CT_SCORE + T_SCORE,CT_SCORE,T_SCORE);
	
	char buf[30],buffer[1024],g_szAuth64[64];
	Handle fileHandle = OpenFile(RoundFile, "w+");
	for (int client = 1; client <= MaxClients; client++)
	{
		if(IsValidClient(client))
		{
			GetClientAuthId(client, AuthId_SteamID64, g_szAuth64, sizeof(g_szAuth64));
			Format(buffer,sizeof(buffer),"%s",g_szAuth64);
			
			int m_iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
			Format(buffer,sizeof(buffer),"%s,%i",buffer,m_iAccount);

			int m_iTeam = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iTeam", _, client);
			Format(buffer,sizeof(buffer),"%s,%i",buffer,m_iTeam);
			
			int m_iKills = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iKills", _, client);
			Format(buffer,sizeof(buffer),"%s,%i",buffer,m_iKills);

			int m_iAssists = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iAssists", _, client);
			Format(buffer,sizeof(buffer),"%s,%i",buffer,m_iAssists);	
				
			int m_iDeaths = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iDeaths", _, client);
			Format(buffer,sizeof(buffer),"%s,%i",buffer,m_iDeaths);

			int m_iMVPs = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iMVPs", _, client);
			Format(buffer,sizeof(buffer),"%s,%i",buffer,m_iMVPs);
				
			int m_iScore = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iScore", _, client);
			Format(buffer,sizeof(buffer),"%s,%i",buffer,m_iScore);

			for(int i = 0; i < GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons"); i++)
			{
				int ent = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
				if(ent!= -1 && GetEntProp(ent, Prop_Send, "m_iPrimaryAmmoType") != -1)
				{
					GetEntityClassname(ent, buf, sizeof(buf));
					Format(buffer,sizeof(buffer),"%s,%s",buffer,buf);
				}
			}
			WriteFileLine(fileHandle, buffer, sizeof(buffer));
		}
	}
	PrintToServer("SUCCESS BACK UP RONUD %i (%i:%i)",CT_SCORE + T_SCORE,CT_SCORE,T_SCORE);
}

stock bool IsValidClient( client )
{
	if ( client < 1 || client > MaxClients ) return false;
	if ( !IsClientConnected( client )) return false;
	if ( !IsClientInGame( client )) return false;
	if ( IsFakeClient(client)) return false;
	return true;
}