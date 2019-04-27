extends CanvasLayer

signal try_again

const clear = Color(1,1,1,0)
const solid = Color(1,1,1,1)

func _ready():
	# hide
	$v_box_container.modulate = clear
	
	$tween.interpolate_property($v_box_container, "modulate", clear, solid, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$tween.start()

func try_again():
	emit_signal("try_again")
