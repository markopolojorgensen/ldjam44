extends Area2D

func _ready():
	$animated_sprite.play()

func _on_animated_sprite_frame_changed():
	if $animated_sprite.frame == 0:
		if $animated_sprite.flip_h:
			# untested :D
			position.x -= 4*6
		else:
			position.x += 4*6

func _on_enemy_body_entered(body):
	if body.has_method("hit_by_enemy"):
		body.hit_by_enemy()
		queue_free()

func is_enemy():
	return true
