extends CanvasLayer

@export var lives_png: Texture
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if Main.starting_lives == 1:
		#$p1_lives.text = "Player 1: %d Life" %Main.starting_lives
		#$p2_lives.text = "Player 2: %d Life" %Main.starting_lives
		#$p3_lives.text = "Player 3: %d Life" %Main.starting_lives
	#else:
		#$p1_lives.text = "Player 1: %d Lives" %Main.starting_lives
		#$p2_lives.text = "Player 2: %d Lives" %Main.starting_lives
		#$p3_lives.text = "Player 3: %d Lives" %Main.starting_lives
		#
	for i in Main.starting_lives:
		add_live($Hud_p1)
		add_live($Hud_p2)
		add_live($Hud_p3)

func add_live(hudnode: Node) -> void:
	var lives_rect = TextureRect.new()
	lives_rect.set_texture(lives_png)
	hudnode.add_child(lives_rect)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
