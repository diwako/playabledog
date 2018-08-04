if(isNil "MISSION_ROOT") then {
  if(isDedicated) then {
	MISSION_ROOT = "mpmissions\__CUR_MP." + worldName + "\";
  }
  else
  {
	MISSION_ROOT = str missionConfigFile select [0, count str missionConfigFile - 15];
  };
};

if(isServer) then {
	diw_dog_max_hit = 5;
	publicVariable "diw_dog_max_hit";
};

if(!hasInterface) exitWith {};

[] spawn {
	waituntil {!(IsNull (findDisplay 46))};
	diwako_dogInit = true;
};

_action = ["diw_dog_pet","Pet dog","",{
	player playMove "AinvPercMstpSnonWnonDnon_Putdown_AmovPercMstpSnonWnonDnon";
	[[format["You have been petted by %1",name player],"PLAIN DOWN"]] remoteExec ["titleText", _target];
	[{titleText ["You morale has been increased","PLAIN DOWN"]},[],5] call CBA_fnc_waitAndExecute;
},{alive _target}] call ace_interact_menu_fnc_createAction;

["alsatian_black_f", 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToClass;

_action = ["diw_dog_heal","Heal dog","",{
	_tartget setDamage 0;
	_tartget setVariable ["diw_dog_hit",0,true];
},{alive _target}] call ace_interact_menu_fnc_createAction;

["alsatian_black_f", 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToClass;