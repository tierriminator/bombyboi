extends Label

func register_player(player_node: Node) -> void:
	player_node.damage.connect(_on_player_damage)

func _on_player_damage(lives: int) -> void:
	text = ("Player 3: %d Life" %lives)
