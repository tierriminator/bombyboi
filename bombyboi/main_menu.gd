extends Control


@export var first_map: PackedScene


func _on_new_game_pressed() -> void:
	load_map(first_map.resource_path)


func load_map(map_path: String) -> void:
	ResourceLoader.load_threaded_request(map_path)
	#can add stuff here to do between loading the map and starting the scene transition
	
	get_tree().change_scene_to_packed(
		ResourceLoader.load_threaded_get(map_path)
	)
