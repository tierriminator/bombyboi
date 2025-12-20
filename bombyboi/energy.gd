extends StaticBody2D

class_name Energy

var type: Main.EnergyType

var green_texture = preload("res://Art/energy.png")
var pink_texture = preload("res://Art/energy2.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("energies")
	match type:
		Main.EnergyType.GREEN:
			$Sprite2D.texture = green_texture
		Main.EnergyType.PINK:
			$Sprite2D.texture = pink_texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
