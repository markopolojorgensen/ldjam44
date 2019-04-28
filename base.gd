extends StaticBody2D

signal activated
signal hit_by_enemy

const highlight_distance = 6 * 16
var highlighted = false

var ignore_clicks = false

func _ready():
	$death.hide()

func _input(event):
	if not ignore_clicks and event.is_action_pressed("spawn_minion"):
		var distance_to_mouse = (get_global_mouse_position() - global_position).length()
		if distance_to_mouse < highlight_distance:
			get_tree().set_input_as_handled()
			# we done been clicked
			emit_signal("activated")
			$animated_sprite.play("doors")
			$animated_sprite.frame = 0

func _process(delta):
	var distance_to_mouse = (get_global_mouse_position() - global_position).length()
	if distance_to_mouse < highlight_distance and not highlighted and not ignore_clicks:
		highlighted = true
		$outline.show()
		$label.show()
	elif distance_to_mouse > highlight_distance:
		highlighted = false
		$outline.hide()
		$label.hide()

func hit_by_enemy():
	emit_signal("hit_by_enemy")

func ignore_clicks():
	var ignore_clicks = true

