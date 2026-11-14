extends Area3D

func get_colliders():
	
	if get_overlapping_bodies() != []:
		print(get_overlapping_bodies())
		return true
	else:
		return false


func _on_body_entered(body: Node3D) -> void:
	#print("a")
	pass
	
#func _process(delta: float) -> void:
	#if get_overlapping_bodies() != []:
		#print(get_overlapping_bodies())
	
