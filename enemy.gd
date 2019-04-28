extends Area2D

export(bool) var start_idle = false

var destination
const max_idle_time = 1

func _ready():
	$animated_sprite.play()
	
	global_position.y = 720
	
	if start_idle:
		idle_wander()

func _process(delta):
	if destination:
		if destination < global_position.x:
			$animated_sprite.flip_h = true
		else:
			$animated_sprite.flip_h = false

func _on_animated_sprite_frame_changed():
	if $animated_sprite.frame == 0:
		if $animated_sprite.flip_h:
			position.x -= 4*6
		else:
			position.x += 4*6

func _on_enemy_body_entered(body):
	if body.has_method("hit_by_enemy"):
		body.hit_by_enemy()
		queue_free()

func is_enemy():
	return true

func idle_wait():
	destination = null
	$idle_wait_timer.wait_time = randf() * max_idle_time
	$idle_wait_timer.start()

func idle_wander():
	var random_dest = (randi() % (64 * 6)) - (32 * 6)
	destination = global_position.x + random_dest
	$idle_wander_timer.wait_time = randf() * max_idle_time
	$idle_wander_timer.start()

