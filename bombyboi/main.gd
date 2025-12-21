extends Node

var player_count: int
var starting_lives: int
var remaining_player_count: int
var result: Array

var ENERGY_SPAWN_P = 0.3
var PINK_ENERGY_P = 0.2

enum EnergyType { GREEN, PINK }

enum Orientation { UP, DOWN, RIGHT, LEFT }

func load_map(map_path: String) -> void:
	
	ResourceLoader.load_threaded_request(map_path)
	#can add stuff here to do between loading the map and starting the scene transition
	
	get_tree().change_scene_to_packed(
		ResourceLoader.load_threaded_get(map_path)
	)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
