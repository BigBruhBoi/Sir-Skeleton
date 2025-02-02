// Initialize path variables
my_path = -1; // Unique path for each instance
path_update_interval = room_speed * 2; // Update path every 2 seconds
path_update_timer = path_update_interval;
move_speed = 3; // Speed at which the instance follows the path

// Set up a global pathfinding grid (shared by all instances)
// Only create the grid once (e.g., in a controller object)
if (!variable_global_exists("global_grid")) {
    // Adjust CELL_SIZE based on your game's tile size (e.g., 32x32)
    CELL_SIZE = 32;
    global.global_grid = mp_grid_create(0, 0, room_width div CELL_SIZE, room_height div CELL_SIZE, CELL_SIZE, CELL_SIZE);
    
    // Add collision objects (e.g., walls) to the grid
    mp_grid_add_instances(global.global_grid, obj_wall, false);
}