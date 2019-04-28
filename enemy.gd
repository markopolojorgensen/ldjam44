extends Area2D

export(bool) var start_idle = false

var destination
const max_idle_time = 1

var rage_target

func _ready():
	$animated_sprite.play()
	
	# pick random speed
	$animated_sprite.frames.set_animation_speed("default", rand_range(10, 20))
	
	# randomize aggro interval
	$aggro_timer.wait_time = 1.5 + randf()
	
	global_position.y = 720
	
	if start_idle:
		idle_wander()

func _process(delta):
	if rage_target and not rage_target.is_manned():
		# stop raging
		rage_target = null
		$animated_sprite.frames.set_animation_speed("default", rand_range(10, 20))
		if start_idle:
			idle_wait()
		else:
			# resume heading towards the base
			destination = 4602
	
	
	if destination and abs(destination - global_position.x) > (4 * 6):
		$animated_sprite.play()
		if destination < global_position.x:
			$animated_sprite.flip_h = true
		else:
			$animated_sprite.flip_h = false
	else:
		$animated_sprite.stop()

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
	$animated_sprite.stop()

func idle_wander():
	var random_dest = (randi() % (64 * 6)) - (32 * 6)
	destination = global_position.x + random_dest
	$idle_wander_timer.wait_time = randf() * max_idle_time
	$idle_wander_timer.start()
	$animated_sprite.play()

func hit_by_wall():
	queue_free()

func check_aggro():
	var towers = $tower_awareness.get_overlapping_areas()
	for tower in towers:
		if not "manned" in tower:
			print("unmannable tower? " + str(tower))
		elif tower.is_manned():
			# stop idling
			$idle_wait_timer.stop()
			$idle_wander_timer.stop()
			# rage
			rage_target = tower
			destination = tower.global_position.x
			$animated_sprite.frames.set_animation_speed("default", 50)


