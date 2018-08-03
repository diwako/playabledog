[] spawn {
	waituntil {!(IsNull (findDisplay 46))};
	private _keyDown = (findDisplay 46) displayAddEventHandler ["KeyDown", {
		if!(player isKindOf 'Dog_Base_F') exitWith {};
		params ["_control", "_key", "_shift", "_ctrl", "_alt"];
		// e
		if(_key == 18) exitWith {

		};

		// q
		if(_key == 16) exitWith {

		};
	}];
	diw_dogInit = true;
};
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

private _action = ["diw_dog_getOut","Get out vehicle","",{
	player setVariable["diwako_dog_inVehicle",false,true];
	private _pos = (player getVariable "diwako_dog_vehicle") modelToWorld [5,0,0];
	detach player;
	player setPosATL _pos;
},{player getVariable["diwako_dog_inVehicle",false]}] call ace_interact_menu_fnc_createAction;

["alsatian_black_f", 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToClass;

_action = ["diw_dog_howl","Howl","",{
	diw_dogBark = time + 10;
	player playmove "Dog_Idle_Growl";
	[player, ["howl" + str(floor random 2),500,1]] remoteExec ["say3D"];
},{((missionNamespace getVariable ['diw_dogBark',(time-1)]) < time) && !(player getVariable["diwako_dog_inVehicle",false])}] call ace_interact_menu_fnc_createAction;

["alsatian_black_f", 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToClass;

_action = ["diw_dog_sit","Sit down","",{
	player playMove "Dog_Sit";
},{true}] call ace_interact_menu_fnc_createAction;

["alsatian_black_f", 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToClass;

_action = ["diw_dog_excited","Get Excited","",{
	player playMove "Dog_Idle_Bark";
	[player, "idle_" + str (floor random 2)] remoteExec ["say3d"];
	[player, "idle_" + str ((floor random 3) + 2)] remoteExec ["say3d"];
},{!(player getVariable["diwako_dog_inVehicle",false])}] call ace_interact_menu_fnc_createAction;

["alsatian_black_f", 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToClass;

_action = ["diw_turn_off_smellovision","Disable Smell-o-Vison","",{
	removeMissionEventHandler ["Draw3D",visoreh];
	switchCamera personalCam;
	visoreh = nil;
},{!isNil 'visoreh'}] call ace_interact_menu_fnc_createAction;

["alsatian_black_f", 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToClass;

_action = ["diw_dog_growl","Growl","",{
	player playMoveNow "Dog_Idle_Growl";
},{((missionNamespace getVariable ['diw_dogBark',(time-1)]) < time) && !(player getVariable["diwako_dog_inVehicle",false])}] call ace_interact_menu_fnc_createAction;

["alsatian_black_f", 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToClass;

_action = ["diw_turn_on_smellovision","Enable Smell-o-Vison","",{
	switchCamera player;
	diw_dog_human_color = [
		[1,0.6,0,1],
		[1,1,1,1]
	];
	visoreh = addMissionEventHandler ["Draw3D",{
		private _posIcon = [0,0,0];
		{
			private _alive = (alive _x);
			_posIcon = _x modelToWorldVisual (_x selectionPosition "pelvis");
			drawIcon3D ["\A3\ui_f\data\map\markers\military\triangle_CA.paa", diw_dog_human_color select _alive, _posIcon, 0.5, 0.5, 0, ["Human (dead)","Human"] select _alive];
			false
		} count visorTargets;
		{
			_posIcon = getPosATLVisual _x;
			drawIcon3D ["\A3\ui_f\data\map\vehicleicons\iconExplosiveAP_ca.paa", [1,0,0,1], _posIcon, 1, 1, 0, "Explosive"];
			false
		} count visorMines;
	}];
},{isNil 'visoreh' && !(player getVariable["diwako_dog_inVehicle",false])}] call ace_interact_menu_fnc_createAction;

["alsatian_black_f", 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToClass;

_action = ["diw_dog_fixcamera","Fix camera","",{
	switchCamera player;
	camDestroy (missionnamespace getVariable ["personalCam",objNull]);
	personalCam = "camera" camCreate (position player);
	personalCam attachTo [doggo, [0,-1.5,1.25]];
	// personalCam attachTo [doggo, [0,0.3,0],"head"];
	switchCamera personalCam;
	if(!isNil "visoreh") then {
		removeMissionEventHandler ["Draw3D",visoreh];
		visoreh = nil;
	};
},{true}] call ace_interact_menu_fnc_createAction;

["alsatian_black_f", 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToClass;

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