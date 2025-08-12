touch_id = -1;
value = 0;
pressed = function(_touch_id, _touch_x, _touch_y){ };
down = function(_touch_id, _touch_x, _touch_y){ };
released = function(_touch_id, _touch_x, _touch_y){ };

touch_pressed = function (_touch_id, _name, _touch_x, _touch_y)
{
	value = 1;
	touch_id = _touch_id;
	pressed(_touch_id, _touch_x, _touch_y);
	Input.update_touch(_name,STATES.PRESSED,value);
}
touch_down = function (_touch_id, _name, _touch_x, _touch_y)
{
	value = 1;
	down(_touch_id, _touch_x, _touch_y);
	Input.update_touch(_name,STATES.DOWN,value);
}
touch_released = function (_touch_id, _name, _touch_x, _touch_y)
{
	value = 0;
	released(_touch_id, _touch_x, _touch_y);
	Input.update_touch(_name,STATES.RELEASED,value);
}