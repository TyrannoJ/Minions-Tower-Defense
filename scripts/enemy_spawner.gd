extends Node3D

@export var enemy:PackedScene
@export var weapon:PackedScene
@onready var spawn_timer=$spawn_timer
var pos_number
func initialize(num):
	pos_number=num
func _on_spawn_timer_timeout() -> void:
	spawn_timer.start(randf_range(20,30))
	spawn_enemys()
	spawn_weapon()
func spawn_enemys():
	var enemy_number=randi_range(2,5)
	var spawn_location=Vector3(randf_range(position.x-20,position.x+20),2,randf_range(position.z-5,position.z+5))
	for i in range(0,enemy_number):
		spawn_location.x+=2
		Global.add_enemy.emit(spawn_location)
	
func spawn_weapon():
	var we=weapon.instantiate()
	add_child(we)
	we.position=Vector3(randf_range(-2,2),-2,randf_range(-2,2))
