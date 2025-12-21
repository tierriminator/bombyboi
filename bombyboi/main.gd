extends Node

var map: PackedScene = preload("res://map.tscn")
var game_over: PackedScene = preload("res://game_over.tscn")
var main_menu: PackedScene = preload("res://main_menu.tscn")


var player_count: int
var ai_count: int
var starting_lives: int
var result: Array

const MAPGEN_WALLS = 15
const MAPGEN_WALL_LENGTH = 10

var ENERGY_SPAWN_P = 0.3
var PINK_ENERGY_P = 0.3
var SPAWN_BOTTLE_P = 0.2

var BOMBE_IN_FLESCHE_MOVE_FREQ = 0.2

enum EnergyType { GREEN, PINK }

enum Orientation { UP, DOWN, RIGHT, LEFT }

func load_map(map_path: String) -> void:
	
	ResourceLoader.load_threaded_request(map_path)
	#can add stuff here to do between loading the map and starting the scene transition
	
	get_tree().change_scene_to_packed(
		ResourceLoader.load_threaded_get(map_path)
	)
	
func orientation_to_direction(o: Main.Orientation) -> Vector2i:
	match o:
		Main.Orientation.UP:
			return Vector2i(0, -1)
		Main.Orientation.DOWN:
			return Vector2i(0, 1)
		Main.Orientation.LEFT:
			return Vector2i(-1, 0)
		Main.Orientation.RIGHT:
			return Vector2i(1, 0)
	return Vector2i(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
