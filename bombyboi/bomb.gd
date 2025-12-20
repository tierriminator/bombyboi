extends StaticBody2D

var explosion_texture: Texture2D = preload("res://Art/explosion.png")
var bomb_live_seconds = 2.0
var explosion_seconds = 0.5

func _ready() -> void:
	add_to_group("bombs")
	$Timer.wait_time = bomb_live_seconds
	$Timer.one_shot = true
	$Timer.timeout.connect(_on_explode)
	$Timer.start()

func _on_explode() -> void:
	$Sprite2D.texture = explosion_texture
	$CollisionShape2D.set_deferred("disabled", true)

	damage_nearby_players()

	$Timer.wait_time = explosion_seconds
	$Timer.timeout.disconnect(_on_explode)
	$Timer.timeout.connect(_on_explosion_finished)
	$Timer.start()

func damage_nearby_players() -> void:
	var terrain = get_node("/root/Map/Terrain")
	var bomb_tile = terrain.local_to_map(position)
	var explosion_tiles = [
		bomb_tile,
		bomb_tile + Vector2i(0, -1),
		bomb_tile + Vector2i(0, 1),
		bomb_tile + Vector2i(-1, 0),
		bomb_tile + Vector2i(1, 0),
	]

	for player in get_tree().get_nodes_in_group("players"):
		var player_tile = terrain.local_to_map(player.position)
		if player_tile in explosion_tiles:
			player.lives -= 1

func _on_explosion_finished() -> void:
	queue_free()
