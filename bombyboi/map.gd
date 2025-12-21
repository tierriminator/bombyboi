extends Node

class_name Map

var faces = [
	preload("res://Art/tierry.png"),
	preload("res://Art/linus.png"),
	preload("res://Art/micha.png")
]

var walls = [
	Vector2i(4, 1),
	Vector2i(3, 1),
	Vector2i(2, 2),
	Vector2i(1, 3),
	Vector2i(1, 4),
	Vector2i(2, 5),
	Vector2i(5, 2),
	Vector2i(1, 6),
	Vector2i(6, 1)
]

var pink_energy_p = 0.5

@onready var terrain := get_node("/root/Map/Terrain")
@onready var bombas := get_node("/root/Map/Bombas")
@onready var player_layer := get_node("/root/Map/Players")

@export var player_scene: PackedScene
@export var bomb_scene: PackedScene
@export var bombe_in_flesche_scene: PackedScene
@export var energy_scene: PackedScene
@export var flesche_scene: PackedScene



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_map()
	place_players(Main.player_count, Main.ai_count)
	$soundtrack.play()

func create_map() -> void:
	var spawned_walls = 0
	while(spawned_walls < Main.MAPGEN_WALLS):
		var pos = Vector2i(randi_range(1, 18), randi_range(1, 8))
		if get_free_neighbours(pos) > 2:
			spawn_wall(pos)
			spawned_walls += 1
			
	for x in 20:
		for y in 10:
			var pos = Vector2i(x, y)
			if get_type(pos) == 1 and randf() < 0.5:
				set_tile(pos, 2)
				
func spawn_wall(start: Vector2i, steps = 0) -> void:
	set_tile(start, 0)
	if steps < Main.MAPGEN_WALL_LENGTH:
		var next = Vector2i(start.x + [-1, 1].pick_random(), start.y + [-1, 1].pick_random())
		if get_free_neighbours(next) > 2:
			spawn_wall(next, steps + 1)
	
func get_free_neighbours(pos: Vector2i) -> int:
	var count = 0
	for x in [-1, 1]:
		for y in [-1, 1]:
			if get_type(pos + Vector2i(x, y)) == 1:
				count += 1
	return count
				
func get_type(pos: Vector2i) -> int:
	return terrain.get_cell_atlas_coords(pos).y

func set_area(pos: Vector2i, size: Vector2i, type: int) -> void:
	for x in size.x:
		for y in size.y:
			set_tile(pos + Vector2i(x, y), type)
	
func set_tile(pos: Vector2i, type: int) -> void:
	#print("set {0} {1} to {2}".format([str(pos.x), str(pos.y), str(type)]))
	terrain.set_cell(Vector2i(pos.x, pos.y), 1, Vector2i(0, type))
	
func set_tile_to_empty(pos: Vector2i) -> void:
	set_tile(pos, 1)
	
func place_players(players: int, ais: int) -> void:
	var available_characters = range(players+ais)
	for player in players + ais:
		var is_ai = player >= players
		var pos = get_random_spawn()
		var character = available_characters.pick_random()
		create_player(player, character, pos, is_ai)
		available_characters.remove_at(available_characters.find(character))
		set_area(pos - Vector2i(0, 1), Vector2i(1, 3), 1)
		set_area(pos - Vector2i(1, 0), Vector2i(3, 1), 1)
		
func create_player(player: int, character: int, pos: Vector2i, is_ai: bool) -> void:
	var psc = player_scene.instantiate()
	psc.is_ai = is_ai
	psc.player_id = player + 1
	psc.get_node("Sprite2D").texture = faces[character]
	psc.set_position(player_layer.map_to_local(pos))
	player_layer.add_child(psc)
		
func get_random_spawn() -> Vector2i:
	var x_start = 2
	var y_start = 2
	var x_end = 17
	var y_end = 7
	var pos = Vector2i(randi_range(x_start, x_end), randi_range(y_start, y_end))
	while (get_type(pos) == 0 and has_player(pos)):
		pos = Vector2i(randi_range(x_start, x_end), randi_range(y_start, y_end))
	return pos
	
func has_player(pos: Vector2i, except_id: int = -1) -> bool:
	for player in get_tree().get_nodes_in_group("players"):
		if player.player_id != except_id:
			return terrain.local_to_map(player.position) == pos
	return false
		
func collides(tile: Vector2i) -> bool:
	var tile_data = terrain.get_cell_tile_data(tile)
	return tile_data.get_custom_data("has_collision") or has_bomb(tile)
	
func get_bombs() -> Array[BaseBomb]:
	var bombs: Array[BaseBomb] = []
	bombs.assign(get_tree().get_nodes_in_group("bombs"))
	return bombs
	
func has_bomb(tile: Vector2i) -> bool:
	for bomb in get_bombs():
		if bombas.local_to_map(bomb.position) == tile:
			return true
	return false
	
func spawn_bomb(tile: Vector2i, player: Player) -> void:
	if has_bomb(tile):
		return
	var target_pos = terrain.map_to_local(tile)
	var bomb: Bomb = bomb_scene.instantiate()
	bomb.position = target_pos
	bomb.player_id = player.player_id
	bomb.explosion_range = player.bomb_range
	bombas.add_child(bomb)
	$sounds/place_bomb.play()
	
func throw_bomb(tile: Vector2i, player: Player) -> void:
	var bomb: BombeInFlesche = bombe_in_flesche_scene.instantiate()
	bombas.add_child(bomb)
	bomb.player_id = player.player_id
	bomb.location = tile
	bomb.direction = Main.orientation_to_direction(player.orientation)
	$sounds/bombe_in_flesche.play()
	bomb.move()
	
func spawn_item(tile: Vector2i) -> void:
	if randf() < Main.SPAWN_BOTTLE_P:
		spawn_bottle(tile)
	else:
		spawn_energy(tile)
		
func get_bottles() -> Array[Bottle]:
	var bottles: Array[Bottle] = []
	bottles.assign(get_tree().get_nodes_in_group("bottles"))
	return bottles
	
func find_bottle(tile: Vector2i) -> Bottle:
	for bottle in get_bottles():
		if bombas.local_to_map(bottle.position) == tile:
			return bottle
	return null
		
func spawn_bottle(tile: Vector2i) -> void:
	var flesche = flesche_scene.instantiate()
	flesche.position = bombas.map_to_local(tile)
	bombas.add_child(flesche)
	
func get_energies() -> Array[Energy]:
	var energies: Array[Energy] = []
	energies.assign(get_tree().get_nodes_in_group("energies"))
	return energies
	
func find_energy(tile: Vector2i) -> Energy:
	for energy in get_energies():
		if bombas.local_to_map(energy.position) == tile:
			return energy
	return null
	
func has_energy(tile: Vector2i) -> bool:
	return find_energy(tile) != null

func has_bottle(tile: Vector2i) -> bool:
	return find_bottle(tile) != null

func has_item(tile: Vector2i) -> bool:
	return has_energy(tile) or has_bottle(tile)

func is_rock(tile: Vector2i) -> bool:
	var tile_data = terrain.get_cell_tile_data(tile)
	return tile_data != null and tile_data.get_custom_data("can_explode")

func spawn_energy(tile: Vector2i) -> void:
	var energy = energy_scene.instantiate()
	if randf() > Main.PINK_ENERGY_P:
		energy.type = Main.EnergyType.GREEN
	else:
		energy.type = Main.EnergyType.PINK
	energy.position = bombas.map_to_local(tile)
	bombas.add_child(energy)
	
func find_player(tile: Vector2i) -> Player:
	for player in get_players():
		if terrain.local_to_map(player.position) == tile:
			return player
	return null
	
func player_exists(id: int) -> bool:
	for player in get_tree().get_nodes_in_group("players"):
		if (player.player_id == id):
			return true
	return false
	
func get_players() -> Array[Player]:
	var players: Array[Player] = []
	players.assign(get_tree().get_nodes_in_group("players"))
	return players.filter(func (p): return not p.is_dead)
	
func collides_player(tile: Vector2i) -> bool:
	return find_player(tile) != null
	
func tile_collides(tile: Vector2i) -> bool:
	var tile_data = get_tile_data(tile)
	if tile_data == null:
		return false
	return tile_data.get_custom_data("has_collision")
	
func tile_explodes(tile: Vector2i) -> bool:
	var tile_data = get_tile_data(tile)
	if tile_data == null:
		return false
	return tile_data.get_custom_data("can_explode")
	
func get_tile_data(tile: Vector2i) -> TileData:
	return terrain.get_cell_tile_data(tile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var players = get_players()
	if players.size() <= 1:
		for player in players:
			player.add_to_results()
			player.is_dead = true
		Main.load_map(Main.game_over.resource_path)
	
