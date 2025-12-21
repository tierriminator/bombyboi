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
	return Bomb.get_explosion_tiles(map, get_tile(), explosion_range)

static func get_explosion_tiles(m: Map, center: Vector2i, expl_range: int) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = [center]
	var directions = [
		Vector2i(0, -1),
		Vector2i(0, 1),
		Vector2i(-1, 0),
		Vector2i(1, 0),
	]
	for dir in directions:
		for i in range(1, expl_range + 1):
			var current = center + dir * i
			var explodes = m.tile_explodes(current)
			if m.tile_collides(current) and not explodes:
				break
			tiles.append(current)
			if explodes:
				break
	return tiles

func maybe_spawn_item(tile: Vector2i):
	if randf() < Main.ENERGY_SPAWN_P:
		map.spawn_energy(tile)
