if!(hasInterface) exitWith {};
params ["_unit"];
if!(_unit isKindOf "CAManBase") exitWith {};

_action = ["diw_dog_lick","Lick hand","",{
  diw_dogBark = time + 5;
  player playmove "Dog_Idle_Growl";
  [player, _target, 0] call ace_interaction_fnc_tapShoulder;
  [[format["A dog licked your hand"],"PLAIN DOWN"]] remoteExec ["titleText", _target];
},{alive _target && {(player isKindOf "Dog_Base_F") && {(missionNamespace getVariable ['diw_dogBark',(time-1)]) < time}}}] call ace_interact_menu_fnc_createAction;

[_unit, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_action = ["diw_dog_drag","Drag","",{
  player playmove "Dog_Idle_Growl";
  player setVariable ["diwako_dog_dragging",true,true];
  [player, _target, true] call ace_common_fnc_claim;
  _target setDir (getDir player);
  _target setPosASL (getPosASL player vectorAdd (vectorDir player vectorMultiply 1.5));
  [_target, "AinjPpneMrunSnonWnonDb_grab", 2, true] call ace_common_fnc_doAnimation;
  _target attachTo [player,[0.25,0.2,0]];
  player setVariable ["diwako_dog_draggedObject",_target];
  [_target, "AinjPpneMrunSnonWnonDb_still", 0, true] call ace_common_fnc_doAnimation;
  [{
    params ["_args", "_idPFH"];
    _args params ["_unit", "_target", "_timeOut"];

    if !(_unit getVariable ["diwako_dog_dragging", false]) exitWith {
      [_idPFH] call CBA_fnc_removePerFrameHandler;
    };
    
    if (!alive _target || {_unit distance _target > 10 || {!(_unit getVariable["ACE_isUnconscious",false])}}) then {
      [_unit, _target] call ace_dragging_fnc_dropObject;
      _unit setVariable ["ace_dragging_isDragging", true, true];
      _unit setVariable ["diwako_dog_dragging",false,true];
      [_idPFH] call CBA_fnc_removePerFrameHandler;
    };
  }, 0.2, [player, _target]] call CBA_fnc_addPerFrameHandler;
},{alive _target && {(player isKindOf "Dog_Base_F") && {(_target getVariable ["ACE_isUnconscious",false]) && {!([_target] call ace_medical_fnc_isBeingCarried) && {!([_target] call ace_medical_fnc_isBeingDragged)}}}}}] call ace_interact_menu_fnc_createAction;

[_unit, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;