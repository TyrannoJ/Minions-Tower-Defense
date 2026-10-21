extends Node3D
@export var enemy_spawner:PackedScene
@onready var timer=$Timer
var grace_area=30
var positions=[]
var spawner_size=15
var possible=[]
var filled=[]
var spawners=[]
func _ready() -> void:
	for x in range(-100,100,10):
		for y in range(-60,60,10):
			if (grace_area<x or x<-grace_area) and (grace_area<y or y<-grace_area):
				possible.append(Vector3(x,3,y))
				filled.append(false)
func add_spawner():
	var spa=enemy_spawner.instantiate()
	var rand=0
	while true:
		rand=randi_range(0,len(possible)-1)
		if !filled[rand]:
			break
	spa.position=possible[rand]
	
	filled[rand]=true
	spa.initialize(rand)
	positions.append(spa.position)
	spawners.append(spa)
	add_child(spa)
	


func _on_timer_timeout() -> void:
	timer.start(randi_range(20,25))
	if len(spawners)<6:
		add_spawner()
		
func reset():
	for spa in spawners:
		spa.queue_free()
	positions=[]
	for i in range(0,len(filled)):
		filled[i]=false
