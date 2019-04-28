extends Area2D

var manned = false

func _ready():
	$minion.hide()

func get_strike_position():
	return $strike_point.global_position

func is_manned():
	return manned

func add_minion():
	$minion.show()
	manned = true

func remove_minion():
	$minion.hide()
	manned = false

func body_entered(body):
	if body.has_method("is_minion") and body.is_minion() and not manned:
		add_minion()
		body.queue_free()
	elif body.has_method("is_enemy") and body.is_enemy() and manned:
		remove_minion()
		body.queue_free()



