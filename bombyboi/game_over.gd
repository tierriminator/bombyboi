extends Control


var main_menu: PackedScene = preload("res://main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer.play()
	for player in Main.result:
		get_node("place_%d" %player).texture = Main.result[player] 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	Main.load_map(main_menu.resource_path)
