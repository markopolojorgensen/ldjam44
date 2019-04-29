extends Node2D

var velocity
const max_velocity = 50

const max_height = 200

const clear = Color(1,1,1,0)

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
	var max_modulate = Color(1,1,1, (randf() / 2.0) + 0.1) # 0.1 - 0.6
	$tween.interpolate_property(self, "modulate", clear, max_modulate, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$tween.start()
	
	# randomize lifespan
	$lifetime.connect("timeout", self, "lifetime_up")
	$lifetime.wait_time = (randf() * 40) + 40
	$lifetime.start()

func lifetime_up():
	$tween.interpolate_property(self, "modulate", modulate, clear, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$tween.start()
	
	yield(get_tree().create_timer(2.5), "timeout")
	
	queue_free()

func _process(delta):
	position.x += velocity * delta
