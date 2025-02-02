// Clean up the path to prevent memory leaks
if (my_path != -1) {
    path_delete(my_path);
}