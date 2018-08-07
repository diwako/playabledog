if!(hasInterface) exitWith {};
params ["_veh"];

if(_veh isKindOf "ace_advanced_throwing_pickUpHelper") exitWith {
  private _action = ["diw_dog_pickUp","Pick up","\a3\ui_f\data\igui\cfg\actions\obsolete\ui_action_takemine_ca.paa",{
    [_target, player] call ace_advanced_throwing_fnc_pickUp;
  },{(player isKindOf 'Dog_Base_F') && {!(player getVariable["diwako_dog_inVehicle",false]) && !(player getVariable ["diwako_dog_isCarried", false]) && {isNull (player getVariable ["ace_advanced_throwing_activeThrowable", objNull])}}}] call ace_interact_menu_fnc_createAction;

  [_veh, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
};

private _action = ["diw_dog_getIn","Get in vehicle","",{
  if(!isNil "visoreh") then {
    switchCamera player;
    camDestroy (missionnamespace getVariable ["personalCam",objNull]);
    personalCam = "camera" camCreate (position player);
    personalCam attachTo [doggo, [0,-1.5,1.25]];
    switchCamera personalCam;
    removeMissionEventHandler ["Draw3D",visoreh];
    visoreh = nil;
  };
  player setVariable["diwako_dog_inVehicle",true,true];
  player setVariable["diwako_dog_vehicle", _target];
  private _attachParams = _target call {
    if(_this isKindOf "Offroad_02_LMG_base_F") exitWith {[[0.25,-1.4,-1.35],90]};
    if(_this isKindOf "Offroad_02_base_F") exitWith {[[0.25,-1.4,-0.7],90]};
    if(_this isKindOf "MRAP_03_base_F") exitWith {[[0.25,0.3,-1],90]};
    if(_this isKindOf "Van_02_base_F") exitWith {[[0,-2,-0.9],180]};
    if(_this isKindOf "Van_01_base_F") exitWith {[[0,-2,-0.6],180]};
    if(_this isKindOf "I_G_Offroad_01_armed_F") exitWith {[[0,-2,-1.25],180]};
    if(_this isKindOf "Offroad_01_base_F") exitWith {[[0,-2,-0.7],180]};
    if(_this isKindOf "Heli_Light_01_armed_base_F") exitWith {[[0,0.6,-0.75],270]};
    if(_this isKindOf "Heli_Light_01_unarmed_base_F") exitWith {[[-0.6,0.7,-0.85],270]};
    if(_this isKindOf "Heli_Transport_01_base_F") exitWith {[[0,3,-1.25],90]};
    if(_this isKindOf "Heli_Transport_03_base_F") exitWith {[[0,1.75,-2.15],180]};
    if(_this isKindOf "B_APC_Wheeled_01_cannon_F") exitWith {[[0,-0.75,-1.25],0]};
    if(_this isKindOf "B_LSV_01_unarmed_F") exitWith {[[0,-0.75,-1.25],0]};
    if(_this isKindOf "LSV_01_armed_base_F") exitWith {[[0,-0.75,-1.25],0]};
    if(_this isKindOf "LSV_01_base_F") exitWith {[[0,-0.75,-0.793305],0]};
    if(_this isKindOf "Truck_02_base_F") exitWith {[[0,-0.65,-0.793305],180]};
    if(_this isKindOf "Truck_01_base_F") exitWith {[[0,-1.5,-0.55],180]};
    if(_this isKindOf "MRAP_01_base_F") exitWith {[[0,-1.75,-0.55],0]};
    if(_this isKindOf "Quadbike_01_base_F") exitWith {[[0.3,0.75,-0.55],90]};
    nil
  };
  if(isNil "_attachParams") exitWith {titleText ["Cannot mount that vehicle as dog","PLAIN DOWN"]};
  _attachParams params ["_pos","_dir"];
  player attachTo [_target,_pos];
  player setDir _dir;
  player playMove "Dog_Sit";
},{(player isKindOf 'Dog_Base_F') && ((damage _target) < 1) && {!(player getVariable["diwako_dog_inVehicle",false]) && !(player getVariable ["diwako_dog_isCarried", false])}}] call ace_interact_menu_fnc_createAction;

[_veh, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;