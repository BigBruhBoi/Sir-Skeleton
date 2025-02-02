if (keyboard_check(ord("A")))
{
    x = x - spd;
}
if (keyboard_check(ord("D")))
{
    x = x + spd;
}
if (keyboard_check(ord("W")))
{
    y = y - spd;
}
if (keyboard_check(ord("S")))
{
    y = y + spd;
}


if attack_ready = true
{
	if (mouse_check_button_pressed(1))
	{
		instance_create_layer(x,y,"Instances",regattack)
		attack_ready = false
		alarm_set(1,30)
		bones = bones -1
	}
}