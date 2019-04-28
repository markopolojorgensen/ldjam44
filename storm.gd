extends Node2D

export(NodePath) var cloud_holder_path
onready var cloud_holder = get_node(cloud_holder_path)

const cloud_scene = preload("res://cloud.tscn")

var full_width = 1 # overwritten by game
var storm_period = 10
var time = 0

func _ready():
	$cloud_spawner.connect("timeout", self, "spawn_cloud")

func _process(delta):
	time = fmod(time + delta, storm_period)
	var weight = ((sin(time * 2 * PI / storm_period) + 1) / 2.0)
	global_position.x = lerp(0, full_width, weight)

func spawn_cloud():
	var inst = cloud_scene.instance()
	cloud_holder.add_child(inst)
	
	var quarter_width = full_width / 4.0
	# poor man's normal distribution
	# randf + randf         ->  0 to 2
	# randf + randf - 1     -> -1 to 1
	var offset = quarter_width * (randf() + randf() - 1)
	inst.global_position.x = global_position.x + offset

