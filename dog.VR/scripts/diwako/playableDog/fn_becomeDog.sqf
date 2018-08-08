if(!hasInterface) exitWith {};
params[["_type","random"],["_owner",objNull],["_name",(name player)],["_allowNvg",true]];
waitUntil { !isNil 'diwako_dogInit' };

if(_type == "random") then {
  if(floor (random 2) == 0) then {
    _type = "Alsatian_Random_F";
  }else{
    _type = "Fin_random_F";
  };
};

camDestroy (missionnamespace getVariable ["personalCam",objNull]);
oldPlayer = player;
doggo = (group player) createUnit [_type, position player, [], 0, "FORM"];
// doggo = (createGroup [east, true]) createUnit ["ALSATIAN_BLACK_F", position player, [], 0, "FORM"];
doggo setVariable ["diwako_dog", true, true];
doggo setVariable ["diwako_dog_name", _name, true];
addSwitchableUnit doggo;
selectPlayer doggo;
doggo setVariable ["BIS_fnc_animalBehaviour_disable", true, true];
personalCam = "camera" camCreate (position player);
personalCam attachTo [doggo, [0,-1.5,1.25]];
// personalCam attachTo [doggo, [0,0.3,0],"head"];
switchCamera personalCam;
doggo enableStamina false;
doggo setVariable ["diwako_dog_owner",_owner,true];

doggo addEventHandler ["Killed",{
  params ["_unit", "_killer", "_instigator", "_useEffects"];
  if(_unit isKindOf "Dog_Base_F") then {
    switchCamera player;
    detach player;
    camDestroy (missionnamespace getVariable ["personalCam",objNull]);
    deleteVehicle (missionnamespace getVariable ["diwako_dog_drone",objNull]);
    if(!isNil "visoreh") then {
      removeMissionEventHandler ["Draw3D",visoreh];
      visoreh = nil;
    };
    if(!isNil "diw_dog_mouse_eh") then {
      (findDisplay 46) displayRemoveEventHandler ["MouseButtonDown",diw_dog_mouse_eh];
      diw_dog_mouse_eh = nil;
    };
    if(!isNil "diw_dog_key_eh") then {
      (findDisplay 46) displayRemoveEventHandler ["KeyDown",diw_dog_key_eh];
      diw_dog_key_eh = nil;
    };
    player enableStamina true;
    playSound3D [MISSION_ROOT + "scripts\diwako\playableDog\sounds\bdog_die_"+ str (floor random 3) +".ogg",_unit,false,getPosATL _unit,2,1,100];
    false setCamUseTi 0;
    camUseNVG false;
    selectPlayer oldPlayer;
    diwako_dog_nvg = false;
    deleteVehicle attachEnemy;
    oldPlayer setDamage 1;
  };
}];

// get rid of ace medical also disable all other actions
[{
  doggo removeAllEventHandlers "HandleDamage";
  doggo addEventHandler ["HandleDamage",{
    params ["_dog", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];
    if!(alive _dog) exitWith {1};
    if(isNil "diwako_dog_last_hit") then {
      diwako_dog_last_hit = -1;
    };
    if(_damage > 10 || {_damage > 0.1 && ((diwako_dog_last_hit + 0.5) < time)}) then {
      diwako_dog_last_hit = time;
      if((missionNamespace getVariable ['diw_dogBark',-1]) < time) then {
        diw_dogBark = time + 1.5  + (random 1);
        [_dog, "hurt_" + str( (floor random 2) + 1 )] remoteExec ["say3D"];
      };
      [_damage] spawn {
        params["_damage"];
        private _effect = [_damage];
        if(isNil "diwako_dog_damage_blur") then {
          private _name = "DynamicBlur";
          private _priority = 400;
          diwako_dog_damage_blur = ppEffectCreate [_name, _priority];
          while {
            diwako_dog_damage_blur < 0
          } do {
            _priority = _priority + 1;
            diwako_dog_damage_blur = ppEffectCreate [_name, _priority];
          };
          diwako_dog_damage_blur ppEffectEnable true;
        };
        diwako_dog_damage_blur ppEffectAdjust _effect;
        diwako_dog_damage_blur ppEffectCommit 0;
        diwako_dog_damage_blur ppEffectAdjust [0];
        diwako_dog_damage_blur ppEffectCommit 0.5;
      };
      if(_damage > 10) then {
        [] spawn {
          if(isNil "diwako_dog_damage_blink") then {
            private _name = "ColorCorrections";
            private _priority = 400;
            diwako_dog_damage_blink = ppEffectCreate [_name, _priority];
            while {
              diwako_dog_damage_blink < 0
            } do {
              _priority = _priority + 1;
              diwako_dog_damage_blink = ppEffectCreate [_name, _priority];
            };
            diwako_dog_damage_blink ppEffectEnable true;
          };
          _h1 = 0.24;
          _h2 = 0.24;
          for "_i" from 0 to 75 step 1 do {
            _h1 = _h1 + 0.01;
            _h2 = _h2 + 0.01;
            diwako_dog_damage_blink ppEffectAdjust [1,1,0,[0,0,0,1],[1,1,1,1],[0.33,0.33,0.33,0],[_h1,_h2,0,0,0,0,4]];
            diwako_dog_damage_blink ppEffectCommit 0;
            sleep 0.01;
          };
          diwako_dog_damage_blink ppEffectAdjust [1,1,0,[0,0,0,0],[1,1,1,1],[0.33,0.33,0.33,0],[0,0,0,0,0,0,4]];
          diwako_dog_damage_blink ppEffectCommit 0;
        };
      };
    };

    (damage _dog + (_damage / 50))
  }];
  doggo setVariable ["ace_dragging_isDragging",true,true];
},[],2] call CBA_fnc_waitAndExecute;

diw_dog_mouse_eh = (findDisplay 46) displayAddEventHandler ["MouseButtonDown", {
  if!(alive doggo) exitWith {};
  private _key = (_this select 1);

  // mouse 1 - Bite
  if (_key == 0) then {
    if((player getVariable["diwako_dog_inVehicle",false]) || (player getVariable ["diwako_dog_dragging", false])) exitWith {};
    if((missionNamespace getVariable ['diw_bitetime',-1]) > time) exitWith {};
    if!(isNull (player getVariable ["ace_advanced_throwing_activeThrowable", objNull])) exitWith {};
    diw_bitetime = time + 1;

    private _pos = player modelToWorld [0,2,-1];
    private _units = ((entities  [["Man"], [], true, false]) - [player]) inAreaArray [_pos, 2, 2, (getdir player) + 45, true, 3];
    // private _units = (allUnits - [player]) inAreaArray [_pos, 2, 2, (getdir player) + 45, true, 3];
    private _target = objNull;
    {
      if(alive _x && (_x isKindOf "Man") && {((_x distance player) < 2.5)}) exitWith {
        _target = _x;
      };
      false
    } count _units;
    if(!(isNull _target) && {isNull objectParent _target}) then {
      systemChat "chompped!";
      if(_target isKindOf "CAManBase") then {
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
      } else {
        private _dam = _target call {
          if(_this isKindOf "Fowl_Base_F") exitWith {1};
          if(_this isKindOf "Dog_Base_F") exitWith {0.1};
          if(_this isKindOf "Goat_Base_F") exitWith {0.25};
          if(_this isKindOf "Sheep_random_F") exitWith {0.25};
          1
        };
        _target setDamage ((damage _target) + _dam);
      };
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
  false
}];

diw_dog_key_eh = (findDisplay 46) displayAddEventHandler ["KeyDown", {
  if!(player isKindOf 'Dog_Base_F') exitWith {};
  if(player getVariable ["diwako_dog_dragging", false]) exitWith {};
  params ["_control", "_key", "_shift", "_ctrl", "_alt"];
  if(_key in actionKeys "nightVision" && {doggo getVariable ["diwako_dog_allowNvg", false] && {(missionNamespace getVariable ["diwako_dog_nvg_time",(time-0.5)]) < time}}) then {
    if(isNil "diwako_dog_nvg") then {
      diwako_dog_nvg = false;
    };
    // epilepsi begone, kind of
    diwako_dog_nvg_time = time + 0.5;
    diwako_dog_nvg = !diwako_dog_nvg;
    camUseNVG diwako_dog_nvg;
    playSound "RscDisplayCurator_visionMode";
  };

  // e
  if(_key == 18) then {
    player setPosATL (player modelToWorld [0,1,0]);
  };

  // q
  if(_key == 16) then {

  };
}];

visorTargets = [];
visorMines = [];
visorAnimals = [];

[] spawn {
  while {player isKindOf "Dog_Base_F"} do {
    private _men = entities  [["Man"], [], true, false];
    _men = _men select {(player distance _x) < 300};
    visorTargets = _men select {_x isKindOf "CAManBase"};
    visorAnimals = _men select {!(_x isKindOf "CAManBase")};
    visorTargets = visorTargets - [(player getVariable ["diwako_dog_owner",objNull])];
    visorAnimals = visorAnimals - [player];
    visorMines = allMines select { (player distance2D _x) <= 25};
    sleep 5;
  };
};

private _action = ["diw_dog_dropNade","Drop throwable","",{
  [player, "Doggo drop that nade, BAD!"] call ace_advanced_throwing_fnc_exitThrowMode;
  player setVariable ["ace_advanced_throwing_activeThrowable", objNull];
},{!isNull (player getVariable ["ace_advanced_throwing_activeThrowable", objNull])}] call ace_interact_menu_fnc_createAction;

[doggo, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_action = ["diw_dog_getOut","Get out vehicle","",{
  player setVariable["diwako_dog_inVehicle",false,true];
  private _pos = (player getVariable "diwako_dog_vehicle") modelToWorld [5,0,0];
  detach player;
  player setPosATL _pos;
},{player getVariable["diwako_dog_inVehicle",false]}] call ace_interact_menu_fnc_createAction;

[doggo, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;

private _action = ["diw_dog_drop","Drop","",{
  [player, (player getVariable ["diwako_dog_draggedObject",objNull])] call ace_dragging_fnc_dropObject;
  player setVariable ["ace_dragging_isDragging", true, true];
  player setVariable ["diwako_dog_dragging",false,true];
},{(player getVariable ["diwako_dog_dragging", false])}] call ace_interact_menu_fnc_createAction;

[doggo, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_action = ["diw_dog_howl","Howl","",{
  diw_dogBark = time + 10;
  player playmove "Dog_Idle_Growl";
  [player, ["howl" + str(floor random 2),500,1]] remoteExec ["say3D"];
},{((missionNamespace getVariable ['diw_dogBark',(time-1)]) < time) && !(player getVariable["diwako_dog_inVehicle",false]) && !(player getVariable ["diwako_dog_dragging", false])}] call ace_interact_menu_fnc_createAction;

[doggo, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_action = ["diw_dog_sit","Sit down","",{
  player playMove "Dog_Sit";
},{!(player getVariable ["diwako_dog_dragging", false]) && {!(player getVariable ["diwako_dog_isCarried", false])}}] call ace_interact_menu_fnc_createAction;

[doggo, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_action = ["diw_dog_excited","Get Excited","",{
  player playMove "Dog_Idle_Bark";
  [player, "idle_" + str (floor random 2)] remoteExec ["say3d"];
  [player, "idle_" + str ((floor random 3) + 2)] remoteExec ["say3d"];
},{!(player getVariable["diwako_dog_inVehicle",false]) && !(player getVariable ["diwako_dog_dragging", false])}] call ace_interact_menu_fnc_createAction;

[doggo, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_action = ["diw_turn_off_smellovision","Disable Smell-o-Vison","",{
  removeMissionEventHandler ["Draw3D",visoreh];
  switchCamera personalCam;
  visoreh = nil;
},{!isNil 'visoreh'}] call ace_interact_menu_fnc_createAction;

[doggo, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_action = ["diw_dog_growl","Growl","",{
  player playMoveNow "Dog_Idle_Growl";
},{((missionNamespace getVariable ['diw_dogBark',(time-1)]) < time) && !(player getVariable["diwako_dog_inVehicle",false]) && !(player getVariable ["diwako_dog_dragging", false])}] call ace_interact_menu_fnc_createAction;

[doggo, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_action = ["diw_turn_on_smellovision","Enable Smell-o-Vison","",{
  switchCamera player;
  diw_dog_human_color = [
    [1,0.6,0,1],
    [1,1,1,1]
  ];
  visoreh = addMissionEventHandler ["Draw3D",{
    private _posIcon = [0,0,0];
    {
      private _alive = !(!(alive _x) || {(_x getVariable ["ace_medical_pain", 0] > 0.2) || {[_x] call ace_medical_fnc_getBloodLoss > 0 || {_x getVariable ["ACE_isUnconscious", false]}}});
      _posIcon = _x modelToWorldVisual (_x selectionPosition "pelvis");
      // drawIcon3D ["\A3\ui_f\data\map\markers\military\triangle_CA.paa", diw_dog_human_color select _alive, _posIcon, 0.5, 0.5, 0, ["Human (dead)","Human"] select _alive];
      drawIcon3D ["\A3\ui_f\data\map\markers\military\triangle_CA.paa", diw_dog_human_color select _alive, _posIcon, 0.5, 0.5, 0, ["Human (wounded)","Human"] select _alive];
      false
    } count visorTargets;
    {
      _posIcon = getPosATLVisual _x;
      drawIcon3D ["\A3\ui_f\data\map\vehicleicons\iconAnimal_ca.paa", [0,1,0,1], _posIcon, 0.5, 0.5, 0, "Animal"];
    } count visorAnimals;
    {
      _posIcon = getPosATLVisual _x;
      drawIcon3D ["\A3\ui_f\data\map\vehicleicons\iconExplosiveAP_ca.paa", [1,0,0,1], _posIcon, 1, 1, 0, "Explosive"];
      false
    } count visorMines;
    if!(isNull (player getVariable ["diwako_dog_owner",objNull])) then {
      private _owner = player getVariable "diwako_dog_owner";
      _posIcon = _owner modelToWorldVisual (_owner selectionPosition "pelvis");
      drawIcon3D ["\A3\ui_f\data\map\markers\military\triangle_CA.paa", [0,1,0,1], _posIcon, 0.5, 0.5, 0, "Owner"];
    };
  }];
},{isNil 'visoreh' && !(player getVariable["diwako_dog_inVehicle",false]) && !(player getVariable ["diwako_dog_dragging", false])}] call ace_interact_menu_fnc_createAction;

[doggo, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;

doggo setVariable ["diwako_dog_allowNvg",_allowNvg];

_action = ["diw_dog_selfhealthcheck","Check own health","",{
  private _dam = damage player;
  if(_dam == 0) exitWith {titleText ["Good health","PLAIN DOWN"]};
  if(_dam < 0.25) exitWith {titleText ["Some damage","PLAIN DOWN"]};
  if(_dam < 0.5 ) exitWith {titleText ["Wounded","PLAIN DOWN"]};
  if(_dam < 0.75 ) exitWith {titleText ["Heavily wounded","PLAIN DOWN"]};
  titleText ["Near death","PLAIN DOWN"];
},{true}] call ace_interact_menu_fnc_createAction;

[doggo, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_action = ["diw_dog_fixcamera","Fix camera","",{
  [player, ""] remoteExec ["switchmove"];
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
  false setCamUseTi 0;
  camUseNVG false;
  doggo setVariable ["ace_dragging_isDragging",true,true];
},{true}] call ace_interact_menu_fnc_createAction;

[doggo, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;

// move old player out of the way
// to be able to still respawn that unit must not die!
[oldPlayer, "Doggo Mode"] call ace_common_fnc_hideUnit;
oldPlayer allowDamage false;
private _safepos = [[0,0,0], 0, 50000, 1, 0, 0.7, 0, [], [[0,0,0], [0,0,0]]] call BIS_fnc_findSafePos;
oldPlayer setPos _safepos;
oldPlayer disableAI "ALL";
oldPlayer setVariable ["acex_headless_blacklist", true, true]; // please stay local

// attach some drone to the dog so AI will shoot at it
private _droneClass = (side group oldPlayer) call {
  if(_this == independent) exitWith {"I_UAV_06_F"};
  if(_this == opfor) exitWith {"O_UAV_06_F"};
  if(_this == blufor) exitWith {"B_UAV_06_F"};
  ""
};
systemChat ("class " + _droneClass);
if(_droneClass != "") then {
  // diwako_dog_drone = (createGroup [(side group oldPlayer),true]) createUnit [_droneClass, position player, [], 0, "FORM"];
  diwako_dog_drone = createVehicle [_droneClass, getPos player, [], 0,""];
  createVehicleCrew diwako_dog_drone;
  {
    _x setVariable ["acex_headless_blacklist", true, true]; // please stay local
    _x disableAI "ALL";
    [_x,false] remoteExec ["enableSimulationGlobal",2];
    false
  } count (crew diwako_dog_drone);
  diwako_dog_drone lock true;
  diwako_dog_drone allowDamage false;
  diwako_dog_drone attachTo [doggo,[0,-0.4,-0.3],"head"];
  diwako_dog_drone setObjectTexture [0,""];
  [diwako_dog_drone,{
    player disableCollisionWith _this;
    _this disableCollisionWith player;
    }] remoteExec ["call",0,diwako_dog_drone];
  // [diwako_dog_drone,false] remoteExec ["enableSimulationGlobal",2];
};