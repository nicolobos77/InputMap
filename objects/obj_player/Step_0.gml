var _mh = (Input.action_down("right") ? 1 : 0) - (Input.action_down("left") ? 1 : 0);
var _mv = (Input.action_down("down") ? 1 : 0) - (Input.action_down("up") ? 1 : 0);

physics_apply_impulse(x,y,_mh,_mv);