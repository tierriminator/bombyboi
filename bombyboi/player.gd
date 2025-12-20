extends CharacterBody2D

var map_position: Vector2i

var player_id: int

@onready var moveup = "p%d_move_up" % player_id
@onready var movedown = "p%d_move_down" % player_id
@onready var moveright = "p%d_move_right" % player_id
@onready var moveleft = "p%d_move_left" % player_id

@onready var terrainmap_path := get_node("/root/Map/Terrain")

func check_terrain(p_movedir: Vector2i) -> TileData:
	return terrainmap_path.get_cell_tile_data(p_movedir)

func _physics_process(delta: float) -> void:
	var movedir: Vector2i
	if Input.is_action_just_pressed(movedown):
		movedir = Vector2i(0,1)
	elif Input.is_action_just_pressed(moveup):
		movedir = Vector2i(0,-1)
	elif Input.is_action_just_pressed(moveright):
		movedir = Vector2i(1,0)
	elif Input.is_action_just_pressed(moveleft):
		movedir = Vector2i(-1,0)
	else:
		movedir = Vector2i(0,0)
	
	map_position = terrainmap_path.local_to_map(position)
	movedir = map_position + movedir
	if check_terrain(movedir).get_collision_polygons_count(0) == 0:
		set_position(terrainmap_path.map_to_local(movedir))
	#move_and_slide()
