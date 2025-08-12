# InputMap for GameMaker

**InputMap** is a flexible input handling system for GameMaker that allows you to map multiple input sources — such as keyboard, mouse, gamepad, and touch — to a single named action.

Instead of checking each device separately, you can query the state of an action using a single string, similar to how GameMaker handles keyboard input.  
For example:
```gml
if (Input.action_pressed("jump")) { /* Do something */ }```

# Key Features:
- Map multiple devices to a single action.
- Supports:
- - Keyboard
- - Mouse
- - Gamepad (buttons and axis)
- - Touch
- Query input with:
- - Input.action_pressed(name)
- - Input.action_released(name)
- - Input.action_down(name)
- - Easy setup and clean code.

# How to Use:

## 1 - Instance the constructor on a global variable

```GML
globalvar Input;
Input = new InputMap();
```

## 2 - Define actions


```GML
Input.action_add("left");
Input.action_add("up");
Input.action_add("down");
Input.action_add("right");
```

## 3 - Map devices to actions

```GML
Input.action_set_input("left", {
    keyboard: [ord("A"), vk_left],
    gamepad : [gp_padl, -gp_axislh],
    touch   : ["left"]
});

Input.action_set_input("right", {
    keyboard: [ord("D"), vk_right],
    gamepad : [gp_padr, gp_axislh],
    mouse   : [mb_right]
});

Input.action_set_input("up", {
    keyboard: [ord("W"), vk_up],
    gamepad : [gp_padu, -gp_axislv],
    mouse   : [MB_WHEELS.UP]
});

Input.action_set_input("down", {
    keyboard: [ord("S"), vk_down],
    gamepad : [gp_padd, gp_axislv],
    mouse   : [MB_WHEELS.DOWN]
});
```

## 4 - Checking input

Anywhere in your code (Step Event of other objects):
```GML
if (Input.action_pressed("left")) {
    x -= 4;
}

if (Input.action_down("up")) {
    y -= 4;
}

if (Input.action_released("down")) {
    show_debug_message("Stopped pressing DOWN");
}
```

# How it works

- action_add(name): Registers a new action.
- action_set_input(name, map): Assigns multiple device inputs to the action.
- action_pressed(name): Returns true if the action was pressed this step.
- action_down(name): Returns true while the action is held.
- action_released(name): Returns true if the action was released this step.

# Example Use Cases
- Platformer movement (keyboard, gamepad, or touch)
- Menu navigation (mouse wheel, arrow keys, joystick)
- Multi-device multiplayer

#Notes
- Gamepad axis mapping supports positive and negative directions.
- Touch input uses named areas or gestures (e.g., "left").