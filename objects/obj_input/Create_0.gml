globalvar Input;
Input = new InputMap();

Input.action_add("left");
Input.action_add("up");
Input.action_add("down");
Input.action_add("right");

Input.action_set_input("left",{	keyboard : [ord("A"),vk_left],	gamepad : [gp_padl,-gp_axislh],  touch : ["left"]});

Input.action_set_input("right",{ keyboard : [ord("D"),vk_right], gamepad : [gp_padr,gp_axislh], touch : ["right"]});

Input.action_set_input("up",{ keyboard : [ord("W"),vk_up], gamepad : [gp_padu,-gp_axislv], mouse : [MB_WHEELS.UP],  touch : ["up"]});

Input.action_set_input("down",{	keyboard : [ord("S"),vk_down], gamepad : [gp_padd,gp_axislv], mouse : [MB_WHEELS.DOWN],  touch : ["down"]});

keys = [];
gp_btns = [];
gp_axis = [];

layer_set_visible("TouchControls",true);