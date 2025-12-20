extends CharacterBody2D

var bomb_scene: PackedScene = preload("res://bomb.tscn")

var player_id: int

@onready var moveup = "p%d_move_up" % player_id
@onready var movedown = "p%d_move_down" % player_id
@onready var moveright = "p%d_move_right" % player_id
@onready var moveleft = "p%d_move_left" % player_id
@onready var place_bomb = "p%d_place_bomb" % player_id

@onready var terrainmap_path := get_node("/root/Map/Terrain")
@onready var bombas_layer := get_node("/root/Map/Bombas")

var max_bombs = 1
var bomb_range = 1

var lives = 3:
	set(value):
		if value < lives:
			do_hit_animation()
		lives = value
		if lives <= 0:
			$Sprite2D.flip_v = true

func do_hit_animation() -> void:
	var tween = create_tween()
	tween.tween_property($Sprite2D, "rotation", TAU, 0.3).from(0.0)

func _init() -> void:
	add_to_group("players")

func check_terrain(p_movedir: Vector2i) -> TileData:
	return terrainmap_path.get_cell_tile_data(p_movedir)

func check_bomb(target_pos: Vector2) -> bool:
	for bomb in get_tree().get_nodes_in_group("bombs"):
		if bomb.position == target_pos:
			return true
	return false

func _physics_process(delta: float) -> void:
	
	var map_position = terrainmap_path.local_to_map(position)
	move(map_position)
	maybe_place_bomb(map_position)
		
func move(map_position: Vector2i) -> void:
	var movedir: Vector2i = Vector2i(0, 0)
	if Input.is_action_just_pressed(movedown):
		movedir += Vector2i(0,1)
	if Input.is_action_just_pressed(moveup):
		movedir += Vector2i(0,-1)
	if Input.is_action_just_pressed(moveright):
		movedir += Vector2i(1,0)
	if Input.is_action_just_pressed(moveleft):
		movedir += Vector2i(-1,0)
	
	movedir = map_position + movedir
	var target_pos = terrainmap_path.map_to_local(movedir)
	if check_terrain(movedir).get_collision_polygons_count(0) == 0 and not check_bomb(target_pos):
		set_position(target_pos)
		
func maybe_place_bomb(map_position: Vector2i) -> void:
	if Input.is_action_just_pressed(place_bomb) and bomb_count() < max_bombs:
		var target_pos = terrainmap_path.map_to_local(map_position)
		if check_bomb(target_pos):
			return
		var bomb = bomb_scene.instantiate()
		bomb.position = target_pos
		bomb.player_id = player_id
		bomb.explosion_range = bomb_range
		bombas_layer.add_child(bomb)
		
func bomb_count() -> int:
	return get_tree().get_nodes_in_group("bombs").filter(func(b): return b.player_id == player_id).size()
