extends StaticBody3D
@export var fence_extension:PackedScene
@onready var damage_area=$area
var start_health=50
@onready var middle_mesh=$MeshInstance3D
@onready var delete_area=$delete_area
func _ready() -> void:
	Global.fence_built.connect(check_fence_proximity)
	damage_area.initialize(start_health)
	damage_area.kill.connect(on_kill)
	
func check_fence_proximity(pos):
	if pos.x==position.x:
		#print("a")
		if pos.z==position.z-2:
			#print("1")
			var fe=fence_extension.instantiate()
			add_child(fe)
			fe.position.z=-1
			fe.rotation.y=PI/2
		if pos.z==position.z+2:
			#print("2")
			var fe=fence_extension.instantiate()
			add_child(fe)
			fe.position.z=1
			fe.rotation.y=PI/2
	if pos.z==position.z:
		#print("b")
		if pos.x==position.x-2:
			#print("3")
			var fe=fence_extension.instantiate()
			add_child(fe)
			fe.position.x=-1
			
		if pos.x==position.x+2:
			#print("4")
			var fe=fence_extension.instantiate()
			add_child(fe)
			fe.position.x=1

func _process(delta: float) -> void:
	middle_mesh.scale.x=damage_area.health/start_health
	middle_mesh.scale.z=damage_area.health/start_health
	if Global.object_under_mouse==delete_area and Global.delete_mode=="fence":
		Global.score+=1
		on_kill()
func on_kill():
	var fe = Global.fences.find(self)
	Global.fences.pop_at(fe)
	queue_free()
			
	
