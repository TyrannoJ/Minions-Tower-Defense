extends StaticBody3D

@onready var damage_area=$area
var start_health=50
@onready var middle_mesh=$MeshInstance3D
@onready var delete_area=$delete_area
@onready var hover_mesh=$hover_mesh
@onready var attack_area=$attack_area
@onready var health_bar=$Health_bar
@onready var anti_health_bar=$anti_health_bar
@onready var delete_timer=$delete_timer
@export var damage_particles:PackedScene
var start_time=80
var damage_timer=1
var damage_val=10
var damage_particle_list=[]
func _ready() -> void:
	
	damage_area.initialize(start_health)
	damage_area.kill.connect(on_kill)
	delete_timer.start(start_time)
	
func _process(delta: float) -> void:
	
	middle_mesh.scale.y=delete_timer.time_left/start_time
	middle_mesh.position.y=(delete_timer.time_left/start_time)*2.5-2.5
	damage_timer-=delta
	damage_area.health=damage_area.health
	var sca:float=float(damage_area.health/start_health) 
	anti_health_bar.scale.x=1-sca
	health_bar.position.x=-(1-sca)
	health_bar.scale.x=sca
	anti_health_bar.position.x=sca
	middle_mesh.scale.x=damage_area.health/start_health
	middle_mesh.scale.z=damage_area.health/start_health
	if Global.object_under_mouse==delete_area and Global.delete_mode=="tower":
		Global.score+=int((delete_timer.time_left/start_time)*5)
		on_kill()
	if Global.object_under_mouse ==delete_area and Global.current_tool==1 and Global.build_mode==2:
		hover_mesh.show()
	else:
		hover_mesh.hide()
	var bodies=attack_area.get_overlapping_bodies()
	#for b:Node3D in bodies:
			#if b.is_in_group("persons"):
				#if b.color=="red": 
					##print("a")
					#var pa=damage_particles.instantiate()
					#pa.position=b.position
					#pa.position.y=0.2
					#pa.emitting=true
					#add_child(pa)
					#damage_particle_list.append(pa)
	if damage_timer<0:
		for p in damage_particle_list:
			p.queue_free()
		damage_particle_list.clear()
		bodies=attack_area.get_overlapping_bodies()
		for b:Node3D in bodies:
			if b.is_in_group("persons"):
				if b.color=="red":
					#print("a")
					b.get_damage(damage_val,-1)
					#var pa=damage_particles.instantiate()
					#pa.position=b.position
					#pa.position.y=0.2
					#pa.emitting=true
					#add_child(pa)
					#damage_particle_list.append(pa)
		damage_timer=0.5
	
func on_kill():
	Global.build_destroyed.emit(position,2)
	var to = Global.towers.find(self)
	Global.towers.pop_at(to)
	queue_free()

func _on_delete_timer_timeout() -> void:
	on_kill()
