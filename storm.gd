extends Node2D

export(NodePath) var cloud_holder_path
onready var cloud_layers = get_node(cloud_holder_path)

const cloud_scene = preload("res://cloud.tscn")

var full_width = 1 # overwritten by game
var storm_period = 10
var time = 0

var first = true

func _ready():
	# $cloud_spawner.connect("timeout", self, "spawn_cloud")
	pass

func _process(delta):
	# time = fmod(time + delta, storm_period)
	# var weight = ((sin(time * 2 * PI / storm_period) + 1) / 2.0)
	# global_position.x = lerp(0, full_width, weight)
	pass

func spawn_cloud():
	if first:
		first = false
		for i in range(100):
			spawn_cloud()
	
	var inst = cloud_scene.instance()
	var parent = cloud_layers.get_child(randi() % cloud_layers.get_child_count())
	parent.add_child(inst)
	
	# var quarter_width = full_width / 4.0
	# poor man's normal distribution
	# randf + randf         ->  0 to 2
	# randf + randf - 1     -> -1 to 1
	# var offset = quarter_width * (randf() + randf() - 1)
	# inst.global_position.x = global_position.x + offset
	inst.global_position.x = full_width * randf()

