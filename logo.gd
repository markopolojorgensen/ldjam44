extends CanvasLayer

const solid_color = Color(1,1,1,1)
const clear_color = Color(1,1,1,0)

export(bool) var skip = false

func _ready():
	if skip:
		delete()
	
	$margin_container.show()
	
	$begin_timer.connect("timeout", self, "begin")
	$end_timer.connect("timeout", self, "end")
	$delete_timer.connect("timeout", self, "delete")
	
	$margin_container/center_container/control/animated_sprite.hide()

func begin():
	$margin_container/center_container/control/animated_sprite.show()
	$margin_container/center_container/control/animated_sprite.play()

func end():
	$tween.interpolate_property($margin_container, "modulate", solid_color, clear_color, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$tween.start()

func delete():
	queue_free()
