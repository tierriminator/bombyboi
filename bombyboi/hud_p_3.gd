extends HBoxContainer

func register_player(player_node: Node) -> void:
	player_node.damage.connect(_on_player_damage)

func _on_player_damage(lives: int) -> void:
	get_child(get_child_count()-1).queue_free()
