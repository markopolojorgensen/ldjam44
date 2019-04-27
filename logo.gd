extends MarginContainer

func _ready():
	$CenterContainer/Control/AnimatedSprite.hide()

func begin():
	$CenterContainer/Control/AnimatedSprite.show()
	$CenterContainer/Control/AnimatedSprite.play()
