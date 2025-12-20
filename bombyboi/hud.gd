extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Main.starting_lives == 1:
		$p1_lives.text = "Player 1: %d Life" %Main.starting_lives
		$p2_lives.text = "Player 2: %d Life" %Main.starting_lives
		$p3_lives.text = "Player 3: %d Life" %Main.starting_lives
	else:
		$p1_lives.text = "Player 1: %d Lives" %Main.starting_lives
		$p2_lives.text = "Player 2: %d Lives" %Main.starting_lives
		$p3_lives.text = "Player 3: %d Lives" %Main.starting_lives


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
