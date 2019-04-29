extends Area2D

signal strike_captured
signal taken_by_worms(location)

var manned = false

func _ready():
	$minion.hide()
	$initial_delay.wait_time = randf() * 15
	$initial_delay.start()

func do_strike():
	$lightning_strike.go()
	if manned:
		emit_signal("strike_captured")
		$strike_audio2.stop()
		$strike_audio2.play()
	else:
		$strike_audio.stop()
		$strike_audio.play()

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
		if $enemy_detector.get_overlapping_areas().size() == 0:
			add_minion()
			body.queue_free()
	elif body.has_method("is_enemy") and body.is_enemy() and manned:
		remove_minion()
		body.queue_free()
		emit_signal("taken_by_worms", global_position.x + rand_range(-64 * 6, 64 * 6))

func start_strikes():
	do_strike()
	$strike_interval.start()



