var _acts = Input.get_actions();
var _nacts = array_length(_acts);
for(var _a = 0; _a < _nacts; _a++)
{
	draw_text(x + 48,y + 48 +_a*16,_acts[_a] + " value:" + string(Input.action_get_value(_acts[_a])));
	draw_text(x + 48,y + 48 +(_a + _nacts)*16,_acts[_a] + " state:" + string(Input.action_get_state(_acts[_a])));
}