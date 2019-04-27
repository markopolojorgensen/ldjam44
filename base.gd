extends Node2D


signal activated

const highlight_distance = 6 * 16
var highlighted = false

func _input(event):
	if event.is_action_pressed("spawn_minion"):
		var distance_to_mouse = (get_global_mouse_position() - global_position).length()
		if distance_to_mouse < highlight_distance:
			get_tree().set_input_as_handled()
			# we done been clicked
			emit_signal("activated")

func _process(delta):
	var distance_to_mouse = (get_global_mouse_position() - global_position).length()
	if distance_to_mouse < highlight_distance and not highlighted:
		highlighted = true
		$outline.show()
	elif distance_to_mouse > highlight_distance:
		highlighted = false
		$outline.hide()



