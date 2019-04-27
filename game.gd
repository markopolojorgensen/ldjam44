extends Node2D

var disco_balls = []

const disco_ball_scene = preload("res://disco_ball.tscn")
const minion_scene = preload("res://minion.tscn")

func _ready():
	$base.connect("activated", self, "spawn_minion")

func _unhandled_input(event):
	if event.is_action_pressed("instaquit"):
		get_tree().quit()
	elif event.is_action_pressed("start_disco"):
		get_tree().set_input_as_handled()
		var inst = disco_ball_scene.instance()
		$disco_balls.add_child(inst)
		inst.global_position.x = get_global_mouse_position().x
		inst.global_position.y = clamp(get_global_mouse_position().y, 200, 500)


func spawn_minion():
	var inst = minion_scene.instance()
	$minions.add_child(inst)
	inst.global_position = $base.global_position + $base/position_2d.position



