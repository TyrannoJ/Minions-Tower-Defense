extends Node3D

@export var enemy:PackedScene
@export var weapon:PackedScene
@onready var spawn_timer=$spawn_timer
@onready var damage_area=$area
@onready var health_bar=$Health_bar
@onready var anti_health_bar=$anti_health_bar
signal killed(number)
var pos_number
var number
var health=2000
func _ready() -> void:
	damage_area.kill.connect(kill)
func initialize(pos,num):
	pos_number=pos
	number=num
	
func _on_spawn_timer_timeout() -> void:
	spawn_timer.start(randf_range(25,35))
	spawn_enemys()
	#spawn_weapon()
func spawn_enemys():
	if Global.enemy_number<Global.MAX_ENEMYS:
		var enemy_number=randi_range(2,4)
		var spawn_location=Vector3(randf_range(position.x-20,position.x+20),2,randf_range(position.z-5,position.z+5))
		for i in range(0,enemy_number):
			spawn_location.x+=2
			Global.add_enemy.emit(spawn_location)
func _process(delta: float) -> void:
	health=damage_area.health
	#print(health)
	var sca:float=float(health/2000)
	
	anti_health_bar.scale.x=1-sca
	health_bar.position.x=-(1-sca)
	health_bar.scale.x=sca
	
	anti_health_bar.position.x=sca
func spawn_weapon():
	var we=weapon.instantiate()
	add_child(we)
	we.position=Vector3(randf_range(-2,2),-2,randf_range(-2,2))
func kill():
	Global.score+=10
	killed.emit(number)
	queue_free()
