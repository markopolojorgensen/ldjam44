extends RigidBody2D

var assigned_ball

# seconds
const max_idle_time = 5

const max_speed = 400
const acceleration = 50
const framerate = 60

var destination

# TODO: wander around once reaching assigned disco ball

func _ready():
	$idle_wait_timer.connect("timeout", self, "idle_wander")
	$idle_wander_timer.connect("timeout", self, "idle_wait")
	
	call_deferred("idle_wander")

func think():
	if assigned_ball and abs(assigned_ball.global_position.x - global_position.x) > (42*6):
		# too far away
		stop_idling()
		destination = assigned_ball.global_position.x + rand_range(-16*6, 16*6)
	elif not is_idling():
		idle_wait()

func is_idling():
	return not $idle_wait_timer.is_stopped() or not $idle_wander_timer.is_stopped()

func _process(delta):
	if linear_velocity.x > 1:
		if $animated_sprite.animation != "move":
			$animated_sprite.play("move")
		$animated_sprite.flip_h = false
	elif linear_velocity.x < -1:
		if $animated_sprite.animation != "move":
			$animated_sprite.play("move")
		$animated_sprite.flip_h = true
	else:
		$animated_sprite.play("default")

func _physics_process(delta):
	if destination and abs(destination - global_position.x) > (5 * 6):
		var me_to_dest = Vector2(destination - global_position.x, 0)
		var impulse = me_to_dest.normalized() * acceleration
		if (linear_velocity + impulse).length() > max_speed:
			var limited_impulse_size = max_speed - linear_velocity.length()
			impulse = impulse.normalized() * limited_impulse_size
		
		apply_central_impulse(impulse * delta * framerate)
	else:
		# no destination, or close enough to destination
		# slow down
		var impulse = -linear_velocity * 0.1
		apply_central_impulse(impulse * delta * framerate)

func idle_wait():
	destination = null
	$idle_wait_timer.wait_time = randf() * max_idle_time
	$idle_wait_timer.start()

func idle_wander():
	var random_dest = (randi() % (64 * 6)) - (32 * 6)
	destination = global_position.x + random_dest
	$idle_wander_timer.wait_time = randf() * max_idle_time
	$idle_wander_timer.start()

func assign(ball):
	assigned_ball = ball

func stop_idling():
	$idle_wait_timer.stop()
	$idle_wander_timer.stop()

func free_ball():
	assigned_ball = null
	idle_wander()

func is_minion():
	return true
