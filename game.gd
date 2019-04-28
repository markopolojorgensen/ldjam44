extends Node2D

class BallProximitySorter:
	# point is not a vector, just an x value
	var point = 0
	func proximity_compare(a, b):
		return abs(point - a.global_position.x) < abs(point - b.global_position.x)

var disco_balls = []

const disco_ball_scene = preload("res://disco_ball.tscn")
const minion_scene = preload("res://minion.tscn")
const enemy_scene = preload("res://enemy.tscn")
const lightning_strike_scene = preload("res://lightning_strike.tscn")
const lose_hud_scene = preload("res://lose_hud.tscn")
const win_hud_scene = preload("res://win_hud.tscn")

var health = 20
var dead = false
var won = false

func _ready():
	$base.connect("activated", self, "spawn_minion")
	$base.connect("hit_by_enemy", self, "update_health", [-2])
	
	$storm.full_width = $ground.get_children().size() * (256 * 6)
	
	update_health(0)
	spawn_enemy()

func _unhandled_input(event):
	if event.is_action_pressed("instaquit"):
		get_tree().quit()
	elif event.is_action_pressed("start_disco"):
		get_tree().set_input_as_handled()
		var inst = disco_ball_scene.instance()
		inst.connect("deleted", self, "disco_stopped")
		$disco_balls.add_child(inst)
		disco_balls.append(inst)
		inst.global_position.x = get_global_mouse_position().x
		inst.global_position.y = clamp(get_global_mouse_position().y, 200, 500)

func _process(delta):
	if dead:
		# shake health bar
		$HUD/margin_container/health_bar.rect_position.x = randf() * 6
		$HUD/margin_container/health_bar.rect_position.y = randf() * 6

func spawn_minion():
	update_health(-1)
	
	var inst = minion_scene.instance()
	$minions.add_child(inst)
	inst.global_position = $base.global_position + $base/position_2d.position

func spawn_enemy():
	var inst = enemy_scene.instance()
	$enemies.add_child(inst)
	inst.global_position = $enemy_spawn_point_left.global_position
	$enemy_spawn_point_left/spawn_animation.show()
	$enemy_spawn_point_left/spawn_animation.play()
	inst.position.x += 120

func update_health(value):
	health += value
	
	if health <= 0 and not dead and not won:
		dead = true
		$base/death.show()
		$base/death.play()
		var lose_hud = lose_hud_scene.instance()
		add_child(lose_hud)
		lose_hud.connect("try_again", self, "try_again")
	elif health >= 100 and not dead and not won:
		won = true
		var win_hud = win_hud_scene.instance()
		add_child(win_hud)
		win_hud.connect("try_again", self, "try_again")
	
	$HUD/margin_container/health_bar.value = health

func allocate_minions():
	if disco_balls.size() == 0:
		# print("0 disco balls")
		# nothing to allocate to!
		return
	
	var minions = $minions.get_children()
	var ratio = minions.size() / float(disco_balls.size())
	# print("%s minions, %s disco balls, %s ratio" % [minions.size(), disco_balls.size(), ratio])
	var round_ratio = floor(ratio)
	
	# build assignment list
	var assignments = {}
	for ball in disco_balls:
		assignments[ball] = []
	var unassigned = []
	
	for minion in minions:
		if minion.assigned_ball == null:
			unassigned.append(minion)
		else:
			assignments[minion.assigned_ball].append(minion)
	
	# print(assignments)
	# print(unassigned)
	
	for ball in disco_balls:
		while assignments[ball].size() < round_ratio and unassigned.size() > 0:
			# print("%s < %s, add minions" % [assignments[ball].size(), round_ratio])
			# print("  %s minions left, we good" % unassigned.size())
			var sorter = BallProximitySorter.new()
			sorter.point = ball.global_position.x
			unassigned.sort_custom(sorter, "proximity_compare")
			
			var minion = unassigned.pop_front()
			minion.assign(ball)
			assignments[ball].append(minion)
	
		while assignments[ball].size() > round_ratio:
			# print("%s > %s, remove minions" % [assignments[ball].size(), round_ratio])
			var sorter = BallProximitySorter.new()
			sorter.point = ball.global_position.x
			assignments[ball].sort_custom(sorter, "proximity_compare")
			# pop farthest first
			var minion = assignments[ball].pop_back()
			# print("  %s minions left after removing one" % [assignments[ball].size()])
			minion.free_ball()
			break

func disco_stopped(ball):
	# print("stopping disco at " + str(ball.global_position.x))
	disco_balls.remove(disco_balls.find(ball))
	for minion in $minions.get_children():
		if minion.assigned_ball == ball:
			minion.free_ball()

func try_again():
	get_tree().reload_current_scene()

func _on_rod_detector_body_entered(body):
	# lightning strike
	var inst = lightning_strike_scene.instance()
	add_child(inst)
	if not body.has_method("get_strike_position"):
		print("body without strike position? " + str(body))
		return
	
	inst.global_position = body.get_strike_position()
	
	if body.is_manned():
		update_health(3)

func _on_rod_detector_area_entered(area):
	_on_rod_detector_body_entered(area)





