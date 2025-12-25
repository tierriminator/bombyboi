extends CharacterBody2D

class_name BasePlayer

var pouch_texture: Texture2D = preload("res://Art/pouch.png")
var bomb_scene: PackedScene = preload("res://bomb.tscn")

var player_id: int

@onready var map: Map = get_node("/root/Map")
@onready var terrain := get_node("/root/Map/Terrain")
@onready var bombas_layer := get_node("/root/Map/Bombas")

var max_bombs = 1
var bomb_range = 1
var orientation: Main.Orientation = Main.Orientation.DOWN
var bottle_count = 0
var pouch: Sprite2D
var is_dead = false

signal damage(new_lives)

var lives = Main.starting_lives:
	set(value):
		if value < lives:
			lives = value
			damage.emit(lives)
			if lives > 0:
				hurt()
			else:
				die()

func hurt() -> void:
	map.get_node("sounds/damage").play()
	do_hit_animation()

func do_hit_animation() -> void:
	var tween = create_tween()
	tween.tween_property($Sprite2D, "rotation", TAU, 0.3).from(0.0)

func die() -> void:
	map.get_node("sounds/die").play()
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(1.5, 0.0), 0.3)
	tween.tween_property($Sprite2D, "scale", Vector2(0.0, 0.0), 0.2)
	add_to_results()
	is_dead = true
	queue_free()

func add_to_results() -> void:
	if not is_dead:
		Main.result.push_front($Sprite2D.texture)

func _init() -> void:
	add_to_group("players")

func _ready() -> void:
	get_node("/root/Map/Hud/Hud_p%d" %player_id).register_player(self)

func move(map_position: Vector2i, direction: Vector2i) -> void:
	if direction == Vector2i(0,0):
		return
	var o = orientation
	if direction.x > 0:
		o = Main.Orientation.RIGHT
	elif direction.x < 0:
		o = Main.Orientation.LEFT
	if direction.y > 0:
		o = Main.Orientation.DOWN
	elif direction.y < 0:
		o = Main.Orientation.UP
	set_orientation(o)

	var new_tile = map_position + direction
	if not map.collides(new_tile):
		var target_pos = terrain.map_to_local(new_tile)
		map.get_node("sounds/walk").play()
		set_position(target_pos)
		consume_energy(new_tile)
		consume_bottle(new_tile)
	else:
		map.get_node("sounds/wall").play()

func set_orientation(o: Main.Orientation):
	orientation = o
	match o:
		Main.Orientation.DOWN:
			self.rotation = 0
		Main.Orientation.UP:
			self.rotation = PI
		Main.Orientation.RIGHT:
			self.rotation = -PI / 2
		Main.Orientation.LEFT:
			self.rotation = PI / 2

func consume_energy(tile: Vector2i) -> void:
	var energy = map.find_energy(tile)
	if energy != null:
		match energy.type:
			Main.EnergyType.GREEN:
				bomb_range += 1
			Main.EnergyType.PINK:
				max_bombs += 1
		map.get_node("sounds/glugg").play()
		energy.queue_free()

func consume_bottle(tile: Vector2i) -> void:
	var bottle = map.find_bottle(tile)
	if bottle:
		bottle_count += 1
		bottle.queue_free()
		if bottle_count == 1:
			pouch = Sprite2D.new()
			add_child(pouch)
			pouch.texture = pouch_texture

func can_place_bomb() -> bool:
	return bomb_count() < max_bombs

func place_bomb(map_position: Vector2i) -> void:
	if can_place_bomb():
		if bottle_count > 0:
			bottle_count -= 1
			map.throw_bomb(map_position, self)
			if bottle_count == 0:
				pouch.queue_free()
		else:
			map.spawn_bomb(map_position, self)

func bomb_count() -> int:
	return map.get_bombs().filter(func(b): return b.player_id == player_id).size()

func get_orientation_vector() -> Vector2i:
	match orientation:
		Main.Orientation.UP:
			return Vector2i(0, -1)
		Main.Orientation.DOWN:
			return Vector2i(0, 1)
		Main.Orientation.LEFT:
			return Vector2i(-1, 0)
		Main.Orientation.RIGHT:
			return Vector2i(1, 0)
	return Vector2i(0, 0)

func is_in_range(tile: Vector2i) -> bool:
	var map_position = terrain.local_to_map(position)
	return tile in Bomb.get_explosion_tiles(map, map_position, bomb_range)
