extends CanvasLayer

func _ready():
	$next.connect("button_up", self, "queue_free")

