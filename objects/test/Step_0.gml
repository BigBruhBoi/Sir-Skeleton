// --- Step Event (Pathfinding Section) ---
path_update_timer--;
if (path_update_timer <= 0 && instance_exists(Player)) {
    path_update_timer = path_update_interval;
    
    // Delete old path
    if (my_path != -1) {
        path_delete(my_path);
        my_path = -1;
    }
    
    // Create a NEW temporary grid (same size as global grid)
	// Create a NEW temporary grid with CELL_SIZE
	var temp_grid = mp_grid_create(
    0, 0, 
    room_width div CELL_SIZE,  // Horizontal cells
    room_height div CELL_SIZE, // Vertical cells
    CELL_SIZE,                 // Cell width
    CELL_SIZE                  // Cell height
);
    // Add walls to the temp grid
    mp_grid_add_instances(temp_grid, obj_wall, false);
    
    // Add other skeletons as temporary obstacles
    var skeleton_list = ds_list_create();
var skeleton_count = collision_circle_list( // CORRECTED FUNCTION NAME
    x, y,                   // Center of the circle
    300,                    // Radius to check
    object_index,           // Object to detect (other skeletons)
    false,                  // Precise collision (true/false)
    true,                   // Exclude self (notme = true)
    skeleton_list,          // List to store instances
    false                   // Ordered by distance? (true/false)
);

// Loop through skeletons and add them to the temp grid
for (var i = 0; i < skeleton_count; i++) {
    var inst = skeleton_list[| i];
    mp_grid_add_cell(temp_grid, inst.x div CELL_SIZE, inst.y div CELL_SIZE);
}

ds_list_destroy(skeleton_list); // Cleanup
    
    // Calculate path with the new grid
    my_path = path_add();
    var _success = mp_grid_path(
        temp_grid, 
        my_path, 
        x, y, 
        Player.x, Player.y, 
        true
    );
    
    // Clean up the temporary grid
    mp_grid_destroy(temp_grid);
    
    if (_success) {
        path_start(my_path, move_speed, path_action_stop, true);
    }
}
// --- Collision Avoidance (Predictive Sidestepping) ---
var avoid_x = 0, avoid_y = 0;
var list = ds_list_create();
var list_size = collision_circle_list(x, y, avoid_radius, object_index, false, true, list, false);

// Only calculate direction if the path is valid
if (my_path != -1 && path_exists(my_path)) {
    var current_pos = path_position;
    var next_pos = min(current_pos + 0.1, path_get_length(my_path)); // Prevent overshooting path
    
    // Get current and next path points to derive direction
    var current_x = path_get_x(my_path, current_pos);
    var current_y = path_get_y(my_path, current_pos);
    var next_x = path_get_x(my_path, next_pos);
    var next_y = path_get_y(my_path, next_pos);
    
    // Calculate direction from current to next point
    var path_dir = point_direction(current_x, current_y, next_x, next_y);
    
    for (var i = 0; i < list_size; i++) {
        var inst = list[| i];
        var dx = x - inst.x;
        var dy = y - inst.y;
        var dist = point_distance(x, y, inst.x, inst.y);
        
        if (dist > 0) {
            // Calculate perpendicular direction (90 degrees from path)
            var avoid_dir = path_dir + 90;
            var strength = (1 - (dist / avoid_radius)) * avoid_force;
            
            avoid_x += lengthdir_x(strength, avoid_dir);
            avoid_y += lengthdir_y(strength, avoid_dir);
        }
    }
}

ds_list_destroy(list);

// --- Apply Movement ---
var move_x = 0; // Initialize to 0
var move_y = 0;

if (my_path != -1 && path_exists(my_path)) {
    var path_length = path_get_number(my_path);
    if (path_length > 0) {
        // Calculate direction to next path point
        var target_x = path_get_x(my_path, path_position + 0.1);
        var target_y = path_get_y(my_path, path_position + 0.1);
        var dir_to_target = point_direction(x, y, target_x, target_y);
        
        // Base movement toward path
        move_x = lengthdir_x(move_speed, dir_to_target);
        move_y = lengthdir_y(move_speed, dir_to_target);
        
        // Blend with avoidance forces
        move_x += avoid_x;
        move_y += avoid_y;
        
        // Clamp speed
        var final_speed = point_distance(0, 0, move_x, move_y);
        if (final_speed > move_speed) {
            move_x = (move_x / final_speed) * move_speed;
            move_y = (move_y / final_speed) * move_speed;
        }
    }
}

// --- Check Future Position for Overlaps ---
var future_x = x + move_x;
var future_y = y + move_y;

// Only move if the new position doesn’t overlap with others
if (!place_meeting(future_x, future_y, object_index)) {
    x = future_x;
    y = future_y;
} else {
    // Optional: Recalculate path immediately
    path_update_timer = 0;
}

// --- Final Overlap Check (Soft Reset) ---
if (place_meeting(x, y, object_index)) {
    // Gently nudge overlapping instances apart
    x = lerp(x, xprevious, 0.5);
    y = lerp(y, yprevious, 0.5);
}

if health_points = 0 {instance_destroy()}