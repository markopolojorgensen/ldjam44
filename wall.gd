extends Area2D

signal drain

var enemies_seen = 0

func _ready():
	$animated_sprite.play()

func filter_enemy(body):
	if not body.has_method("is_enemy") or not body.is_enemy():
		print("not an enemy? " + str(body))
		return
	
	if enemies_seen == 0:
		body.hit_by_wall()
	
	enemies_seen = (enemies_seen + 1) % 2

func drain_interval():
	emit_signal("drain")

func update_x(new_x):
	global_position.x = new_x
	if new_x < 4620:
		$animated_sprite.flip_h = true

func lifetime_up():
	queue_free()


