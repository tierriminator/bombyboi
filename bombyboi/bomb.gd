extends BaseBomb

class_name Bomb

var live_seconds = 2.0
var explosion_range = 3
var player_id: int

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

func explode_tiles() -> void:
	var bomb_tile = terrain.local_to_map(position)
	var directions = [
		Vector2i(0, -1),
		Vector2i(0, 1),
		Vector2i(-1, 0),
		Vector2i(1, 0),
	]
	
	explode_tile(bomb_tile)

	map.get_node("sounds/bamm").play()

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
				maybe_spawn_item(current)
				break
			
	
func maybe_spawn_item(tile: Vector2i):
	if randf() < Main.ENERGY_SPAWN_P:
		map.spawn_energy(tile)
