extends Area3D

@onready var timer=$Timer
var number=0
@onready var number_mesh=$number
@onready var button_mesh=$mesh
@onready var mat=$mesh.get_active_material(0)
func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	
	if event is InputEventMouseButton and event.button_index==1 and event.is_released():
		
		if number>0:
			for i in range(0,number):
				Global.add_player.emit(position)
			number=0


func _on_timer_timeout() -> void:
	if Global.player_number+number < Global.MAX_PLAYERS:
		number+=1
	timer.start(randf_range(1,2))

func _process(delta: float) -> void:
	
	var me=number_mesh.mesh
	me.text=str(number)



func _on_mouse_entered() -> void:
	mat.albedo_color=Color.from_hsv(0.61, 0.753, 1.0, 1.0)
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	mat.albedo_color=Color.from_hsv(1,0,1)
	pass # Replace with function body.
