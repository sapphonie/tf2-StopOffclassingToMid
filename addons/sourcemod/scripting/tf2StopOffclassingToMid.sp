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


#define PLUGIN_VERSION      "0.0.6"

new bool:IsOffClassingAllowed = true;
new playerTeam;

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
    if (LibraryExists("updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}

public Action EventRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
    SetConVarInt(FindConVar("tf_tournament_classlimit_pyro"),       0, false);
    SetConVarInt(FindConVar("tf_tournament_classlimit_heavy"),      0, false);
    SetConVarInt(FindConVar("tf_tournament_classlimit_engineer"),   0, false);
    SetConVarInt(FindConVar("tf_tournament_classlimit_sniper"),     0, false);
    SetConVarInt(FindConVar("tf_tournament_classlimit_spy"),        0, false);
    IsOffClassingAllowed = false;
    CreateTimer(30.0, unlockSlots);
    CPrintToChatAll("{yellowgreen}[OffclassLocker]{white} Locked offclasses for 30 seconds.");
    for(new cl = 1; cl <= MaxClients; cl++)
    {
        if (!IsClientInGame(cl))
        {
            continue;
        }
        CreateTimer(1.0, checkOffclasses, cl);
    }
}

public Action unlockSlots(Handle timer)
{
    SetConVarInt(FindConVar("tf_tournament_classlimit_pyro"),       2, false);
    SetConVarInt(FindConVar("tf_tournament_classlimit_heavy"),      1, false);
    SetConVarInt(FindConVar("tf_tournament_classlimit_engineer"),   1, false);
    SetConVarInt(FindConVar("tf_tournament_classlimit_sniper"),     2, false);
    SetConVarInt(FindConVar("tf_tournament_classlimit_spy"),        2, false);
    IsOffClassingAllowed = true;
    CPrintToChatAll("{yellowgreen}[OffclassLocker]{white} Unlocked offclasses.");
}

// adapted from classrestrict.smx ( https://forums.alliedmods.net/showpost.php?p=2277594&postcount=467 )
public Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
    if (IsOffClassingAllowed)
    {
        return;
    }
    new cl = GetClientOfUserId(GetEventInt(event, "userid"));
    CreateTimer(1.0, checkOffclasses, cl);
}

// adapted from classrestrict.smx ( https://forums.alliedmods.net/showpost.php?p=2277594&postcount=467 )
public Action:checkOffclasses(Handle Timer, cl)
{
    playerTeam = GetClientTeam(cl);
    if (!IsOffClassingAllowed                       &&
        TF2_GetPlayerClass(cl) == TFClass_Pyro      ||
        TF2_GetPlayerClass(cl) == TFClass_Heavy     ||
        TF2_GetPlayerClass(cl) == TFClass_Engineer  ||
        TF2_GetPlayerClass(cl) == TFClass_Sniper    ||
        TF2_GetPlayerClass(cl) == TFClass_Spy
       )
    {
        SetHudTextParams(-1.0, 0.25, 5.0, 255, 255, 255, 255, 1, 2.0, 0.5, 1.0);  // white color
        ShowHudText(cl, -1, "Change off your offclass within 5 seconds or face the consequences...");
        // prevents crashing a server with an infinite loop
        CreateTimer(5.5, KillIdiot, cl);
        ShowVGUIPanel(cl, playerTeam == 3 ? "class_blue" : "class_red");
    }
}

// :)
public Action:KillIdiot(Handle Timer, cl)
{
    if (!IsOffClassingAllowed                       &&
        TF2_GetPlayerClass(cl) == TFClass_Pyro      ||
        TF2_GetPlayerClass(cl) == TFClass_Heavy     ||
        TF2_GetPlayerClass(cl) == TFClass_Engineer  ||
        TF2_GetPlayerClass(cl) == TFClass_Sniper    ||
        TF2_GetPlayerClass(cl) == TFClass_Spy
       )
    {
        SDKHooks_TakeDamage(cl, 0, 0, 9999.9, DMG_CLUB, -1, NULL_VECTOR, NULL_VECTOR);
        CreateTimer(1.0, lolOwned, cl);
    }
}

public Action:lolOwned(Handle Timer, cl)
{
    SetHudTextParams(-1.0, 0.25, 5.0, 255, 255, 255, 255, 1, 2.0, 0.5, 1.0);  // white color
    ShowHudText(cl, -1, "I told you...");
}
