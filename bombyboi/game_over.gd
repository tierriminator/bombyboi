extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for player in Main.result:
		get_node("place_%d" %player).texture = Main.result[player] 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
