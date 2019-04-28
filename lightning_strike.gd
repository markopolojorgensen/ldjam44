extends AnimatedSprite

func _ready():
	play()
	$animation_player.play("flash")

func _on_timer_timeout():
	queue_free()
