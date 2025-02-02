// Update the path timer
path_update_timer -= 1;
if (path_update_timer <= 0 && instance_exists(Player)) {
    path_update_timer = path_update_interval; // Reset timer
    
    // Delete the old path (to avoid memory leaks)
    if (my_path != -1) {
        path_delete(my_path);
    }
    
    // Calculate a new path to the player
    my_path = path_add();
    var _success = mp_grid_path(
        global.global_grid, // The shared grid
        my_path, // Unique path for this instance
        x, y, // Current position
        Player.x, Player.y, // Target (player's position)
        true // Allow diagonal movement (set to false for grid-aligned)
    );
    
    // Start following the new path if valid
    if (_success) {
        path_start(my_path, move_speed, path_action_stop, true);
    } else {
        // Optional: Handle failed pathfinding (e.g., wander randomly)
        path_delete(my_path);
        my_path = -1;
    }
}

// Optional: Stop smoothly at the end of the path
if (path_position >= 1) {
    path_end();
}