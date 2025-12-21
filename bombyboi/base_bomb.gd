extends Node2D

class_name BaseBomb

var explosion_texture: Texture2D = preload("res://Art/explosion.png")
var explosion_seconds = 0.5
var explosion_sprites: Array[Sprite2D] = []
var explosion_range: int = 1

var sprite: Sprite2D

@onready var terrain = get_node("/root/Map/Terrain")
@onready var bombas = get_node("/root/Map/Bombas")
@onready var map: Map = get_node("/root/Map")

func explode_tiles() -> void:
	map.get_node("sounds/bamm").play()
	for tile in danger_zone():
		explode_tile(tile)

func get_tile() -> Vector2i:
	return terrain.local_to_map(position)

func danger_zone() -> Array[Vector2i]:
	assert(false, "Not implemented")
	return []

func in_danger_zone(tile: Vector2i) -> bool:
	return tile in danger_zone()

func get_effective_distance(tile: Vector2i) -> float:
	if not in_danger_zone(tile):
		return INF
	return tile.distance_squared_to(get_tile())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_explode() -> void:
	sprite.visible = false

	explode_tiles()
	
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = explosion_seconds
	timer.timeout.connect(_on_explosion_finished)
	timer.start()
	
func explode_tile(tile: Vector2i):
	spawn_explosion_sprite(tile)
	damage_players(tile)
	explode_map_tile(tile)
	
func spawn_explosion_sprite(tile: Vector2i) -> void:
	var explosion_sprite = Sprite2D.new()
	explosion_sprite.texture = explosion_texture
	explosion_sprite.position = bombas.map_to_local(tile)
	bombas.add_child(explosion_sprite)
	explosion_sprites.append(explosion_sprite)

func damage_players(explosion_tile: Vector2i) -> void:
	if get_tree():
		for player in get_tree().get_nodes_in_group("players"):
			var player_tile = bombas.local_to_map(player.position)
			if player_tile == explosion_tile:
				player.lives = max(player.lives - 1, 0)
				
func explode_map_tile(tile: Vector2i) -> void:
	if map.tile_explodes(tile):
		map.spawn_item(tile)
		map.set_tile_to_empty(tile)
	
func _on_explosion_finished() -> void:
	for explosion_sprite in explosion_sprites:
		explosion_sprite.queue_free()
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
