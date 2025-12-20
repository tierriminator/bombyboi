extends StaticBody2D

var explosion_texture: Texture2D = preload("res://Art/explosion.png")
var live_seconds = 2.0
var explosion_seconds = 0.5
var explosion_range = 3
var explosion_sprites: Array[Sprite2D] = []
var player_id: int

@onready var terrain = get_node("/root/Map/Terrain")
@onready var map = get_node("/root/Map")

func _ready() -> void:
	add_to_group("bombs")
	$Timer.wait_time = live_seconds
	$Timer.one_shot = true
	$Timer.timeout.connect(_on_explode)
	$Timer.start()

func _on_explode() -> void:
	$Sprite2D.texture = explosion_texture
	$CollisionShape2D.set_deferred("disabled", true)

	explode_tiles()

	$Timer.wait_time = explosion_seconds
	$Timer.timeout.disconnect(_on_explode)
	$Timer.timeout.connect(_on_explosion_finished)
	$Timer.start()

func explode_tiles() -> void:
	var bomb_tile = terrain.local_to_map(position)
	var directions = [
		Vector2i(0, -1),
		Vector2i(0, 1),
		Vector2i(-1, 0),
		Vector2i(1, 0),
	]

	for dir in directions:
		for i in range(1, explosion_range + 1):
			var current = bomb_tile + dir * i
			var tile_data = terrain.get_cell_tile_data(current)
			if tile_data == null:
				break
			var collides = tile_data.get_custom_data("has_collision")
			var explodes = tile_data.get_custom_data("can_explode")
			if collides and not explodes:
				break
			explode_tile(current)
			if explodes:
				break
			

func explode_tile(tile: Vector2i):
	spawn_explosion_sprite(tile)
	damage_players(tile)
	map.set_tile_to_empty(tile)
	

func spawn_explosion_sprite(tile: Vector2i) -> void:
	var sprite = Sprite2D.new()
	sprite.texture = explosion_texture
	sprite.position = terrain.map_to_local(tile)
	get_parent().add_child(sprite)
	explosion_sprites.append(sprite)

func damage_players(explosion_tile: Vector2i) -> void:
	for player in get_tree().get_nodes_in_group("players"):
		var player_tile = terrain.local_to_map(player.position)
		if player_tile == explosion_tile:
			player.lives = max(player.lives - 1, 0)

func _on_explosion_finished() -> void:
	for sprite in explosion_sprites:
		sprite.queue_free()
	queue_free()
