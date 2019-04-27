extends Camera2D

var velocity = 0
var max_velocity = 1400
var acceleration = 200

# for multiplying with delta
const framerate = 60

func _physics_process(delta):
	var impulse = 0
	if Input.is_action_pressed("ui_right"):
		impulse = acceleration
	elif Input.is_action_pressed("ui_left"):
		impulse = -acceleration
	elif abs(velocity) > 0.1:
		# lurch to a stop
		velocity *= 0.1 * delta * framerate
	
	if abs(velocity + impulse) > max_velocity:
		impulse = max_velocity - abs(velocity)
	velocity += impulse * delta * framerate
	
	position.x += velocity * delta
	
	# enforce limits
	position.x = clamp(position.x, 690, 8526)



