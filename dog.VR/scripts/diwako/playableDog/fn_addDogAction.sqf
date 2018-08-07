if!(hasInterface) exitWith {};
params ["_dog"];
if!(_dog isKindOf "Dog_Base_F") exitWith {};

private _action = ["diw_dog_pet","Pet dog","",{
  player playMove "AinvPercMstpSnonWnonDnon_Putdown_AmovPercMstpSnonWnonDnon";
  [[format["You have been petted by %1",name player],"PLAIN DOWN"]] remoteExec ["titleText", _target];
  [{titleText ["You morale has been increased","PLAIN DOWN"]},[],5] call CBA_fnc_waitAndExecute;
},{alive _target}] call ace_interact_menu_fnc_createAction;

[_dog, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

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
},{(_target getVariable ["diwako_dog", false])}] call ace_interact_menu_fnc_createAction;

[_dog, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_action = ["diw_dog_heal","Heal dog","",{
  [player, true, false] call ACE_medical_ai_fnc_playTreatmentAnim;
  [{
    params["_dog"];
    _dog setDamage 0;
    // _dog setVariable ["diw_dog_hit", 0 ,true];
  },[_target],1.5] call CBA_fnc_waitAndExecute;
},{(_target getVariable ["diwako_dog", false]) && alive _target && {(damage _target) > 0}}] call ace_interact_menu_fnc_createAction;

[_dog, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_action = ["diw_dog_carry","Carry dog","",{
	_target attachTo[player,[-0.15,-0.15,-0.25],"spine3"];
  _target setDir 90;
  _target setVariable ["diwako_dog_isCarried",true,true];
  player setVariable ["diwako_dog_carryDog",true,true];
  [{
    params ["_args", "_idPFH"];
    _args params ["_unit", "_target", "_timeOut"];
    
    if (!alive _target || {!(_unit getVariable ["diwako_dog_carryDog", false]) ||{!(isNull objectParent _unit) || {!(alive _unit) || {(_unit getVariable["ace_unconscious",false])}}}}) then {
      [_unit, _target] call ace_dragging_fnc_dropObject;
      _target setVariable ["diwako_dog_isCarried",false,true];
      _unit setVariable ["diwako_dog_carryDog",false,true];
      [_idPFH] call CBA_fnc_removePerFrameHandler;
    };
  }, 0.2, [player, _target]] call CBA_fnc_addPerFrameHandler;
},{(_target getVariable ["diwako_dog", false]) && alive _target && {!(player getVariable ["diwako_dog_carryDog",false]) && {!(_target getVariable ["diwako_dog_isCarried", false]) && {!(_target getVariable ["diwako_dog_inVehicle", false]) && {!(player isKindOf "Dog_Base_F")}}}}}] call ace_interact_menu_fnc_createAction;

[_dog, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_action = ["diw_dog_checkName","Check dog collar","",{
	private _text = "On the collar it says this dog ";
  if(alive _target) then {
    _text = _text + "is named %1.";
  } else {
    _text = _text + "was named %1.";
  };
  titleText [format[_text, (_target getVariable ["diwako_dog_name", name _target])],"PLAIN DOWN"];
},{(_target getVariable ["diwako_dog_name", ""]) != ""}] call ace_interact_menu_fnc_createAction;

[_dog, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;