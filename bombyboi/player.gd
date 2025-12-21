extends CharacterBody2D

class_name Player

var pouch_texture: Texture2D = preload("res://Art/pouch.png")

var bomb_scene: PackedScene = preload("res://bomb.tscn")

var player_id: int

@onready var moveup = "p%d_move_up" % player_id
@onready var movedown = "p%d_move_down" % player_id
@onready var moveright = "p%d_move_right" % player_id
@onready var moveleft = "p%d_move_left" % player_id
@onready var place_bomb_input = "p%d_place_bomb" % player_id

@onready var map: Map = get_node("/root/Map")
@onready var terrain := get_node("/root/Map/Terrain")
@onready var bombas_layer := get_node("/root/Map/Bombas")

var max_bombs = 1
var bomb_range = 1
var orientation: Main.Orientation = Main.Orientation.DOWN
var bottle_count = 0
var pouch: Sprite2D
var is_dead = false
var is_ai: bool = false

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
	if is_ai:
		var timer = Timer.new()
		add_child(timer)
		timer.one_shot = false
		timer.timeout.connect(ai_action)
		timer.wait_time = 0.5
		timer.start()

func _physics_process(delta: float) -> void:
	var map_position = terrain.local_to_map(position)
	if not is_ai:
		action_move(map_position)
		action_place_bomb(map_position)
	
func action_move(map_position: Vector2i) -> void:
	var movedir: Vector2i = Vector2i(0, 0)
	if Input.is_action_just_pressed(movedown):
		movedir += Vector2i(0,1)
	if Input.is_action_just_pressed(moveup):
		movedir += Vector2i(0,-1)
	if Input.is_action_just_pressed(moveright):
		movedir += Vector2i(1,0)
	if Input.is_action_just_pressed(moveleft):
		movedir += Vector2i(-1,0)
	move(map_position, movedir)
	
func ai_action() -> void:
	var map_position = terrain.local_to_map(position)
	var visible_tiles = get_visible_tiles()
	var possible_destinations = visible_tiles.filter(func (t): return not map.collides(t) and map_position.distance_squared_to(t) == 1)
	var possible_steps: Array[Vector2i] = []
	possible_steps.assign(possible_destinations.map(func (t): return t - map_position))

	var all_bombs = map.get_bombs()

	# Filter steps to never decrease effective distance to any bomb
	var safe_steps: Array[Vector2i] = []
	safe_steps.assign(possible_steps.filter(func (s): return is_safe_step(s, map_position, all_bombs)))

	# Check if we're in danger from any bomb
	var in_danger = false
	for bomb in all_bombs:
		if bomb.in_danger_zone(map_position):
			in_danger = true
			break

	if in_danger:
		flee(possible_steps)
		return
	var visible_players: Array[Vector2i] = []
	visible_players.assign(visible_tiles.filter(func (t): return map.has_player(t, player_id)))
	if not visible_players.is_empty() and randf() < 0.5 and bomb_count() > 0:
		attack_players(visible_players, safe_steps)
		return

	# Move towards closest visible item
	var visible_items: Array[Vector2i] = []
	visible_items.assign(visible_tiles.filter(func (t): return map.has_item(t)))
	if not visible_items.is_empty():
		var target = get_closest_tile(visible_items, map_position)
		var step = get_step_towards(target, map_position)
		if step in safe_steps:
			move(map_position, step)
		elif not safe_steps.is_empty():
			move(map_position, safe_steps.pick_random())
		return

	# Attack rocks
	var visible_rocks: Array[Vector2i] = []
	visible_rocks.assign(visible_tiles.filter(func (t): return map.is_rock(t)))
	if not visible_rocks.is_empty() and can_place_bomb():
		attack_targets(visible_rocks, safe_steps, map_position)
		return

	# Random step
	if not safe_steps.is_empty():
		move(map_position, safe_steps.pick_random())

func attack_targets(targets: Array[Vector2i], possible_steps: Array[Vector2i], map_position: Vector2i) -> void:
	if bottle_count == 0:
		attack_targets_without_bottle(targets, map_position)
	else:
		attack_targets_with_bottle(targets, possible_steps, map_position)

func attack_targets_without_bottle(targets: Array[Vector2i], map_position: Vector2i) -> void:
	for target_tile in targets:
		if is_in_range(target_tile):
			place_bomb(map_position)
			return

	if randf() < 0.5:
		var closest = get_closest_tile(targets, map_position)
		move(map_position, get_step_towards(closest, map_position))
	else:
		place_bomb(map_position)

func attack_targets_with_bottle(targets: Array[Vector2i], possible_steps: Array[Vector2i], map_position: Vector2i) -> void:
	for target_tile in targets:
		var diff = target_tile - map_position
		var dist = abs(diff.x) + abs(diff.y)
		if dist >= 3 and is_facing(target_tile, map_position):
			place_bomb(map_position)
			return

	var far_targets: Array[Vector2i] = []
	for target_tile in targets:
		var diff = target_tile - map_position
		var dist = abs(diff.x) + abs(diff.y)
		if dist >= 4:
			far_targets.append(target_tile)

	if not far_targets.is_empty():
		var target = far_targets.pick_random()
		move(map_position, get_step_towards(target, map_position))
		return

	var escape_steps: Array[Vector2i] = []
	for step in possible_steps:
		var new_pos = map_position + step
		for target_tile in targets:
			if new_pos.distance_squared_to(target_tile) > map_position.distance_squared_to(target_tile):
				escape_steps.append(step)
				break

	if not escape_steps.is_empty():
		move(map_position, escape_steps.pick_random())
	else:
		move(map_position, possible_steps.pick_random())

func get_closest_tile(tiles: Array[Vector2i], from: Vector2i) -> Vector2i:
	var closest = tiles[0]
	var closest_dist = from.distance_squared_to(closest)
	for tile in tiles:
		var dist = from.distance_squared_to(tile)
		if dist < closest_dist:
			closest_dist = dist
			closest = tile
	return closest

func get_visible_tiles() -> Array[Vector2i]:
	var map_position = terrain.local_to_map(position)
	var out: Array[Vector2i] = [map_position]
	for d in Main.DIRECTIONS:
		var i = 1
		while true:
			var next = map_position + d*i
			out.append(next)
			if map.collides(next):
				break
			i += 1
	return out
	
func is_in_range(tile: Vector2i) -> bool:
	var map_position = terrain.local_to_map(position)
	var diff = map_position - tile
	var absx = abs(diff.x)
	var absy = abs(diff.y)
	return max(absx, absy) <= bomb_range and min(absx, absy) == 0
	
func flee(possible_steps: Array[Vector2i]) -> void:
	var map_position = terrain.local_to_map(position)
	var all_bombs = map.get_bombs()

	if all_bombs.is_empty():
		return

	# Include staying as an option
	var all_options: Array[Vector2i] = [Vector2i(0, 0)]
	all_options.append_array(possible_steps)

	# Filter to only steps that don't decrease effective distance to any bomb
	var safe_options: Array[Vector2i] = []
	for step in all_options:
		if is_safe_step(step, map_position, all_bombs):
			safe_options.append(step)

	if safe_options.is_empty():
		return

	# Find steps that maximize minimum effective distance
	var best_steps: Array[Vector2i] = []
	var best_min_eff_dist: float = -INF

	for step in safe_options:
		var new_pos = map_position + step
		var min_eff_dist: float = INF
		for bomb in all_bombs:
			var eff_dist = bomb.get_effective_distance(new_pos)
			if eff_dist < min_eff_dist:
				min_eff_dist = eff_dist
		if min_eff_dist > best_min_eff_dist:
			best_min_eff_dist = min_eff_dist
			best_steps = [step]
		elif min_eff_dist == best_min_eff_dist:
			best_steps.append(step)

	# Prefer directions where we can see further
	var best_visibility: int = -1
	var best_visibility_steps: Array[Vector2i] = []
	for step in best_steps:
		var visibility = get_visibility_in_direction(map_position, step)
		if visibility > best_visibility:
			best_visibility = visibility
			best_visibility_steps = [step]
		elif visibility == best_visibility:
			best_visibility_steps.append(step)

	move(map_position, best_visibility_steps.pick_random())

func get_visibility_in_direction(from: Vector2i, direction: Vector2i) -> int:
	if direction == Vector2i(0, 0):
		return 0
	var count = 0
	var pos = from + direction
	while not map.collides(pos):
		count += 1
		pos += direction
	return count

func is_safe_step(step: Vector2i, from: Vector2i, bombs: Array) -> bool:
	var new_pos = from + step
	for bomb in bombs:
		var old_eff_dist = bomb.get_effective_distance(from)
		var new_eff_dist = bomb.get_effective_distance(new_pos)
		if new_eff_dist < old_eff_dist:
			return false
	return true
		
func attack_players(visible_players: Array[Vector2i], possible_steps: Array[Vector2i]) -> void:
	var map_position = terrain.local_to_map(position)
	attack_targets(visible_players, possible_steps, map_position)

func get_step_towards(target: Vector2i, from: Vector2i) -> Vector2i:
	var diff = target - from
	if diff.x != 0:
		return Vector2i(sign(diff.x), 0)
	else:
		return Vector2i(0, sign(diff.y))

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

func is_facing(target: Vector2i, from: Vector2i) -> bool:
	var diff = target - from
	var dir = get_orientation_vector()
	# Check if target is in the direction we're facing
	if dir.x != 0:
		return sign(diff.x) == dir.x and diff.y == 0
	else:
		return sign(diff.y) == dir.y and diff.x == 0
		
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

func action_place_bomb(map_position: Vector2i) -> void:
	if Input.is_action_just_pressed(place_bomb_input):
		place_bomb(map_position)
			
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
