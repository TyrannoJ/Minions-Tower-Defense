extends CharacterBody3D
@export var boulder:PackedScene
@export var marker:PackedScene
@onready var shot_marker=$shot_marker
@onready var animations=$catapult/AnimationPlayer
@onready var godot_animations=$AnimationPlayer
@onready var marker_mesh=$marker
@onready var explain=$explain
@onready var damage_area=$damage_area
@onready var click_area=$click
@onready var delete_area=$delete_area
@onready var hit_marker=$hit_marker
@onready var collision_raycast=$Collision_raycast
@onready var wall_hit_marker=$wall_hit_marker
var controlled=false
var loading=false
var load_value=0
var markers=[]
var current_marker_nr=0
var highest_hit=Vector2.ZERO
var highest_hits=[]
func _ready() -> void:
	explain.position=position
	explain.position.y=5
	explain.position.z-=2
	damage_area.initialize(1000)
	damage_area.kill.connect(kill)
func _unhandled_input(event: InputEvent) -> void:
	if controlled:
		if event is InputEventMouseButton and event.is_pressed():
			if event.button_index==MOUSE_BUTTON_WHEEL_UP:
				rotation.y+=PI/50
				#make_collision_map()
				make_improved_collision_map()
			elif event.button_index==MOUSE_BUTTON_WHEEL_DOWN:
				rotation.y-=PI/50
				#make_collision_map()
				make_improved_collision_map()

func _process(delta: float) -> void:
	controlled=false
	#print(shot_marker.global_position.y)
	if click_area == Global.object_under_mouse:
		controlled=true
	else:
		controlled=false
	#print(damage_area.health)
	if Global.explanations:
		explain.show()
	else:
		explain.hide()
	
	if controlled:
		marker_mesh.show()
	else:
		marker_mesh.hide()
	if controlled:
		if Input.is_action_pressed("catapult"):#is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and controlled :
			if !loading:
				loading=true
				load_value=0
				hit_marker.position.z=0
				current_marker_nr=0
			else:
				if load_value <20:
					hit_marker.hide()
					wall_hit_marker.hide()
					for m in markers:
						m.queue_free()
					markers.clear()
					#hit_marker.show()
					load_value+=5/Engine.get_frames_per_second()*Engine.time_scale
					var null_point=0
					var y_point=0
					var wall=false
					#print(highest_hit.x)
					
					var angle=atan(0.447214/(0.89442714070866))
					#var angle=atan(1/2)
					#0.46364799328752
					#print(angle)
					for x in range(0,1000):
						var real_x=(float(x)/10.0)
						#var y=4.975+float(x)/10.0 * tan(atan(0.447214*load_value/0.89442714070866*load_value))-(9.81*pow(float(x)/10.0,2)/(2*pow(load_value,2)*pow(cos(atan(0.447214*load_value/0.89442714070866*load_value)),2)))
						var y=4.549+real_x * tan(angle)-(abs(get_gravity().y)*pow(real_x,2)/(2*pow(load_value*0.95,2)*pow(cos(angle),2)))
						if x %10==0:
							#if current_marker_nr>=len(markers):
							var ma=marker.instantiate()
							add_child(ma)
							ma.position=Vector3(0,y,real_x-0.433)
							markers.append(ma)
							
							#print(ma.get_colliders())
							#current_marker_nr+=1
						
							
							#else:
								#markers[current_marker_nr].position=Vector3(0,y,float(x)/10.0)
							#var hit_wall=false
							##print(len(markers))
							#for marker in markers:
								#if marker.get_colliders():
									#print("f")
									#null_point=x
									#hit_wall=true
									#break
							#if hit_wall:
								#break
							if y<=0:
								null_point=real_x-0.433
								#print(null_point)
								break
							#print(y)
							for hit in highest_hits:
								if y<=hit.y+0.5 and real_x-0.433>=hit.x and real_x-0.433<=hit.x+1:
									null_point=real_x-0.433
									y_point=y
									wall=true
									break
							if wall:
								break
					if !wall:
						#print(null_point)
						hit_marker.position.z=null_point
						hit_marker.global_position.y=0
						hit_marker.show()
					else:
						wall_hit_marker.position.z=null_point
						wall_hit_marker.position.y=y_point
						wall_hit_marker.show()
					
					animations.play("fire")
					animations.pause()
					animations.seek(1-load_value/20)
		if Input.is_action_just_released("catapult"):
			#loading=false
			fire()
	#print(delete_area)
	if Global.object_under_mouse==delete_area and Global.delete_mode=="catapult":
		Global.score+=10
		kill()
		

	
	
	

func go_to_start():
	animations.speed_scale=1
	animations.play_backwards("fire")

func fire():
	
	loading=false
	godot_animations.play("fire")
	godot_animations.pause()
	godot_animations.seek(1-load_value/20)
	animations.speed_scale=2
	godot_animations.speed_scale=2
	animations.play("fire")
	godot_animations.play("fire")
	await get_tree().create_timer(0.45*load_value/20).timeout
	var bo=boulder.instantiate()
	add_child(bo)
	bo.global_position=shot_marker.global_position
	bo.instantiate(rotation.y,load_value)
	bo.impact.connect(on_boulder_impact)
	go_to_start()
	await animations.animation_finished
	
func kill():
	var ca = Global.catapults.find(self)
	Global.catapults.pop_at(ca)
	queue_free()
#func _on_click_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	#if event is InputEventMouseButton and event.is_released() and event.button_index==2:
		#if loading:
			#fire()
		
		
			
func make_collision_map():
	highest_hits=[]
	var last_colliding=false
	var final_height=Vector3.ZERO
	var last_collider
	
	for i in range(0,25):
		collision_raycast.rotation.x=-PI/2*float(i)/50
		#print(rad_to_deg(collision_raycast.rotation.x))
		#print(last_colliding)
		if collision_raycast.is_colliding():
			last_collider=collision_raycast.get_collider()
			last_colliding=true
			final_height=collision_raycast.get_collision_point()
		else:
			if last_colliding:
				break
		await get_tree().physics_frame
		#await get_tree().create_timer(0.1).timeout
	#print(final_height)
	var x_val=Vector3(position.x,0,position.z).distance_to(Vector3(final_height.x,0,final_height.z))
	#print(x_val)
	highest_hit=Vector2(x_val,final_height.y)
	
	collision_raycast.add_exception(last_collider)
	highest_hits.append(highest_hit)
	
	last_colliding=false
	
	for i in range(0,25):
		collision_raycast.rotation.x=-PI/2*float(i)/50
		#print(rad_to_deg(collision_raycast.rotation.x))
		#print(last_colliding)
		if collision_raycast.is_colliding():
			last_collider=collision_raycast.get_collider()
			last_colliding=true
			final_height=collision_raycast.get_collision_point()
		else:
			if last_colliding:
				break
		await get_tree().physics_frame
		#await get_tree().create_timer(0.1).timeout
	#print(final_height)
	x_val=Vector3(position.x,0,position.z).distance_to(Vector3(final_height.x,0,final_height.z))
	#print(x_val)
	highest_hit=Vector2(x_val,final_height.y)
	
	collision_raycast.add_exception(last_collider)
	highest_hits.append(highest_hit)
	
	#print(highest_hits)
	collision_raycast.clear_exceptions()
	#print(highest_hit)
			
func make_improved_collision_map():
	highest_hits=[]
	await get_tree().physics_frame
	for i in range (0,5):
		var hit:=Vector2.ZERO
		if collision_raycast.is_colliding():
			var collider:Node3D=collision_raycast.get_collider()
			var pos=collision_raycast.get_collision_point()
			var collider_pos=collider.get_node("CollisionShape3D").global_position
			var shape=collider.get_node("CollisionShape3D").shape
			hit.y=collider_pos.y+shape.size.y/2
			hit.x=Vector3(position.x,0,position.z).distance_to(Vector3(pos.x,0,pos.z))
			#if hit.x > 70:
				#break
			highest_hit=hit
			highest_hits.append(hit)
			collision_raycast.add_exception(collider)
			await get_tree().physics_frame
		#else:
			#break
	collision_raycast.clear_exceptions()	
	print(highest_hits)
	#print(highest_hit)
	#print(highest_hits)

#func _on_click_mouse_entered() -> void:
	#controlled=true
#
#
#func _on_click_mouse_exited() -> void:
	#if loading:
		#fire()
	#controlled=false
func on_boulder_impact():
	hit_marker.hide()
	wall_hit_marker.hide()
	for m in markers:
		m.queue_free()
	markers.clear()
	
