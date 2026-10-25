extends Node3D
@export var block:PackedScene
func _ready() -> void:
	for x in range(0,240,2):
		Global.navigation_list.append([])
		Global.navigation_block_list.append([])
		for z in range(0,140,2):
			var blo=block.instantiate()
			add_child(blo)
			blo.initialize((x/2),(z/2))
			blo.position=Vector3(x-120,2,z-70)
			Global.navigation_list[(x/2)].append(true)
			Global.navigation_block_list[(x/2)].append(blo)
