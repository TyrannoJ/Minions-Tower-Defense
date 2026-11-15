extends StaticBody3D
@export var fence_extension:PackedScene
@onready var damage_area=$area
var start_health=50
@onready var middle_mesh=$MeshInstance3D
@onready var delete_area=$delete_area
@onready var hover_mesh=$hover_mesh

func _ready() -> void:
	
	damage_area.initialize(start_health)
	damage_area.kill.connect(on_kill)
	
	
func _process(delta: float) -> void:
	middle_mesh.scale.x=damage_area.health/start_health
	middle_mesh.scale.z=damage_area.health/start_health
	if Global.object_under_mouse==delete_area and Global.delete_mode=="tower":
		Global.score+=5
		on_kill()
	if Global.object_under_mouse ==delete_area and Global.current_tool==1 and Global.build_mode==2:
		hover_mesh.show()
	else:
		hover_mesh.hide()
func on_kill():
	var to = Global.towers.find(self)
	Global.towers.pop_at(to)
	queue_free()
