extends BasePlayer

class_name AIPlayer

var timer: Timer

func _ready() -> void:
	super._ready()
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = false
	timer.timeout.connect(ai_action)
	timer.wait_time = get_random_wait_time()
	timer.start()

func get_random_wait_time() -> float:
	var diff = randf() * Main.AI_WAIT_RANGE * 2 - Main.AI_WAIT_RANGE
	return Main.AI_WAIT_AVG + diff

func ai_action() -> void:
	timer.wait_time = get_random_wait_time()
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
	if not visible_players.is_empty() and can_place_bomb():
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
		else:
			random_step(safe_steps)
		return

	# Attack rocks
	var visible_rocks: Array[Vector2i] = []
	visible_rocks.assign(visible_tiles.filter(func (t): return map.is_rock(t)))
	if not visible_rocks.is_empty() and can_place_bomb():
		attack_targets(visible_rocks, safe_steps, map_position)
		return

	# Random step
	random_step(safe_steps)

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

	# No target in range, move towards closest
	var closest = get_closest_tile(targets, map_position)
	move(map_position, get_step_towards(closest, map_position))

func attack_targets_with_bottle(targets: Array[Vector2i], possible_steps: Array[Vector2i], map_position: Vector2i) -> void:
	for target_tile in targets:
		var diff = target_tile - map_position
		var dist = abs(diff.x) + abs(diff.y)
		if dist >= 2 and is_facing(target_tile, map_position):
			place_bomb(map_position)
			return

	var far_targets: Array[Vector2i] = []
	for target_tile in targets:
		var diff = target_tile - map_position
		var dist = abs(diff.x) + abs(diff.y)
		if dist >= 3:
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
		random_step(escape_steps)
	else:
		random_step(possible_steps)

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

	random_step(best_visibility_steps)

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

func is_facing(target: Vector2i, from: Vector2i) -> bool:
	var diff = target - from
	var dir = get_orientation_vector()
	# Check if target is in the direction we're facing
	if dir.x != 0:
		return sign(diff.x) == dir.x and diff.y == 0
	else:
		return sign(diff.y) == dir.y and diff.x == 0

func random_step(steps: Array[Vector2i]) -> void:
	if steps.is_empty():
		return
	var map_position = terrain.local_to_map(position)
	var orientation_dir = get_orientation_vector()
	if orientation_dir in steps and randf() < 0.5:
		move(map_position, orientation_dir)
	else:
		move(map_position, steps.pick_random())
