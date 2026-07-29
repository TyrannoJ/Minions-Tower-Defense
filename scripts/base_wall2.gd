extends StaticBody3D
@onready var area=$area
func _ready() -> void:
	area.kill.connect(kill)
	
func kill():
	queue_free()
	
