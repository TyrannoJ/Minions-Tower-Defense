extends StaticBody3D
@export var fence_extension:PackedScene
func _ready() -> void:
	Global.fence_built.connect(check_fence_proximity)
	
	
func check_fence_proximity(pos):
	if pos.x==position.x:
		print("a")
		if pos.z==position.z-2:
			print("1")
			var fe=fence_extension.instantiate()
			add_child(fe)
			fe.position.z=-1
			fe.rotation.y=PI/2
		if pos.z==position.z+2:
			print("2")
			var fe=fence_extension.instantiate()
			add_child(fe)
			fe.position.z=1
			fe.rotation.y=PI/2
	if pos.z==position.z:
		print("b")
		if pos.x==position.x-2:
			print("3")
			var fe=fence_extension.instantiate()
			add_child(fe)
			fe.position.x=-1
			
		if pos.x==position.x+2:
			print("4")
			var fe=fence_extension.instantiate()
			add_child(fe)
			fe.position.x=1
			
	
