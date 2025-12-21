extends BaseBomb

class_name BombeInFlesche

var location: Vector2i:
	set(new_location):
		location = new_location
		set_position(bombas.map_to_local(location))

var direction: Vector2i

var move_timer = Timer.new()

func _ready() -> void:
	super._ready()
	sprite = $Sprite2D
	add_to_group("bombs")
	add_child(move_timer)
	move_timer.wait_time = Main.BOMBE_IN_FLESCHE_MOVE_FREQ
	move_timer.timeout.connect(move)
	move_timer.one_shot = false
	move_timer.start()
	
func move() -> void:
	var new_location = location + direction
	if map.tile_collides(new_location) or map.collides_player(new_location):
		move_timer.stop()
		_on_explode()
	else:
		location = new_location

func get_tile() -> Vector2i:
	return location

func danger_zone() -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	for x in 3:
		for y in 3:
			var tile = location + Vector2i(x - 1, y - 1)
			var collides = map.tile_collides(tile)
			var explodes = map.tile_explodes(tile)
			if not collides or explodes:
				tiles.append(tile)
	return tiles

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
