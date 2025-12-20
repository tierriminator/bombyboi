extends CharacterBody2D

class_name Player

var bomb_scene: PackedScene = preload("res://bomb.tscn")

var player_id: int

@onready var moveup = "p%d_move_up" % player_id
@onready var movedown = "p%d_move_down" % player_id
@onready var moveright = "p%d_move_right" % player_id
@onready var moveleft = "p%d_move_left" % player_id
@onready var place_bomb = "p%d_place_bomb" % player_id

@onready var map: Map = get_node("/root/Map")
@onready var terrain := get_node("/root/Map/Terrain")
@onready var bombas_layer := get_node("/root/Map/Bombas")

var max_bombs = 1
var bomb_range = 1

signal damage(new_lives)

var lives = Main.starting_lives:
	set(value):
		if value < lives:
			do_hit_animation()
		lives = value
		damage.emit(lives)
		if lives <= 0:
			$Sprite2D.flip_v = true

func do_hit_animation() -> void:
	var tween = create_tween()
	tween.tween_property($Sprite2D, "rotation", TAU, 0.3).from(0.0)

func _init() -> void:
	add_to_group("players")
	
func _ready() -> void:
	get_node("/root/Map/Hud/p%d_lives" %player_id).register_player(self)

func _physics_process(delta: float) -> void:
	var map_position = terrain.local_to_map(position)
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
	if not map.collides(movedir):
		var target_pos = terrain.map_to_local(movedir)
		set_position(target_pos)
		consume_energy(movedir)
		
func consume_energy(tile: Vector2i) -> void:
	var energy = map.find_energy(tile)
	if energy != null:
		match energy.type:
			Main.EnergyType.GREEN:
				bomb_range += 1
			Main.EnergyType.PINK:
				max_bombs += 1
		energy.queue_free()
		
func maybe_place_bomb(map_position: Vector2i) -> void:
	if Input.is_action_just_pressed(place_bomb) and bomb_count() < max_bombs:
		map.spawn_bomb(map_position, self)
		
func bomb_count() -> int:
	return map.get_bombs().filter(func(b): return b.player_id == player_id).size()
