extends BasePlayer

class_name HumanPlayer

var moveup: String
var movedown: String
var moveright: String
var moveleft: String
var place_bomb_input: String

func _ready() -> void:
	super._ready()
	moveup = "p%d_move_up" % player_id
	movedown = "p%d_move_down" % player_id
	moveright = "p%d_move_right" % player_id
	moveleft = "p%d_move_left" % player_id
	if player_id == 1 and Main.player_count < 3:
		place_bomb_input = "p3_place_bomb"
	else:
		place_bomb_input = "p%d_place_bomb" % player_id

func _physics_process(delta: float) -> void:
	var map_position = terrain.local_to_map(position)
	action_move(map_position)
	action_place_bomb(map_position)

func action_move(map_position: Vector2i) -> void:
	var movedir: Vector2i = Vector2i(0, 0)
	if Input.is_action_just_pressed(movedown):
		movedir += Vector2i(0,1)
	if Input.is_action_just_pressed(moveup):
		movedir += Vector2i(0,-1)
	if Input.is_action_just_pressed(moveright):
		movedir += Vector2i(1,0)
	if Input.is_action_just_pressed(moveleft):
		movedir += Vector2i(-1,0)
	move(map_position, movedir)

func action_place_bomb(map_position: Vector2i) -> void:
	if Input.is_action_just_pressed(place_bomb_input):
		place_bomb(map_position)
