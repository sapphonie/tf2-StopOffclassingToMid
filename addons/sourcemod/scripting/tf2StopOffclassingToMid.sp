#pragma semicolon 1
#include <sourcemod>
#include <morecolors>
#include <tf2_stocks>
#include <sdktools_functions>
#include <sdkhooks>
#include <sdktools>
#undef REQUIRE_PLUGIN
#include <updater>

#define UPDATE_URL	"https://raw.githubusercontent.com/stephanieLGBT/tf2-StopOffclassingToMid/master/updatefile.txt"

#define SCOUT          1
#define SOLDIER        3
#define PYRO           7
#define DEMOMAN        4
#define ENGINEER       9
#define HEAVY          6
#define MEDIC          5
#define SNIPER         2
#define SPY            8
#define UNKNOWN        0

#define PLUGIN_VERSION      "0.0.5"

new bool:IsOffClassingAllowed = true;
new g_playerClass[MAXPLAYERS + 1];
new playerClass;

public Plugin:myinfo =
{
    name        = "Stop Offclassing To Mid",
    author      = "Stephanie",
    description = "You should know better...",
    version     =  PLUGIN_VERSION,
    url         = "https://steph.anie.dev"
}

public OnPluginStart()
{
    HookEvent("teamplay_round_start", EventRoundStart);                         // hooks round start events
    HookEvent("player_spawn", Event_PlayerSpawn);
    if (LibraryExists("updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}

public OnClientPutInServer(client)
{
    g_playerClass[client] = UNKNOWN;
}

public Action EventRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
    CreateTimer(0.5, respPlayers);
    SetConVarInt(FindConVar("tf_tournament_classlimit_pyro"), 0, false);
    SetConVarInt(FindConVar("tf_tournament_classlimit_heavy"), 0, false);
    SetConVarInt(FindConVar("tf_tournament_classlimit_engineer"), 0, false);
    SetConVarInt(FindConVar("tf_tournament_classlimit_sniper"), 0, false);
    SetConVarInt(FindConVar("tf_tournament_classlimit_spy"), 0, false);
    IsOffClassingAllowed = false;
    CreateTimer(30.0, unlockSlots);
    CPrintToChatAll("{green}[OffclassLocker]{white} Locked offclasses for 30 seconds.");
}

public Action respPlayers(Handle timer)
{
    for(new cl = 1; cl <= MaxClients; cl++)
    {
        if (!IsClientInGame(cl))
        {
            continue;
        }
        TF2_RespawnPlayer(cl);
    }
}

public Action unlockSlots(Handle timer)
{
    SetConVarInt(FindConVar("tf_tournament_classlimit_pyro"), 2, false);
    SetConVarInt(FindConVar("tf_tournament_classlimit_heavy"), 1, false);
    SetConVarInt(FindConVar("tf_tournament_classlimit_engineer"), 1, false);
    SetConVarInt(FindConVar("tf_tournament_classlimit_sniper"), 2, false);
    SetConVarInt(FindConVar("tf_tournament_classlimit_spy"), 2, false);
    IsOffClassingAllowed = true;
    CPrintToChatAll("{green}[OffclassLocker]{white} Unlocked offclasses.");
}

// adapted from classrestrict.smx ( https://forums.alliedmods.net/showpost.php?p=2277594&postcount=467 )
public Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
    if (IsOffClassingAllowed)
    {
        return;
    }
    new iClient        = GetClientOfUserId(GetEventInt(event, "userid"));
    playerClass        = GetEventInt(event, "class");
    new playerTeam     = GetClientTeam(iClient);

    if (!IsOffClassingAllowed      &&
        playerClass == PYRO        ||
        playerClass == HEAVY       ||
        playerClass == ENGINEER    ||
        playerClass == SNIPER      ||
        playerClass == SPY
        )
    {
        SetHudTextParams(-1.0, 0.25, 5.0, 255, 255, 255, 255, 1, 2.0, 0.5, 1.0);  // white color
        ShowHudText(iClient, -1, "Change off your offclass within 5 seconds or face the consequences...", playerClass);
        // prevents crashing a server with an infinite loop
        CreateTimer(5.5, KillIdiot, iClient);
        ShowVGUIPanel(iClient, playerTeam == 3 ? "class_blue" : "class_red");
    }
}

// :)
public Action:KillIdiot(Handle Timer, iClient)
{
    if (!IsOffClassingAllowed  &&
    playerClass == PYRO        ||
    playerClass == HEAVY       ||
    playerClass == ENGINEER    ||
    playerClass == SNIPER      ||
    playerClass == SPY
    )
    {
        SDKHooks_TakeDamage(iClient, 0, 0, 9999.9, DMG_CLUB, -1, NULL_VECTOR, NULL_VECTOR);
    }
}
