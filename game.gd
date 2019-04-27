extends Node2D

var disco_balls = []

const disco_ball_scene = preload("res://disco_ball.tscn")
const minion_scene = preload("res://minion.tscn")
const enemy_scene = preload("res://enemy.tscn")
const lose_hud_scene = preload("res://lose_hud.tscn")

var health = 20
var dead = false

func _ready():
	$base.connect("activated", self, "spawn_minion")
	$base.connect("hit_by_enemy", self, "update_health", [-1])
	
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
		inst.global_position.x = get_global_mouse_position().x
		inst.global_position.y = clamp(get_global_mouse_position().y, 200, 500)

func _process(delta):
	if dead:
		# shake health bar
		$HUD/margin_container/health_bar.rect_position.x = randf() * 6
		$HUD/margin_container/health_bar.rect_position.y = randf() * 6

func spawn_minion():
	update_health(-5)
	
	var inst = minion_scene.instance()
	$minions.add_child(inst)
	inst.global_position = $base.global_position + $base/position_2d.position

func spawn_enemy():
	var inst = enemy_scene.instance()
	$enemies.add_child(inst)
	inst.global_position = $enemy_spawn_point_left.global_position
	inst.position.x += 120

func update_health(value):
	health += value
	
	if health <= 0 and not dead:
		dead = true
		$base/death.show()
		$base/death.play()
		var lose_hud = lose_hud_scene.instance()
		add_child(lose_hud)
		lose_hud.connect("try_again", self, "try_again")
		
	
	$HUD/margin_container/health_bar.value = health

func disco_stopped(where):
	print("TODO: stop disco at " + str(where))

func try_again():
	get_tree().reload_current_scene()
