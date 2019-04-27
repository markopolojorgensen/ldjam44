extends Node2D

var velocity
const max_velocity = 100

const max_height = 200

const clear = Color(1,1,1,0)

const max_lifetime = 15

func _ready():
	# hide
	modulate = clear
	
	# pick animation
	if randf() > 0.5:
		$animated_sprite.play("cloud_a")
	else:
		$animated_sprite.play("cloud_b")
	
	# pick direction
	velocity = (randf() * max_velocity) - (max_velocity / 2.0)
	
	# pick height
	position.y += randf() * max_height
	
	# fade in
	var max_modulate = Color(1,1,1, (randf() + 1.0) / 2.0)
	$tween.interpolate_property(self, "modulate", clear, max_modulate, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$tween.start()
	
	# randomize lifespan
	$lifetime.wait_time = (randf() * max_lifetime) + 5
	$lifetime.start()
	yield($lifetime, "timeout")
	
	$tween.interpolate_property(self, "modulate", modulate, clear, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$tween.start()
	
	yield(get_tree().create_timer(2.5), "timeout")
	
	queue_free()

func _process(delta):
	position.x += velocity * delta
