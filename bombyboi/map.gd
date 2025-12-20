extends Node

var spawnpoints = {
	1: Vector2i(1,1),
	2: Vector2i(18,8)
}

var player_count = spawnpoints.size()

@onready var terrain := get_node("/root/Map/Terrain")

@export var player_scene: PackedScene



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for player in spawnpoints:
		var psc = player_scene.instantiate()
		psc.set_position(terrain.map_to_local(spawnpoints[player]))
		psc.player_id = player
		add_child(psc)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
