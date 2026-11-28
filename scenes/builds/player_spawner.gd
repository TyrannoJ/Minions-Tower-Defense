extends Area3D

@onready var timer=$Timer

@onready var number_mesh=$number
@onready var button_mesh=$mesh
@onready var mat=$mesh.get_active_material(0)
@onready var explain=$explain
@onready var damage_area=$damage_area
@onready var hover_mesh=$hover_mesh
@onready var delete_area=$delete_area
var start_health=1000

func _ready() -> void:
	damage_area.initialize(start_health)
	damage_area.kill.connect(on_kill)
func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	
	if event is InputEventMouseButton and event.button_index==1 and event.is_released() and Global.current_tool==0:
		
		if Spawners.number>0:
			for i in range(0,Spawners.number):
				Global.add_player.emit(Vector3(randf_range(position.x-3,position.x+3),1,randf_range(position.z-3,position.z+3)))
			Spawners.number=0




func _process(delta: float) -> void:
	if Global.explanations:
		explain.show()
	else:
		explain.hide()
	var me=number_mesh.mesh
	me.text=str(Spawners.number)
	if Global.object_under_mouse==delete_area and Global.delete_mode=="spawner":
		if damage_area.health==start_health:
			Global.score+=1
		on_kill()
	if Global.object_under_mouse ==delete_area and Global.current_tool==1 and Global.build_mode==3:
		hover_mesh.show()
	else:
		hover_mesh.hide()

func start():
	timer.start()
	#number=20

func _on_mouse_entered() -> void:
	if Global.current_tool==0:
		mat.albedo_color=Color.from_hsv(0.61, 0.753, 1.0, 0.5)
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	mat.albedo_color=Color.from_hsv(1,0,1,0.5)
	pass # Replace with function body.

	
func on_kill():
	Global.build_destroyed.emit(position,3)
	var spa = Global.spawners.find(self)
	Global.spawners.pop_at(spa)
	queue_free()
