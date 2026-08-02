extends Area3D
var health:float=8000
var has_killed_emitted=false
signal base_killed
var start_health=8000
@onready var health_bar=$Health_bar
@onready var anti_health_bar=$anti_health_bar
@onready var rescue_timer=$rescue_timer
@export var wall:PackedScene
@export var wall_edge:PackedScene
func _ready() -> void:
	for x in range(-8,10,2):
		for z in range(-8,10,2):
			if abs(x)==8 and abs(z)==8:
				var wa=wall_edge.instantiate()
				add_child(wa)
				wa.position=Vector3(x,-1,z)
				if x==-8 and z==-8:
					wa.rotation.y=PI/2
				elif x==8 and z==-8:
					wa.rotation.y=0
				elif x==8 and z==8:
					wa.rotation.y=-PI/2
				elif x==-8 and z==8:
					wa.rotation.y=PI
			elif abs(x)==8 and abs(z)!=8:
				var wa=wall.instantiate()
				add_child(wa)
				wa.position=Vector3(x,-1,z)
				if x==8:
					wa.rotation.y=PI/2
				elif x==-8:
					wa.rotation.y=-PI/2
			elif abs(x)!=8 and abs(z)==8:
				var wa=wall.instantiate()
				add_child(wa)
				wa.position=Vector3(x,-1,z)
				if z==8:
					wa.rotation.y=0
				elif z==-8:
					wa.rotation.y=PI
func get_damage(val):
	health-=val
	rescue_timer.start(5)
	Global.attack_on_base=true
	
	if health <=0:
		if !has_killed_emitted:
			
			
			base_killed.emit()
			has_killed_emitted=true
	var sca:float=float(health/start_health)
	
	anti_health_bar.scale.x=1-sca
	health_bar.position.x=-(1-sca)
	health_bar.scale.x=sca
	
	anti_health_bar.position.x=sca


func _on_rescue_timer_timeout() -> void:
	Global.attack_on_base=false
