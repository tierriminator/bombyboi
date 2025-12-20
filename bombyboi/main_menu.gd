extends Control

@export var first_map: PackedScene

func _ready() -> void:
	$AudioStreamPlayer.play()

func _on_new_game_pressed() -> void:
	Main.player_count = $MenuCenter/PlayerCount.get_selected_id() + 1
	Main.starting_lives = $MenuCenter/StartingLives.get_selected_id() + 1
	load_map(first_map.resource_path)

# get_tree().get_nodes_in_group("players")

func load_map(map_path: String) -> void:
	
	ResourceLoader.load_threaded_request(map_path)
	#can add stuff here to do between loading the map and starting the scene transition
	
	get_tree().change_scene_to_packed(
		ResourceLoader.load_threaded_get(map_path)
	)
