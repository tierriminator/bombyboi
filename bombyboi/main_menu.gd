extends Control

func _ready() -> void:
	$AudioStreamPlayer.play()

func _on_new_game_pressed() -> void:
	Main.player_count = $MenuCenter/PlayerCount.get_selected_id() + 1
	if Main.player_count == 1:
		Main.ai_count = 1
	else:
		Main.ai_count = 0
	Main.starting_lives = $MenuCenter/StartingLives.get_selected_id() + 1
	Main.load_map(Main.map.resource_path)

# get_tree().get_nodes_in_group("players")
