extends CharacterBody2D

var map_position: Vector2i

@onready var playermap_path := get_node("/root/Map/Players")

@onready var terrainmap_path := get_node("/root/Map/Terrain")

func check_terrain(p_movedir: Vector2i) -> TileData:
	return terrainmap_path.get_cell_tile_data(p_movedir)

func _physics_process(delta: float) -> void:
	var movedir: Vector2i
	if Input.is_action_just_pressed("p1_move_down"):
		movedir = Vector2i(0,1)
	elif Input.is_action_just_pressed("p1_move_up"):
		movedir = Vector2i(0,-1)
	elif Input.is_action_just_pressed("p1_move_right"):
		movedir = Vector2i(1,0)
	elif Input.is_action_just_pressed("p1_move_left"):
		movedir = Vector2i(-1,0)
	else:
		movedir = Vector2i(0,0)
	
	map_position = playermap_path.local_to_map(position)
	movedir = map_position + movedir
	if check_terrain(movedir).get_collision_polygons_count(0) == 0:
		set_position(playermap_path.map_to_local(movedir))
#	move_and_slide()
