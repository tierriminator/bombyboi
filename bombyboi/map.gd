extends Node

class_name Map

var spawnpoints = {
	1: Vector2i(1,1),
	2: Vector2i(18,8)
}

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
	Vector2i(1, 4)
]

var player_count = spawnpoints.size()

var pink_energy_p = 0.5

@onready var terrain := get_node("/root/Map/Terrain")
@onready var bombas := get_node("/root/Map/Bombas")
@onready var player_layer := get_node("/root/Map/Players")

@export var player_scene: PackedScene
@export var bomb_scene: PackedScene
@export var energy_scene: PackedScene



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_map()
	place_players(2)
		
func create_map() -> void:
	for n in 20:
		var segment = walls.pick_random()
		var pos = Vector2i(randi_range(1, 13), randi_range(1, 3))
		set_area(pos, segment  + Vector2i(2, 2), 1)
		set_area(pos + Vector2i(1, 1), segment, 0)
	for x in 20:
		for y in 10:
			var pos = Vector2i(x, y)
			if get_type(pos) == 1 and randf() < 0.5:
				set_tile(pos, 2)
				
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
	
func place_players(players: int) -> void:
	for player in players:
		var pos = get_random_spawn()
		create_player(get_random_player_id(), pos)
		set_area(pos - Vector2i(0, 1), Vector2i(1, 3), 1)
		set_area(pos - Vector2i(1, 0), Vector2i(3, 1), 1)
		
func create_player(player: int, pos: Vector2i) -> void:
	var psc = player_scene.instantiate()
	psc.player_id = player + 1
	psc.get_node("Sprite2D").texture = faces[player]
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
	
func has_player(pos: Vector2i) -> bool:
	for player in get_tree().get_nodes_in_group("players"):
		return terrain.local_to_map(player.position) == pos
	return false
	
func get_random_player_id() -> int:
	var id = randi_range(0, 2)
	while player_exists(id + 1):
		id = (id + 1) % 3
	return id
	
func collides(tile: Vector2i) -> bool:
	var tile_data = terrain.get_cell_tile_data(tile)
	return tile_data.get_custom_data("has_collision") or has_bomb(tile)
	
func get_bombs() -> Array[Bomb]:
	var bombs: Array[Bomb] = []
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
	return find_energy(tile) == null

func spawn_energy(tile: Vector2i) -> void:
	var energy = energy_scene.instantiate()
	if randf() > pink_energy_p:
		energy.type = Main.EnergyType.GREEN
	else:
		energy.type = Main.EnergyType.PINK
	energy.position = bombas.map_to_local(tile)
	bombas.add_child(energy)
	
func player_exists(id: int) -> bool:
	for player in get_tree().get_nodes_in_group("players"):
		if (player.player_id == id):
			return true
	return false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
