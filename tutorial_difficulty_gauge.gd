extends TextureProgress


var rate = 5
var secret_value = 0.0

const framerate = 60


func _process(delta):
	secret_value += rate * delta
	value = int(secret_value)
	if value >= 100:
		secret_value = 0.0
		value = 0
