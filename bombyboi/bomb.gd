extends BaseBomb

class_name Bomb

var live_seconds = 2.0

func _ready() -> void:
	super._ready()
	sprite = $Sprite2D
	add_to_group("bombs")
	var live_timer = Timer.new()
	add_child(live_timer)
	live_timer.wait_time = live_seconds
	live_timer.one_shot = true
	live_timer.timeout.connect(_on_explode)
	live_timer.start()

func danger_zone() -> Array[Vector2i]:
	var bomb_tile = get_tile()
	var tiles: Array[Vector2i] = [bomb_tile]
	var directions = [
		Vector2i(0, -1),
		Vector2i(0, 1),
		Vector2i(-1, 0),
		Vector2i(1, 0),
	]

	for dir in directions:
		for i in range(1, explosion_range + 1):
			var current = bomb_tile + dir * i
			var explodes = map.tile_explodes(current)
			if map.tile_collides(current) and not explodes:
				break
			tiles.append(current)
			if explodes:
				break

	return tiles

func maybe_spawn_item(tile: Vector2i):
	if randf() < Main.ENERGY_SPAWN_P:
		map.spawn_energy(tile)
