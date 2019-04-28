extends AnimatedSprite

signal spawn_worm(location)

var number_of_worms = 5

func _ready():
	global_position.y = 720
	play()

func spawn_worm():
	emit_signal("spawn_worm", global_position.x + (rand_range(-16 * 6, 16 * 6)))
	number_of_worms -= 1
	
	if number_of_worms <= 0:
		queue_free()



