extends RigidBody2D

# seconds
const max_idle_time = 5

const max_speed = 400
const acceleration = 50
const framerate = 60

var destination

func _ready():
	$idle_wait_timer.connect("timeout", self, "idle_wander")
	$idle_wander_timer.connect("timeout", self, "idle_wait")
	
	idle_wait()

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
	if destination and abs(destination.x - global_position.x) > (5 * 6):
		var me_to_dest = destination - global_position
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
	goto(global_position + Vector2(random_dest, 0))
	$idle_wander_timer.wait_time = randf() * max_idle_time
	$idle_wander_timer.start()

func goto(target):
	destination = target


