function InputMap(_deadzone = 0.2) constructor
{
	enum MB_WHEELS { UP = 6, DOWN = 7};
	enum STATES { NONE, PRESSED, DOWN, RELEASED};
	#macro MAX_TOUCH_DEVICES 10
	fingers = array_create(MAX_TOUCH_DEVICES,{"STATE" : STATES.NONE, "INSTANCE" : noone, "X" : 0, "Y" : 0});
	
	actions = {};
	actions_names = [];
	
	gamepad_buttons = [gp_face1, gp_face2, gp_face3, gp_face4,gp_shoulderl,gp_shoulderlb,gp_shoulderr,gp_shoulderrb,gp_select,gp_start,gp_stickl,gp_stickr,gp_padu,gp_padd,gp_padl,gp_padr];
	gamepad_axis = [gp_axislh,gp_axislv,gp_axisrh,gp_axisrv];
	mouse_buttons = [mb_left,mb_middle,mb_right,mb_side1,mb_side2,MB_WHEELS.UP,MB_WHEELS.DOWN];
	
	gamepads = [];
	gamepad_main = undefined;
	
	gamepad_states = {};
	gamepad_values = {};
	mouse_states = {};
	key_states = {};
	touches_states = {};
	touches_values = {};
	
	captured_keys = [];
	captured_gpbuttons = [];
	captured_gpaxis = [];
	captured_mb = [];
	captured_touches = [];
	
	deadzone = _deadzone;
	
	/// @func action_pressed(name)
	/// @desc Returns true if action is pressed
	/// @param {String} _name Action's name
	/// @return {Bool}
	function action_pressed(_name)
	{
		var _act = action_get(_name);
		var _res = struct_get(_act,"state") == STATES.PRESSED;
		return _res;
	}
	/// @func action_down(name)
	/// @desc Returns true if action is down
	/// @param {String} _name Action's name
	/// @return {Bool}
	function action_down(_name)
	{
		return struct_get(action_get(_name),"state") == STATES.DOWN;
	}
	/// @func action_release(name)
	/// @desc Returns true if action is released
	/// @param {String} _name Action's name
	/// @return {Bool}
	function action_released(_name)
	{
		var _act = action_get(_name);
		var _res = struct_get(_act,"state") == STATES.RELEASED;
		return _res;
	}
	/// @func action_none(name)
	/// @desc Returns true if action is none
	/// @param {String} _name Action's name
	/// @return {Bool}
	function action_none(_name)
	{
		return struct_get(action_get(_name),"state") == STATES.NONE;
	}
	/// @func action_get_value(name)
	/// @desc Returns action's value
	/// @param {String} _name Action's name
	/// @return {Bool}
	function action_get_value(_name)
	{
		return struct_get(action_get(_name),"value");
	}
	
	/// @func action_get_state(name)
	/// @desc Returns action's state enum
	/// @param {String} _name Action's name
	/// @return {ENUM.STATES}
	function action_get_state(_name)
	{
		return struct_get(action_get(_name),"state");
	}
	
	/// @func action_get_deadzone(name)
	/// @desc Returns action's deadzone
	/// @param {String} _name Action's name
	/// @param {String} _deadzone Action's deadzone
	function action_get_deadzone(_name,_deadzone)
	{
		var _act = struct_get(actions,_name);
		return struct_get(_act,"deadzone");
	}
	/// @func action_get_events(name)
	/// @desc Returns action's input
	/// @param {String} _name Action's name
	/// @return {Struct}
	function action_get_input(_name)
	{
		var _act = struct_get(actions,_name);
		return struct_get(_act,"input");
	}
	
	/// @func action_set_deadzone(name,deadzone)
	/// @desc Sets action's deadzone
	/// @param {String} _name Action's name
	/// @param {Real} _deadzone Action's deadzone
	function action_set_deadzone(_name,_deadzone)
	{
		var _act = struct_get(actions,_name);
		struct_set(_act,"deadzone", _deadzone);
	}
	
	/// @func action_add(name,deadzone)
	/// @desc Adds an action
	/// @param {String} _name Action's name
	/// @param {Real} _deadzone Action's deadzone
	function action_add(_name,_deadzone = 0.2)
	{
		if(!action_exists(_name))
		{
			struct_set(actions,_name,{ input : { keyboard : [], gamepad : [], mouse : [], touch : []}, state : STATES.NONE, value : 0.0});
			array_push(actions_names,_name);
		}
	}
	/// @func action_remove(name)
	/// @desc Removes an action
	/// @param {String} _name Action's name
	function action_remove(_name)
	{
		var _ind = array_get_index(actions_names,_name);
		if(_ind != -1)
		{
			array_delete(actions_names,_ind,1);
			struct_remove(actions,_name);
		}
	}
	
	/// @func action_get(name)
	/// @desc Returns an action struct
	/// @param {String} _name Action's name
	function action_get(_name)
	{
		return struct_get(actions,_name);
	}
	
	/// @func get_actions(name)
	/// @desc Returns actions struct
	function get_actions()
	{
		return actions_names;
	}
	
	/// @func action_exists(name)
	/// @desc Checks if an action exists
	/// @param {String} _name Action's name
	function action_exists(_name)
	{
		return struct_exists(actions,_name);
	}
	
	/// @func action_set_input(name,input)
	/// @desc Adds input to an action
	/// @param {String} _name Action's name
	/// @param _input Input struct
	function action_set_input(_name,_input)
	{
		var _act = struct_get(actions,_name);
		if(_act != undefined)
		{
			var _ainput = struct_get(_act,"input");
			if(_ainput != undefined)
			{
				var _keys = struct_get(_input,"keyboard");
				if(_keys != undefined && is_array(_keys))
				{
					struct_set(_ainput,"keyboard",_keys);
					for(var _k = 0; _k < array_length(_keys);_k++)
					{
						var _key = _keys[_k];
						if(!struct_exists(key_states,_key))
						{
							struct_set(key_states,string(_key),STATES.NONE);	
						}
					}
				}
			
				var _gp = struct_get(_input,"gamepad");
				if(_gp != undefined && is_array(_gp))
				{
					struct_set(_ainput,"gamepad",_gp);
					for(var _g = 0; _g < array_length(_gp); _g++)
					{
						var _gi = _gp[_g];
						if(array_contains(gamepad_buttons,_gi) || array_contains(gamepad_axis,((_gi < 0) ? -_gi : _gi)) && !struct_exists(gamepad_states,_gi))
						{
							struct_set(gamepad_states,string(_gi),STATES.NONE);
						}
						if(array_contains(gamepad_buttons,_gi) || array_contains(gamepad_axis,((_gi < 0) ? -_gi : _gi)) && !struct_exists(gamepad_values,_gi))
						{
							struct_set(gamepad_values,string(_gi),0);
						}
					}
				}
				var _mb = struct_get(_input,"mouse");
				if(_mb != undefined && is_array(_mb))
				{
					struct_set(_ainput,"mouse",_mb);
					for(var _m = 0; _m < array_length(_mb); _m++)
					{
						var _mi = _mb[_m];
						if(array_contains(mouse_buttons,_mi) && !struct_exists(mouse_states,_mi))
						{
							struct_set(mouse_states,string(_mi),STATES.NONE);	
						}
					}
				}
				var _tb = struct_get(_input,"touch");
				if(!is_undefined(_tb) && is_array(_tb))
				{
					struct_set(_ainput,"touch",_tb);
					for(var _t = 0; _t < array_length(_tb); _t++)
					{
						var _ti = _tb[_t];
						struct_set(touches_states,string(_ti),STATES.NONE);
					}
				}
			}
		}
	}
	
	/// @func update_key_state(_vk,_state)
	/// @desc Updates a key's state on key_states struct
	/// @param {String} _vk Keycode
	/// @param {ENUM.STATES} _state State
	function update_key_state(_vk,_state)
	{
		/*var _key = struct_get(key_states,_vk);
		if(_key != undefined)
		{*/
			/*if((_state == STATES.PRESSED && _key != STATES.NONE) ||
			(_state == STATES.DOWN && _key != STATES.PRESSED) ||
			(_state == STATES.RELEASED && _key != STATES.DOWN) ||
			(_state == STATES.NONE && _key != STATES.RELEASED))
			{
				return;
			}*/
			struct_set(key_states,_vk,_state);
		//}
	}
	
	/// @func update_mouse_state(_mbi,_state)
	/// @desc Updates a mouse buttons states on mouse_states struct
	/// @param {Real | Constant.MouseButton} _mbi Mouse button
	/// @param {ENUM.STATES} _state State
	function update_mouse_state(_mbi,_state)
	{
		/*var _mb = struct_get(mouse_states,string(_mbi));
		if(_mb != undefined)
		{*/
			/*if((_state == STATES.PRESSED && _mb != STATES.NONE) ||
			(_state == STATES.DOWN && _mb != STATES.PRESSED) ||
			(_state == STATES.RELEASED && _mb != STATES.DOWN) ||
			(_state == STATES.NONE && _mb != STATES.RELEASED))
			{
				return;
			}*/
			struct_set(mouse_states,string(_mbi),_state);
		//}
	}
	
	/// @func update_gamepad_state(_gpi,_state)
	/// @desc Updates a gamepad buttons states on gamepad_states struct
	/// @param {String | Constant.GamepadButton} _gpi Gamepad button
	/// @param {ENUM.STATES} _state State
	function update_gamepad_state(_gpi,_state)
	{
		/*var _gp = struct_get(gamepad_states,string(_gpi));
		if(_gp != undefined)
		{*/
			/*if((_state == STATES.PRESSED && _gp != STATES.NONE) ||
			(_state == STATES.DOWN && _gp != STATES.PRESSED) ||
			(_state == STATES.RELEASED && _gp != STATES.DOWN) ||
			(_state == STATES.NONE && _gp != STATES.RELEASED))
			{
				return;
			}*/
			struct_set(gamepad_states,string(_gpi),_state);
			struct_set(gamepad_values,string(_gpi),(_state != STATES.NONE && _state != STATES.RELEASED) ? 1 : 0);
		//}
	}
	
	/// @func update_gamepad_axis(_gpi,_state)
	/// @desc Updates a gamepad axis states on gamepad_states struct
	/// @param {String | Constant.GamepadAxis} _gpi Gamepad axis
	function update_gamepad_axis(_gpi, _value)
	{
		var _state = struct_get(gamepad_states,string(_gpi));
		var _state_final = STATES.NONE;
		if(_state == STATES.NONE && _value >= deadzone)
		{
			_state_final = STATES.PRESSED;	
		}
		else if((_state == STATES.PRESSED || _state == STATES.DOWN) && _value >= deadzone)
		{
			_state_final = STATES.DOWN;	
		}
		else if(_state == STATES.DOWN && _value < deadzone)
		{
			_state_final = STATES.RELEASED;	
		}
		struct_set(gamepad_states,string(_gpi),_state_final);
		struct_set(gamepad_values,string(_gpi),_value);
	}
	
	/// @func update_touch(_name,_state,_value)
	/// @param {String} _name Name
	/// @param {ENUM.STATES} _state State
	/// @param {Real} _value Value
	function update_touch(_name,_state,_value)
	{
		var _ostate = struct_get(touches_states,_name);
		if(is_undefined(_ostate))
		{
			_ostate = STATES.NONE;
		}
		if(_state == STATES.RELEASED && (_ostate == STATES.RELEASED || _ostate == STATES.NONE))
		{
			_state = STATES.NONE;
		}
		struct_set(touches_states,_name,_state);
		struct_set(touches_values,_name,_value);
	}
		
	/// @func action_gamepad_async(_async_load)
	/// @desc Manages gamepad connection and disconnection
	/// @param {Id.DsMap} _async_load Async Load ds_map
	function action_gamepad_async(_async_load)
	{
		var _gamepad = _async_load[? "pad_index"];

		switch(_async_load[? "event_type"])
		{
			case "gamepad discovered":
				gamepad_set_axis_deadzone(_gamepad,deadzone);
				array_push(gamepads,_gamepad);
			break;
			case "gamepad lost":
				var _gp_ind = array_get_index(gamepads,_gamepad);
				if(_gp_ind >= 0)
				{
					array_delete(gamepads,_gp_ind,1);
				}
			break;
		}

		if(array_length(gamepads) > 0)
		{
			gamepad_main = gamepads[0];
		}
		else
		{
			gamepad_main = undefined;	
		}
	}
	
	/// @func touch_begin_step()
	/// @desc Manages touch
	function touch_begin_step()
	{
		var _ind = 0;
		while(_ind < array_length(captured_touches))
		{
			var _touch = captured_touches[_ind];
			var _tid = struct_get(_touch,"FINGER");
			var _tname = struct_get(_touch,"NAME");
			if(!is_undefined(_tid) && !is_undefined(_tname))
			{
				var _down = device_mouse_check_button(_tid,mb_left);
				var _released = device_mouse_check_button_released(_tid,mb_left);
				
				var _touch_x = device_mouse_x_to_gui(_tid);
				var _touch_y = device_mouse_y_to_gui(_tid);
				fingers[_tid].X = _touch_x;
				fingers[_tid].Y = _touch_y;
				var _ui_at_pos = instance_position(_touch_x,_touch_y,obj_touch_parent);
				var _instance = fingers[_tid].INSTANCE;
				var _state = fingers[_tid].STATE;
				if(_ui_at_pos != noone && _instance == _ui_at_pos)
				{
					if(_released)
					{
						fingers[_tid].STATE = STATES.RELEASED;
						_ui_at_pos.touch_released(_tid,_tname,_touch_x,_touch_y);
					}
					else if(_down)
					{
						fingers[_tid].STATE = STATES.DOWN;
						_ui_at_pos.touch_down(_tid,_tname,_touch_x,_touch_y);
					}
					else
					{
						fingers[_tid].STATE = STATES.NONE;
						array_delete(captured_touches,_ind,1);
						continue;
					}
				}
				else if(_instance != noone)
				{
					var _name = _instance.touch_name;
					fingers[_tid].STATE = STATES.RELEASED;
					_instance.touch_released(_tid,_name,_touch_x,_touch_y);
					fingers[_tid].INSTANCE = noone;
				}
			}
			else
			{
				array_delete(captured_touches,_ind,1);
				continue;
			}
			_ind++;
		}
		
		for(var _i = 0; _i < MAX_TOUCH_DEVICES; _i++)
		{
			var _pressed = device_mouse_check_button_pressed(_i, mb_left);
			if(_pressed)
			{
				var _touch_x = device_mouse_x_to_gui(_i);
				var _touch_y = device_mouse_y_to_gui(_i);
				fingers[_i].X = _touch_x;
				fingers[_i].Y = _touch_y;
			
				var _ui_at_pos = instance_position(_touch_x,_touch_y,obj_touch_parent);
				var _instance = fingers[_i].INSTANCE;
				var _state = fingers[_i].STATE;
				if(_ui_at_pos != noone)
				{
					var _name = _ui_at_pos.touch_name;
					if((_state == STATES.NONE || _state == STATES.RELEASED))
					{
						if(_instance != _ui_at_pos)
						{
							fingers[_i].INSTANCE = _ui_at_pos;
							_instance = _ui_at_pos;
						}
						fingers[_i].STATE = STATES.PRESSED;
						_ui_at_pos.touch_pressed(_i,_name,_touch_x,_touch_y);
						if(!array_contains(captured_touches,_name))
						{
							array_push(captured_touches,{"FINGER": _i,"NAME" : _name});	
						}
					}
				}
			}
		}
		
		/*for(var _i = 0; _i < MAX_TOUCH_DEVICES; _i++)
		{
			var _touch_x = device_mouse_x_to_gui(_i);
			var _touch_y = device_mouse_y_to_gui(_i);
			fingers[_i].X = _touch_x;
			fingers[_i].Y = _touch_y;
			
			var _ui_at_pos = instance_position(_touch_x,_touch_y,obj_touch_parent);
			var _instance = fingers[_i].INSTANCE;
			var _state = fingers[_i].STATE;
			
			var _pressed = device_mouse_check_button_pressed(_i, mb_left);
			var _down = device_mouse_check_button(_i, mb_left);
			var _released = device_mouse_check_button_released(_i, mb_left);
			
			if(_ui_at_pos != noone)
			{
				var _name = _ui_at_pos.touch_name;
				if(_pressed && (_state == STATES.NONE || _state == STATES.RELEASED))
				{
					if(_instance != _ui_at_pos)
					{
						fingers[_i].INSTANCE = _ui_at_pos;
						_instance = _ui_at_pos;
					}
					fingers[_i].STATE = STATES.PRESSED;
					_ui_at_pos.touch_pressed(_i,_name,_touch_x,_touch_y);
					if(!array_contains(captured_touches,_name))
					{
						array_push(captured_touches,_name);	
					}
				}
				else if(_down && (_state == STATES.PRESSED || _state == STATES.DOWN))
				{
					fingers[_i].STATE = STATES.DOWN;
					_ui_at_pos.touch_down(_i,_name,_touch_x,_touch_y);
				}
				else if(_released && _state == STATES.DOWN)
				{
					fingers[_i].STATE = STATES.RELEASED;
					_ui_at_pos.touch_released(_i,_name,_touch_x,_touch_y);
					fingers[_i].INSTANCE = noone;
				}
			}
			else if(_instance != noone && ((_down || _pressed) && _state != STATES.RELEASED))
			{
				var _name = _instance.touch_name;
				fingers[_i].STATE = STATES.RELEASED;
				_instance.touch_released(_i,_name,_touch_x,_touch_y);
				fingers[_i].INSTANCE = noone;
			}
		}*/
	}
	
	/// @func action_begin_step()
	/// @desc Get input, manages it, and updates actions states and values
	function action_begin_step()
	{		
		#region Keyboard
		var _ind = 0;
		while(_ind < array_length(captured_keys))
		{
			var _val = captured_keys[_ind];
			// ACTION RELEASED
			if(keyboard_check_released(_val))
			{
				update_key_state(_val,STATES.RELEASED);
			}
			// ACTION DOWN
			else if(keyboard_check_direct(_val))
			{
				update_key_state(_val,STATES.DOWN);
				_ind++;
				continue;
			}
			else
			{
				// ACTION NONE
				update_key_state(_val,STATES.NONE);
				array_delete(captured_keys,_ind,1);
				continue;
			}
			_ind++;
		}
		
		// ACTION PRESSED
		var _key = keyboard_key;
		if(keyboard_check_pressed(_key) && !array_contains(captured_keys,string(_key)) && struct_get(key_states,string(_key)) != undefined)
		{
			array_push(captured_keys,string(_key));
			update_key_state(string(_key),STATES.PRESSED);
		}
		#endregion
		
		#region Mouse
		_ind = 0;
		while(_ind < array_length(captured_mb))
		{
			var _val = captured_mb[_ind];
			
			if(_val == MB_WHEELS.UP)
			{
				var _state = struct_get(mouse_states,string(_val));
				if(_state != undefined)
				{
					if(mouse_wheel_up())
					{
						if(_state == STATES.PRESSED)
						{
							update_mouse_state(_val,STATES.DOWN);
							_ind++;
							continue;
						}
					}
					else
					{
						if(_state == STATES.DOWN || _state == STATES.PRESSED)
						{
							update_mouse_state(_val,STATES.RELEASED);
						}
						else if(_state == STATES.RELEASED)
						{
							update_mouse_state(_val,STATES.NONE);
							array_delete(captured_mb,_ind,1);
							continue;
						}
					}
					_ind++;
				}
				else
				{
					update_mouse_state(_val,STATES.NONE);
				}
			}
			else if(_val == MB_WHEELS.DOWN)
			{
				var _state = struct_get(mouse_states,string(_val));
				if(_state != undefined)
				{
					if(mouse_wheel_down())
					{
						if(_state == STATES.PRESSED)
						{
							update_mouse_state(_val,STATES.DOWN);
							_ind++;
							continue;
						}
					}
					else
					{
						if(_state == STATES.DOWN || _state == STATES.PRESSED)
						{
							update_mouse_state(_val,STATES.RELEASED);
						}
						else if(_state == STATES.RELEASED)
						{
							update_mouse_state(_val,STATES.NONE);
							array_delete(captured_mb,_ind,1);
							continue;
						}
					}
					_ind++;
				}
				else
				{
					update_mouse_state(_val,STATES.NONE);
				}
			}
			else
			{
				// ACTION RELEASED
				if(mouse_check_button_released(_val))
				{
					update_mouse_state(_val,STATES.RELEASED);
				}
				// ACTION DOWN
				else if(mouse_check_button(_val))
				{
					update_mouse_state(_val,STATES.DOWN);
					_ind++;
					continue;
				}
				else
				{
					// ACTION NONE
					update_mouse_state(_val,STATES.NONE);
					array_delete(captured_mb,_ind,1);
					continue;
				}
			}
			_ind++;
		}
		
		// ACTION PRESSED
		var _mkey = mouse_button;
		if(!is_undefined(struct_get(mouse_states,string(_mkey))) && (mouse_check_button_pressed(_mkey)) && !array_contains(captured_mb,_mkey))
		{
			array_push(captured_mb,_mkey);
			update_mouse_state(_mkey,STATES.PRESSED);
		}
		
		if(struct_get(mouse_states,string(MB_WHEELS.UP)) != undefined && mouse_wheel_up() && !array_contains(captured_mb,MB_WHEELS.UP))
		{
			array_push(captured_mb,MB_WHEELS.UP);
			update_mouse_state(MB_WHEELS.UP,STATES.PRESSED);
		}
		
		if(struct_get(mouse_states,string(MB_WHEELS.DOWN)) != undefined && mouse_wheel_down() && !array_contains(captured_mb,MB_WHEELS.DOWN))
		{
			array_push(captured_mb,MB_WHEELS.DOWN);
			update_mouse_state(MB_WHEELS.DOWN,STATES.PRESSED);
		}
		
		#endregion
		
		#region Gamepad
		if(!is_undefined(gamepad_main))
		{
			_ind = 0;
			while(_ind < array_length(captured_gpbuttons))
			{
				var _val = captured_gpbuttons[_ind];
				// ACTION RELEASED
				if(gamepad_button_check_released(gamepad_main,_val))
				{
					update_gamepad_state(_val,STATES.RELEASED);
				}
				// ACTION DOWN
				else if(gamepad_button_check(gamepad_main,_val))
				{
					update_gamepad_state(_val,STATES.DOWN);
					//_ind++;
					//continue;
				}
				else
				{
					// ACTION NONE
					update_gamepad_state(_val,STATES.NONE);
					array_delete(captured_gpbuttons,_ind,1);
					continue;
				}
				_ind++;
			}
		
			// ACTION PRESSED
			for(var _g = 0; _g < array_length(gamepad_buttons);_g++)
			{
				var _btn = gamepad_buttons[_g];
				if(gamepad_button_check_pressed(gamepad_main,_btn) && !array_contains(captured_gpbuttons,_btn) && struct_get(gamepad_states,string(_btn)) != undefined)
				{
					array_push(captured_gpbuttons,_btn);
					update_gamepad_state(_btn,STATES.PRESSED);
				}
			}
			
			// AXIS
			_ind = 0;
			while(_ind < array_length(captured_gpaxis))
			{
				var _ax = captured_gpaxis[_ind];
				var _val = gamepad_axis_value(gamepad_main,_ax);
				
				var _state = struct_get(gamepad_states,string(_ax));
				
				update_gamepad_axis(_ax,_val);
				
				if(struct_get(gamepad_states,string(-_ax)) != undefined)
				{
					update_gamepad_axis(string(-_ax),-_val);
				}
				
				if(abs(_val) < deadzone && _state == STATES.NONE)
				{
					// ACTION NONE
					array_delete(captured_gpaxis,_ind,1);
					continue;
				}
				_ind++;
			}
		
			// ACTION PRESSED
			for(var _g = 0; _g < array_length(gamepad_axis);_g++)
			{
				var _axis = gamepad_axis[_g];
				var _val = gamepad_axis_value(gamepad_main,_axis);
				if(abs(_val) >= deadzone && !array_contains(captured_gpaxis,_axis) && struct_get(gamepad_states,string(_axis)) != undefined)
				{
					array_push(captured_gpaxis,_axis);
					update_gamepad_axis(_axis,_val);
					if(struct_get(gamepad_states,string(-_axis)) != undefined)
					{
						update_gamepad_axis(string(-_axis),-_val);
					}
				}
			}
		}
		#endregion
		
		#region Input combination
		for(var _i = 0; _i < array_length(actions_names);_i++)
		{
			var _act = struct_get(actions, actions_names[_i]);
			var _state = struct_get(_act,"state");
			var _input = struct_get(_act,"input");
			var _any_pressed = false;
			var _any_down = false;
			
			var _value_final = 0;
			
			if(!is_undefined(_input) && !is_undefined(_state))
			{
				var _keys = struct_get(_input,"keyboard");
				if(!is_undefined(_keys))
				{
					for(var _k = 0; _k < array_length(_keys);_k++)
					{
						var _kc = _keys[_k];
						var _kstate = struct_get(key_states,string(_kc));
						if(_kstate != undefined)
						{
							if(_kstate == STATES.PRESSED)
							{
								_any_pressed = true;
								_any_down = true;
							}
							else if(_kstate == STATES.DOWN)
							{
								_any_down = true;	
							}
						}
					}
					_value_final = (_any_down) ? 1 : 0;
				}
				var _mb = struct_get(_input,"mouse");
				if(!is_undefined(_mb))
				{
					for(var _k = 0; _k < array_length(_mb);_k++)
					{
						var _kc = _mb[_k];
						var _kstate = struct_get(mouse_states,string(_kc));
						if(!is_undefined(_kstate))
						{
							if(_kstate == STATES.PRESSED)
							{
								_any_pressed = true;
								_any_down = true;
							}
							else if(_kstate == STATES.DOWN)
							{
								_any_down = true;	
							}
						}
					}
					_value_final = (_any_down) ? 1 : 0;
				}
				if(!is_undefined(gamepad_main))
				{
					var _gpbtns = struct_get(_input,"gamepad");
					if(!is_undefined(_gpbtns))
					{
						for(var _g = 0; _g < array_length(_gpbtns);_g++)
						{
							var _gc = _gpbtns[_g];
							if(array_contains(gamepad_buttons,_gc))
							{
								var _gstate = struct_get(gamepad_states,string(_gc));
								var _gval = struct_get(gamepad_values,string(_gc));
								if(!is_undefined(_gstate) && !is_undefined(_gval))
								{
									if(_gval > _value_final)
									{
										_value_final = _gval;	
									}
									if(_gstate == STATES.PRESSED)
									{
										_any_pressed = true;
										_any_down = true;
									}
									else if(_gstate == STATES.DOWN)
									{
										_any_down = true;	
									}
								}
								_value_final = (_any_down) ? 1 : 0;
							}
							else if(array_contains(gamepad_axis,abs(_gc)))
							{
								var _gval = struct_get(gamepad_values,string(_gc));
								var _gstate = struct_get(gamepad_states,string(_gc));
								
								if(_gstate != undefined && _gval != undefined)
								{
									if(abs(_gval) > abs(_value_final))
									{
										_value_final = _gval;
									}
									if(_gstate == STATES.PRESSED)
									{
										_any_pressed = true;
										_any_down = true;
									}
									else if(_gstate == STATES.DOWN)
									{
										_any_down = true;	
									}
								}
							}
						}
					}
				}
				var _touches = struct_get(_input,"touch");
				if(!is_undefined(_touches))
				{
					for(var _t = 0; _t < array_length(_touches); _t++)
					{
						var _touch = _touches[_t];
						var _kstate = struct_get(touches_states,string(_touch));
						var _kvalue = struct_get(touches_values,string(_touch));
						if(!is_undefined(_kstate) && !is_undefined(_kvalue))
						{
							if(_kvalue > _value_final)
							{
								_value_final = _kvalue;	
							}
							if(_kstate == STATES.PRESSED)
							{
								_any_pressed = true;
								_any_down = true;
							}
							else if(_kstate == STATES.DOWN)
							{
								_any_down = true;
							}
						}
					}
				}
			}
			var _state_final = STATES.NONE;
			
			switch (_state)
			{
				case STATES.NONE:
					if (_any_pressed)
						_state_final = STATES.PRESSED;
				break;
				case STATES.PRESSED:
					_state_final = _any_down ? STATES.DOWN : STATES.RELEASED;
				break;
				case STATES.DOWN:
					_state_final = _any_down ? STATES.DOWN : STATES.RELEASED;
				break;
				
				case STATES.RELEASED:
					_state_final = STATES.NONE;
				break;
			}
			struct_set(_act,"state",_state_final);
			struct_set(_act, "value", _value_final);
		}
		#endregion
	}
}