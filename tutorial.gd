extends Node2D

func _process(delta):
	if get_child_count() == 0:
		get_tree().paused = false
		queue_free()
