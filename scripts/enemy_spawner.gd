extends Node3D

@export var enemy:PackedScene
@export var weapon:PackedScene
@onready var spawn_timer=$spawn_timer
func _on_spawn_timer_timeout() -> void:
	spawn_timer.start(randf_range(5,15))
	spawn_enemys()
	spawn_weapon()
func spawn_enemys():
	Global.add_enemy.emit(Vector3(randf_range(position.x-20,position.x+20),2,randf_range(position.z-5,position.z+5)))
	
func spawn_weapon():
	var we=weapon.instantiate()
	add_child(we)
	we.position=Vector3(randf_range(-2,2),-2,randf_range(-2,2))
