extends Node2D

const spawn_interval_min = 0.5
const spawn_interval_max = 5.5
const game_time = 360.0 # six minutes

class BallProximitySorter:
	# point is not a vector, just an x value
	var point = 0
	func proximity_compare(a, b):
		return abs(point - a.global_position.x) < abs(point - b.global_position.x)

var disco_balls = []

var total_time_elapsed = 0
var calibrated = true

const disco_ball_scene = preload("res://disco_ball.tscn")
const minion_scene = preload("res://minion.tscn")
const enemy_scene = preload("res://enemy.tscn")
const lightning_strike_scene = preload("res://lightning_strike.tscn")
const lose_hud_scene = preload("res://lose_hud.tscn")
const win_hud_scene = preload("res://win_hud.tscn")
const wall_scene = preload("res://wall.tscn")
const portal_scene = preload("res://portal.tscn")

var health = 20
var dead = false
var won = false

var enemy_spawn_left = true

func _ready():
	$base.connect("activated", self, "spawn_minion")
	$base.connect("hit_by_enemy", self, "update_health", [-2])
	
	$storm.full_width = $ground.get_children().size() * (256 * 6)
	
	update_health(0)
	
	for rod in $rods.get_children():
		rod.connect("strike_captured", self, "strike_captured")
		rod.connect("taken_by_worms", self, "open_portal")

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
	elif event.is_action_pressed("spawn_wall"):
		get_tree().set_input_as_handled()
		var inst = wall_scene.instance()
		inst.connect("drain", self, "wall_drain")
		$walls.add_child(inst)
		inst.update_x(get_global_mouse_position().x)
		inst.global_position.y = 720

func _process(delta):
	total_time_elapsed += delta
	
	# $HUD/debug.text = "time elapsed: %0.0f\nspawn interval: %0.1f" % [total_time_elapsed, $enemy_spawn_timer.wait_time]
	var game_percent = total_time_elapsed / game_time
	$HUD/margin_container/health_bar/texture_rect/difficulty_gauge.value = game_percent
	
	if fmod(total_time_elapsed, 10) < 1 and not calibrated:
		# calibrate enemy spawn interval
		var weight = total_time_elapsed / game_time
		$enemy_spawn_timer.wait_time = lerp(spawn_interval_max, spawn_interval_min, clamp(weight, 0, 1))
		calibrated = true
	elif fmod(total_time_elapsed, 10) > 9 and calibrated:
		# reset for next calibration round
		calibrated = false
		
	
	if health < 10:
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
	
	inst.destination = $base.global_position.x
	
	if enemy_spawn_left:
		inst.global_position = $enemy_spawn_point_left.global_position
	else:
		inst.global_position = $enemy_spawn_point_right.global_position
	
	enemy_spawn_left = not enemy_spawn_left
	

func update_health(value):
	if dead or won:
		# ignore
		return
	
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
		$win_timer.start()
		$base.ignore_clicks()
	
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

func disco_stopped(ball):
	# print("stopping disco at " + str(ball.global_position.x))
	disco_balls.remove(disco_balls.find(ball))
	for minion in $minions.get_children():
		if minion.assigned_ball == ball:
			minion.free_ball()

func try_again():
	get_tree().reload_current_scene()

func strike_captured():
	update_health(3)

func wall_drain():
	update_health(-1)

func open_portal(location):
	var inst = portal_scene.instance()
	var weight = clamp(total_time_elapsed / game_time, 0, 1)
	inst.number_of_worms = floor(lerp(2, 10, weight))
	inst.connect("spawn_worm", self, "portal_spawn_enemy")
	$portals.add_child(inst)
	inst.global_position.x = location

func portal_spawn_enemy(location):
	var inst = enemy_scene.instance()
	$enemies.add_child(inst)
	
	inst.destination = $base.global_position.x
	
	inst.global_position.x = location

