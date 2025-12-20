extends Node

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

@onready var terrain := get_node("/root/Map/Terrain")

@export var player_scene: PackedScene



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
	
func place_players(players: int) -> void:
	for player in players:
		create_player(player)
		
func create_player(player: int) -> void:
	var psc = player_scene.instantiate()
	psc.player_id = player
	psc.get_node("Sprite2D").texture = faces[player]
	psc.set_position(terrain.map_to_local(get_random_spawn()))
	add_child(psc)
		
func get_random_spawn() -> Vector2i:
	var pos = Vector2i(randi_range(1, 18), randi_range(1, 8))
	while (get_type(pos) == 1):
		pos = Vector2i(randi_range(1, 18), randi_range(1, 8))
	return pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
