extends Node3D
@export var enemy_spawner:PackedScene
@onready var timer=$Timer
@export var score_number:PackedScene
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
	spa.initialize(rand,len(spawners))
	spa.killed.connect(delete_spawner)
	positions.append(spa.position)
	spawners.append(spa)
	add_child(spa)
	
func start():
	#pass
	timer.start(5)
	#var spa=enemy_spawner.instantiate()
	#
	#spa.position=Vector3(0,3,20)
	#
	#
	#spa.initialize(1,len(spawners))
	#spa.killed.connect(delete_spawner)
	#positions.append(spa.position)
	#spawners.append(spa)
	#add_child(spa)
func _on_timer_timeout() -> void:
	timer.start(randi_range(25,35))
	if len(spawners)<5:
		add_spawner()
		
func reset():
	for spa in spawners:
		spa.queue_free()
	positions=[]
	for i in range(0,len(filled)):
		filled[i]=false
	timer.start(5)
	
func delete_spawner(number):
	filled[number]=false
	var spa=spawners.pop_at(number)
	#print(number)
	var pos=possible[number]
	print(pos)
	print(number)
	var sco=score_number.instantiate()
	sco.position=Vector3(pos.x,10,pos.z)
	sco.initialize(10,Color.RED)
	add_child(sco)
	var tween=get_tree().create_tween()
	tween.tween_property(sco,"scale",Vector3(8,8,8),0.2)
	await tween.finished
	await get_tree().create_timer(0.3).timeout
	sco.queue_free()
	
