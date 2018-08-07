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

private _action = ["diw_dog_carry","Drop dog","",{
  player setVariable ["diwako_dog_carryDog",false,true];
},{player getVariable ["diwako_dog_carryDog",false]}] call ace_interact_menu_fnc_createAction;

[typeOf player, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToClass;

["ace_interactMenuOpened", {
    if !(player isKindOf 'Dog_Base_F') exitWith {};
    // systemChat "open!";

}] call CBA_fnc_addEventHandler;

["ace_throwablePickedUp", {
  params["_activeThrowable", "_unit", "_attachedTo"];
  if !(_unit isKindOf 'Dog_Base_F') exitWith {};
  [{
    params["_activeThrowable", "_unit", "_attachedTo"];
    _unit setVariable ["ace_advanced_throwing_activeThrowable", _activeThrowable];
    _unit setVariable ["ace_advanced_throwing_primed", true];
    _unit getVariable ["ace_advanced_throwing_inHand",true];
    
    if!(isNil "ace_advanced_throwing_draw3DHandle") exitWith {};
    // Add throw action to suppress weapon firing (not possible to suppress mouseButtonDown event)
    _unit setVariable ["ace_advanced_throwing_throwAction", [_unit, "DefaultAction", {true}, {true}] call ace_common_fnc_addActionEventHandler];
    ace_advanced_throwing_draw3DHandle = addMissionEventHandler ["Draw3D", {
      if (dialog 
      // || {!(ACE_player getVariable ["ace_advanced_throwing_inHand", false])} 
      // || {!([ACE_player, true] call ace_advanced_throwing_fnc_canPrepare)}
      ) exitWith {
        [ACE_player, "In dialog or no throwable in hand or cannot prepare throwable"] call ace_advanced_throwing_fnc_exitThrowMode;
      };

      private _primed = ACE_player getVariable ["ace_advanced_throwing_primed", false];
      private _activeThrowable = ACE_player getVariable ["ace_advanced_throwing_activeThrowable", objNull];

      // Exit if throwable died primed in hand
      if (isNull _activeThrowable && {_primed}) exitWith {
        [ACE_player, "Throwable died primed in hand"] call ace_advanced_throwing_fnc_exitThrowMode;
      };

      private _throwable = currentThrowable ACE_player;

      private _throwableMag = _throwable param [0, "#none"];

      // Get correct throw power for primed grenade
      if (_primed) then {
        private _ammoType = typeOf _activeThrowable;
        _throwableMag = ace_advanced_throwing_ammoMagLookup getVariable _ammoType;
        if (isNil "_throwableMag") then {
          _throwableMag = "HandGrenade";
        };
      };

      // Some throwables have different classname for magazine and ammo
      // Primed magazine may be different, read speed before checking primed magazine!
      private _throwSpeed = getNumber (configFile >> "CfgMagazines" >> _throwableMag >> "initSpeed");

      // Reduce power of throw over shoulder and to sides
      private _unitDirVisual = getDirVisual ACE_player;
      private _cameraDir = getCameraViewDirection ACE_player;
      _cameraDir = (_cameraDir select 0) atan2 (_cameraDir select 1);

      private _phi = abs (_cameraDir - _unitDirVisual) % 360;
      _phi = [_phi, 360 - _phi] select (_phi > 180);

      private _power = linearConversion [0, 180, _phi - 30, 1, 0.3, true];
      ACE_player setVariable ["ace_advanced_throwing_throwSpeed", _throwSpeed * _power];

      private _throwableType = getText (configFile >> "CfgMagazines" >> _throwableMag >> "ammo");

      // Exit in case of explosion in hand
      if (isNull _activeThrowable) exitWith {
        [ACE_player, "No active throwable (explosion in hand)"] call ace_advanced_throwing_fnc_exitThrowMode;
      };

      // Exit if locality changed (someone took the throwable from hand)
      if (!local _activeThrowable && {ACE_player getVariable ["ace_advanced_throwing_localityChanged", true]}) exitWith {
        [ACE_player, "Throwable locality changed"] call ace_advanced_throwing_fnc_exitThrowMode;
      };

      // Set position
      private _posHeadRel = ACE_player selectionPosition "head";

      private _leanCoef = (_posHeadRel select 0) - 0.15; // 0.15 counters the base offset
      // Don't take leaning into account when weapon is lowered due to jiggling when walking side-ways (bandaid)
      if (abs _leanCoef < 0.15 || {vehicle ACE_player != ACE_player} || {weaponLowered ACE_player}) then {
        _leanCoef = 0;
      };

      private _posCameraWorld = AGLToASL (positionCameraToWorld [0, 0, 0]);
      _posHeadRel = _posHeadRel vectorAdd [-0.03, 0.01, 0.15]; // Bring closer to eyePos value
      private _posFin = AGLToASL (ACE_player modelToWorldVisual _posHeadRel);

      private _throwType = ACE_player getVariable ["ace_advanced_throwing_throwType", "normal"];

      // Orient it nicely, point towards player
      _activeThrowable setDir (_unitDirVisual + 90);

      private _pitch = [-30, -90] select (_throwType == "high");
      [_activeThrowable, _pitch, 0] call BIS_fnc_setPitchBank;

      // Force drop mode if underwater
      if (underwater player) then {
        ACE_player setVariable ["ace_advanced_throwing_dropMode", true];
      };

      if (ACE_player getVariable ["ace_advanced_throwing_dropMode", false]) then {
        _posFin = _posFin vectorAdd (AGLToASL (positionCameraToWorld [_leanCoef, 0, ACE_player getVariable ["ace_advanced_throwing_dropDistance", 0.2]]));

        // Even vanilla throwables go through glass, only "GEOM" LOD will stop it but that will also stop it when there is no glass in a window
        if (lineIntersects [_posCameraWorld, _posFin vectorDiff _posCameraWorld]) then {
          ACE_player setVariable ["ace_advanced_throwing_dropDistance", ((ACE_player getVariable ["ace_advanced_throwing_dropDistance", 0.2]) - 0.1) max 0.2];
        };
      } else {
        private _xAdjustBonus = [0, -0.075] select (_throwType == "high");
        private _yAdjustBonus = [0, 0.1] select (_throwType == "high");
        private _cameraOffset = [_leanCoef, 0, 0.3] vectorAdd [-0.1, -0.15, -0.03] vectorAdd [_xAdjustBonus, _yAdjustBonus, 0];

        _posFin = _posFin vectorAdd (AGLToASL (positionCameraToWorld _cameraOffset));

        if (vehicle ACE_player != ACE_player) then {
          // Counteract vehicle velocity including acceleration
          private _vectorDiff = (velocity (vehicle ACE_player)) vectorMultiply (time - (ACE_player getVariable ["ace_advanced_throwing_lastTick", time]) + 0.01);
          _posFin = _posFin vectorAdd _vectorDiff;
          ACE_player setVariable ["ace_advanced_throwing_lastTick", time];
        };
      };

      _activeThrowable setPosASL (_posFin vectorDiff _posCameraWorld);
    }];
  }, _this, 0.5] call CBA_fnc_waitAndExecute;
  // [_unit] call ace_advanced_throwing_fnc_prepare;
}] call CBA_fnc_addEventHandler;