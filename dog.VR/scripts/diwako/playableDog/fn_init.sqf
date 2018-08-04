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

_action = ["diw_dog_pet","Pet dog","",{
  player playMove "AinvPercMstpSnonWnonDnon_Putdown_AmovPercMstpSnonWnonDnon";
  [[format["You have been petted by %1",name player],"PLAIN DOWN"]] remoteExec ["titleText", _target];
  [{titleText ["You morale has been increased","PLAIN DOWN"]},[],5] call CBA_fnc_waitAndExecute;
},{alive _target}] call ace_interact_menu_fnc_createAction;

["alsatian_black_f", 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToClass;

_action = ["diw_dog_checkhealth","Check health","",{
  player playMove "AinvPercMstpSnonWnonDnon_Putdown_AmovPercMstpSnonWnonDnon";
  [{
    params["_dog"];
    if!(alive _dog) exitWith {titleText ["The dog is dead","PLAIN DOWN"]};
    private _dam = damage _dog;
    if(_dam == 0) exitWith {titleText ["The dog is completely healthy","PLAIN DOWN"]};
    if(_dam < 0.25) exitWith {titleText ["The dog took some damage","PLAIN DOWN"]};
    if(_dam < 0.5 ) exitWith {titleText ["The dog is wounded","PLAIN DOWN"]};
    if(_dam < 0.75 ) exitWith {titleText ["The dog is heavily wounded","PLAIN DOWN"]};
    titleText ["The dog is near death","PLAIN DOWN"];
  },[_target],0.5] call CBA_fnc_waitAndExecute;
},{true}] call ace_interact_menu_fnc_createAction;

["alsatian_black_f", 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToClass;

_action = ["diw_dog_heal","Heal dog","",{
  [player, true, false] call ACE_medical_ai_fnc_playTreatmentAnim;
  [{
    params["_dog"];
    _dog setDamage 0;
    // _dog setVariable ["diw_dog_hit", 0 ,true];
  },[_target],1.5] call CBA_fnc_waitAndExecute;
},{alive _target && {(damage _target) > 0}}] call ace_interact_menu_fnc_createAction;

["alsatian_black_f", 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToClass;