extends Area3D
var filled=false
var x=0
var z=0
#@onready var mesh_instance:MeshInstance3D =$MeshInstance3D2


	#mesh_instance.mesh=mesh_instance.mesh.duplicate()
func initialize(pos_x,pos_z):
	x=pos_x
	z=pos_z
	#if -10<x and x<20 and -10<z and z<20:
		#var mesh2:=mesh_instance.mesh as TextMesh
		#mesh2.text=str(x)+ " , " + str(z)
func _on_timer_timeout() -> void:
	if has_overlapping_bodies():
		filled=true
		#print(x)
		#print(Global.navigation_list[x])
		Global.navigation_list[x][z]=false
	else:
		filled=false
		#print(x)
		#print(Global.navigation_list[x])
		Global.navigation_list[x][z]=true
	if filled:
		#pass
		$MeshInstance3D.show()
		
func request():
	if has_overlapping_bodies():
		filled=true
	else:
		filled=false
		
	#$MeshInstance3D.show()
	#print("______")
	#print(x)
	#print(z)
	#print("_______")
	#$Timer2.start(0.05)
	
	return filled


func _on_timer_2_timeout() -> void:
	$MeshInstance3D.hide()
