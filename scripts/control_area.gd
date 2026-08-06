extends Area3D
@onready var wall_top=$walls/wall2
@onready var wall_bottom=$walls/wall1
@onready var wall_left=$walls/wall4
@onready var wall_right=$walls/wall3
@onready var middle_mesh=$MeshInstance3D
var under_creation=true
var selected=false
func _process(delta: float) -> void:
	wall_top.scale.z=1/scale.z
	wall_bottom.scale.z=1/scale.z
	wall_left.scale.z=1/scale.x
	wall_right.scale.z=1/scale.x
	if selected:
		middle_mesh.show()
	else:
		middle_mesh.hide()
	if !under_creation:
		var col=get_overlapping_bodies()
		for co in col:
			if co.is_in_group("persons"):
				if co.color=="blue":
					if co.color=="blue" :
						co.vision.set_collision_mask_value(6,true)
		
	


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseMotion and event.button_mask==MOUSE_BUTTON_MASK_MIDDLE and selected:
		under_creation=true
		position.x=event_position.x
		position.z=event_position.z
		print("a")
	else:
		under_creation=false
	if event is InputEventMouseButton and event.button_index==2 and event.is_released():
		selected=!selected
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("delete_area") and selected:
		queue_free()
