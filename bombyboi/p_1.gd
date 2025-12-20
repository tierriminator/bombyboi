extends TextureRect

func _on_timer_timeout() -> void:
	set_rotation_degrees(-get_rotation_degrees())
