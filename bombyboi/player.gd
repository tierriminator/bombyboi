extends CharacterBody2D

var map_position: Vector2i

@onready var playermap_path := get_node("/root/Map/Players")

@onready var terrainmap_path := get_node("/root/Map/Terrain")


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	map_position = playermap_path.local_to_map(position)
	if Input.is_action_just_pressed("p1_move_down"):
		print(map_position)
		set_position(playermap_path.map_to_local(map_position + Vector2i(0,1)))
#	move_and_slide()
