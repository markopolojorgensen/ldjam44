extends Node2D

const delete_distance = 6 * 10

var highlighted = false

func _ready():
	$animated_sprite.play()

func _input(event):
	if event.is_action_pressed("start_disco"):
		var distance_to_mouse = (get_global_mouse_position() - global_position).length()
		if distance_to_mouse < delete_distance:
			get_tree().set_input_as_handled()
			queue_free()

func _process(delta):
	var distance_to_mouse = (get_global_mouse_position() - global_position).length()
	if distance_to_mouse < delete_distance and not highlighted:
		# highlight me
		$dark.show()
		$dark.play()
		$dark.frame = $animated_sprite.frame
		highlighted = true
	elif distance_to_mouse > delete_distance:
		highlighted = false
		$dark.stop()
		$dark.hide()
	
