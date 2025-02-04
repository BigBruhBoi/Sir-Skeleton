if health_points = 0 {instance_destroy()}



// Step Event of obj_test
var seek_vector = [0, 0];
var separate_vector = [0, 0];
var total_neighbors = 0;

// Seek Player behavior
if instance_exists(Player) {
    var target_x = Player.x;
    var target_y = Player.y;
    
    seek_vector[0] = target_x - x;
    seek_vector[1] = target_y - y;
    
    // Normalize seek vector
    var seek_mag = point_distance(0, 0, seek_vector[0], seek_vector[1]);
    if seek_mag > 0 {
        seek_vector[0] /= seek_mag;
        seek_vector[1] /= seek_mag;
    }
}

// Separation from other instances using proper collision check
var nearby_list = ds_list_create();
var num_nearby = collision_circle_list(x, y, separation_radius, test, false, true, nearby_list, false);

for (var i = 0; i < num_nearby; i++) {
    var neighbour = nearby_list[| i];
    if neighbour.id == id continue;
    
	var dx = x - neighbour.x;
    var dy = y - neighbour.y;
    var distance = point_distance(x, y, neighbour.x, neighbour.y);
    
    if distance > 0 {
        // Linear falloff with distance
        var strength = (separation_radius - distance) / separation_radius;
        separate_vector[0] += (dx / distance) * strength * separation_force;
        separate_vector[1] += (dy / distance) * strength * separation_force;
        total_neighbors++;
    }
}
ds_list_destroy(nearby_list);

// Normalize separation vector
if total_neighbors > 0 {
    separate_vector[0] /= total_neighbors;
    separate_vector[1] /= total_neighbors;
    
    var sep_mag = point_distance(0, 0, separate_vector[0], separate_vector[1]);
    if sep_mag > 0 {
        separate_vector[0] = (separate_vector[0] / sep_mag) * separation_force;
        separate_vector[1] = (separate_vector[1] / sep_mag) * separation_force;
    }
}

// Combine vectors with separation priority
velocity[0] += separate_vector[0] * 2 + seek_vector[0];
velocity[1] += separate_vector[1] * 2 + seek_vector[1];

// Limit maximum speed
var current_speed = point_distance(0, 0, velocity[0], velocity[1]);
if current_speed > max_speed {
    velocity[0] = (velocity[0] / current_speed) * max_speed;
    velocity[1] = (velocity[1] / current_speed) * max_speed;
}

// Apply movement
x += velocity[0];
y += velocity[1];

// Final collision push-apart
var colliding = instance_place(x, y, test);
if colliding != noone && colliding.id != id {
    var push_dir = point_direction(colliding.x, colliding.y, x, y);
    x += lengthdir_x(2, push_dir);
    y += lengthdir_y(2, push_dir);
}