extends Control

var humans = 2:
	set(x):
		if x >= 0 and x <= 3:
			humans = x
			$CenterControls/HumansControl/Minus.disabled = x == 0
			$CenterControls/HumansControl/Plus.disabled = x == 3
			$CenterControls/HumansControl/Count.text = str(x)
			if x + ais < 2:
				ais = 2 - x
			elif x + ais > 3:
				ais = 3 - x
var ais = 0:
	set(x):
		if x >= 0 and x <= 3:
			ais = x
			$CenterControls/AIControl/Minus.disabled = x == 0
			$CenterControls/AIControl/Plus.disabled = x == 3
			$CenterControls/AIControl/Count.text = str(x)
			if x + humans < 2:
				humans = 2 - x
			elif x + humans > 3:
				humans = 3 - x
var lives = 3:
	set(x):
		if x >= 1 and x <= 3:
			lives = x
			$CenterControls/LivesControl/Minus.disabled = x == 0
			$CenterControls/LivesControl/Plus.disabled = x == 3
			$CenterControls/LivesControl/Count.text = str(x)

func _ready() -> void:
	$AudioStreamPlayer.play()
	humans = 2
	ais = 0
	lives = 3

func _on_new_game_pressed() -> void:
	Main.player_count = humans
	Main.ai_count = ais
	Main.starting_lives = lives
	Main.load_map(Main.map.resource_path)

func _on_human_minus_pressed() -> void:
	humans -= 1

func _on_human_plus_pressed() -> void:
	humans += 1


func _on_ai_minus_pressed() -> void:
	ais -= 1


func _on_ai_plus_pressed() -> void:
	ais += 1


func _on_lives_minus_pressed() -> void:
	lives -= 1


func _on_lives_plus_pressed() -> void:
	lives += 1
