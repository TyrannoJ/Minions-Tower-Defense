extends Area3D

@onready var timer=$Timer
var number=0
@onready var number_mesh=$number
func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index==1 and event.is_released():
		if number>0:
			Global.add_player.emit(position)
			number-=1


func _on_timer_timeout() -> void:
	number+=1
	timer.start(randi_range(10,15))

func _process(delta: float) -> void:
	var me=number_mesh.mesh
	me.text=str(number)
