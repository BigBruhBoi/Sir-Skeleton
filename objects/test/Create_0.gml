// Pathfinding
my_path = -1;
path_update_interval = room_speed * 2; // Update path every 2 seconds
path_update_timer = path_update_interval;
move_speed = 3; // Base movement speed

// Collision Avoidance
avoid_radius = 128; // Radius to check for nearby instances
avoid_force = 0.8; // Lowered to prevent overshooting

// Steering
steering_force = 0.5; // How strongly to adjust direction

// Global Grid Setup (for walls)
if (!variable_global_exists("global_grid")) {
    CELL_SIZE = 32;
    global.global_grid = mp_grid_create(0, 0, room_width div CELL_SIZE, room_height div CELL_SIZE, CELL_SIZE, CELL_SIZE);
    mp_grid_add_instances(global.global_grid, obj_wall, false);
}

// Create Event
CELL_SIZE = 32;

health_points = 1