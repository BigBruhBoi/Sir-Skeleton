enemies_alive = instance_number(test);
if enemies_alive < enemy_spawn
{
	spawnX = random_range(-200, 2200)
	spawnY = random_range(-200, 1300)
	
	if point_distance(spawnX,spawnY,Player.x,Player.y) > 512 {
		instance_create_layer(spawnX,spawnY,"Instances",test)
	}
	
}

if kills > 10
{
kills = 0
enemy_spawn = enemy_spawn +1
}