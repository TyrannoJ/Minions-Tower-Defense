extends Area3D
var filled=false
var x=0
var z=0
	
	
func initialize(pos_x,pos_z):
	x=pos_x
	z=pos_z
	
	

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
	if Global.navigation_list[x][z]==false:
		$MeshInstance3D.hide()
	else:
		$MeshInstance3D	.show()
