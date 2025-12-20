extends StaticBody2D

var explosion_texture: Texture2D = preload("res://Art/explosion.png")
var bomb_live_seconds = 3.0
var explosion_seconds = 1.0

func _ready() -> void:
	add_to_group("bombs")
	$Timer.wait_time = bomb_live_seconds
	$Timer.one_shot = true
	$Timer.timeout.connect(_on_explode)
	$Timer.start()

func _on_explode() -> void:
	$Sprite2D.texture = explosion_texture
	$CollisionShape2D.set_deferred("disabled", true)

	$Timer.wait_time = explosion_seconds
	$Timer.timeout.disconnect(_on_explode)
	$Timer.timeout.connect(_on_explosion_finished)
	$Timer.start()

func _on_explosion_finished() -> void:
	queue_free()
