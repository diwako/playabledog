if(!hasInterface) exitWith {};
waitUntil { !isNil 'diw_dogInit' };
camDestroy (missionnamespace getVariable ["personalCam",objNull]);
oldPlayer = player;
doggo = (group player) createUnit ["ALSATIAN_BLACK_F", position player, [], 0, "FORM"];
// doggo = (createGroup [east, true]) createUnit ["ALSATIAN_BLACK_F", position player, [], 0, "FORM"];
addSwitchableUnit doggo; selectPlayer doggo;
personalCam = "camera" camCreate (position player);
personalCam attachTo [doggo, [0,-1.5,1.25]];
// personalCam attachTo [doggo, [0,0.3,0],"head"];
switchCamera personalCam;
// deleteVehicle _oldPlayer
doggo enableStamina false;

doggo addEventHandler ["Killed",{
	params ["_unit", "_killer", "_instigator", "_useEffects"];
	if(_unit isKindOf "Dog_Base_F") then {
		switchCamera player;
		detach player;
		camDestroy (missionnamespace getVariable ["personalCam",objNull]);
		if(!isNil "visoreh") then {
			removeMissionEventHandler ["Draw3D",visoreh];
			visoreh = nil;
		};
		if(!isNil "diw_dog_mouse_eh") then {
			removeMissionEventHandler ["MouseButtonDown",diw_dog_mouse_eh];
			diw_dog_mouse_eh = nil;
		};
		player enableStamina true;
		playSound3D [MISSION_ROOT + "scripts\diwako\playableDog\sounds\bdog_die_"+ str (floor random 3) +".ogg",_unit,false,getPosATL _unit,2,1,100];
		selectPlayer oldPlayer;
		oldPlayer setDamage 1;
	};
}];

// get rid of ace medical
[{
	doggo removeAllEventHandlers "HandleDamage";
	doggo addEventHandler ["HandleDamage",{
		private _dog = _this select 0;
		if(!alive _dog) exitWith {};
		private _source	= _this select 3;
		private _projectile = _this select 4;
		private _hits = _dog getVariable ["diw_dog_hit",0];
		if ((_projectile != '') and !(isnull _source )) then {
			_hits = _hits + 1;
			if (_hits > diw_dog_max_hit) then {
          		_dog setdamage 1;
        	};
			if((alive _dog) && ((missionNamespace getVariable ['diw_dogBark',(time-1)]) < time)) then {
				diw_dogBark = time + 1.5  + (random 1);
				[_dog, "hurt_" + str( (floor random 2) + 1 )] remoteExec ["say3D"];
			};
			_dog setVariable ["diw_dog_hit",_hits,true];
		};
		0
	}];
	systemChat "damage handler applied";
},[],2] call CBA_fnc_waitAndExecute;

diw_dog_mouse_eh = findDisplay 46 displayAddEventHandler ["MouseButtonDown", {
	private _key = (_this select 1);

	// mouse 1
	if (_key == 0) then {
		if(player getVariable["diwako_dog_inVehicle",false]) exitWith {};
		if((missionNamespace getVariable ['diw_bitetime',(time-1)]) > time) exitWith {};
		diw_bitetime = time + 1;

		private _pos = player modelToWorld [0,2,-1];
		private _units = (allUnits - [player]) inAreaArray [_pos, 2, 2, (getdir player) + 45, true, 3];
		private _target = objNull;
		{
			if(alive _x && (_x isKindOf "CAManBase") && {((_x distance player) < 2.5)}) exitWith {
				_target = _x;
			};
			false
		} count _units;
		if(alive doggo && !(isNull _target) && {isNull objectParent _target}) then {
			systemChat "chompped!";

			private _sel = [
			"head", 0.1,
			"body", 0.1,
			"hand_l", 0.2,
			"hand_r", 0.2,
			"leg_l", 0.2,
			"leg_r", 0.2
			] call BIS_fnc_selectRandomWeighted;

			private _dam = 0.2 + random (switch (_sel) do {
			case "head": {0.2};
			case "body": {0.4};
			case "leg_l";
			case "leg_r";
			case "hand_l";
			case "hand_r"; {0.5};
			default {0}
			});
			_dam = _dam * (missionNamespace getVariable ["ace_medical_playerDamageThreshold", 1]);
			[_target, _dam, _sel, "stab"] remoteExec ["ace_medical_fnc_addDamageToUnit", _target];
			[_target,"MIDDLE"] remoteExec ["setUnitPos",_target];
			[{
				params ["_target"];
				_snd = selectRandom ["WoundedGuyB_05", "WoundedGuyB_06", "WoundedGuyB_07","WoundedGuyB_08","WoundedGuyA_08","WoundedGuyA_07","WoundedGuyA_06"];
				[_target, [_snd,100,1]] remoteExecCall ["say3D"];
				if(random 2 < 1) then {
					// 50% chance to knock unit out
					[_target, true,round(random(15)+5),true] call ace_medical_fnc_setUnconscious;
				}
			}, [_target], 0.2] call CBA_fnc_waitAndExecute;
		};
	};

	// right click
	if (_key == 1) then {
		if((missionNamespace getVariable ['diw_dogBark',(time-1)]) > time) exitWith {};
		diw_dogBark = time + 1.5  + (random 1);
		[player, ["bark_" + str( (floor random 4) + 1 ),150,1]] remoteExec ["say3D"];
	};

	// middle click
	if (_key == 2) then {
		if((missionNamespace getVariable ['diw_dogBark',(time-1)]) > time) exitWith {};
		diw_dogBark = time + 1.5  + (random 1);
		[player, ["idle_" + str (floor random 5),50,1]] remoteExec ["say3D"];
	};
	systemChat str _this;
	false
}];

visorTargets = [];
visorMines = [];

[] spawn {
	while {player isKindOf "Dog_Base_F"} do {
		// private _men = entities "CAManBase";
		private _men = entities  [["CAManBase"], [], true, false];
		visorTargets = _men select { (player distance _x) < 300};
		// private _men = player nearEntities [["CAManBase"], 300];
		// visorTargets = _men select { alive _x };
		visorMines = allMines select { (player distance2D _x) <= 25};
		sleep 5;
	};
};

[oldPlayer,true] remoteExec ["hideObjectGlobal", 2, oldPlayer];