if(!isNil "diwako_dogInit") exitWith {};

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

// ["isNotDog", {player isKindOf "CAManBase"}] call ace_common_fnc_addCanInteractWithCondition;