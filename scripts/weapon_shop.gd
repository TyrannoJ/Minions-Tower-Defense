extends Node3D
@export var weapon:PackedScene
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("persons"):
		var we=weapon.instantiate()
		add_child(we)
		we.position=Vector3(randf_range(-5,5),2,randf_range(-5,5))
