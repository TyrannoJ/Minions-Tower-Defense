extends CharacterBody3D
@onready var vision=$Vision
var delta_v_x
var delta_v_z
var start_v_x
var start_v_z
var Speed=1
var max_speed=1
var min_speed=0.5
var color=""
var number=0
var clicked=false
var y_rot_tween
var rot_y_before
var rotating=false
var has_weapon=false
var kills=0
var unique_id=0
signal killed(color,number)
var has_killed_emitted=false
var dragged=false
var not_rotating=false
var stop=false
@onready var pathfinder=$Pathfinder
@onready var rot_timer=$Rotation_timer
@onready var weapon_red=$sword_red
@onready var weapon_blue=$sword_blue
@onready var attack_area=$attack
@onready var health_bar=$Health_bar
@onready var focused=$focused
@onready var anti_health_bar=$anti_health_bar
@onready var follow_area=$follow_area
@onready var character=$Character
var show_location=false
var pathfinding=false
var next_pos=Vector3.ZERO
var next_index=0
@export var health:float=100
var damaging=[]

func _ready() -> void:
	
	#Engine.time_scale=0.2
	rotation.y=deg_to_rad(randf_range(-180,180))
	velocity+=-global_transform.basis.z
	Global.update_target.connect(on_update_target)

func initialize():
	
	if color=="blue":
		character.make_blue()
	else:
		
		character.make_red()
		
func _physics_process(delta: float) -> void:
	
	
	if color=="blue" and has_weapon:
		vision.set_collision_mask_value(6,true)
		
	else:
		vision.set_collision_mask_value(6,false)
		
	follow_area.color=color
	
	attack_players()
	follow_mouse()
	show_attributes()
	pathfinder.player_position=position
	move()
	if rotation.y==rot_y_before:
		rotating=false
	else:
		rotating=true
	
	
	
		
	handle_collisions()
	
	velocity.x=0
	velocity.z=0
	velocity+=-global_transform.basis.z*Speed
	move_and_slide()
	rot_y_before=rotation.y
	
func move():
	speed()
	
	if pathfinding:
		handle_pathfinding()
	else:
		direction()
	
	
func direction():
	
	follow_persons()
	if not_rotating:
		if !pathfinding and !vision.is_colliding() and !dragged:
			not_rotating=false
			change_rotation()
			rot_timer.start(1)
			
			
	if color=="blue":
		
		if Global.attack_on_base and has_weapon and !clicked:
			if Global.red_coords !=[]:
				walk_to(find_closest_enemy())
				
				
	elif color=="red":
		if  has_weapon:#!vision.is_colliding() and
			look_at(Global.base)
			rotation.z=0
			rotation.x=0
		

func speed():
	if Speed>=min_speed:
		if Speed>=max_speed:
			Speed-=0.1
		Speed+=randf_range(-0.05,0.05)
	else:
		Speed+=0.2
	if stop:
		Speed=0
		velocity=Vector3.ZERO
	character.animations.speed_scale=Speed*4
	
func handle_collisions():
	for index in range(get_slide_collision_count()):
		
		var collision = get_slide_collision(index)
		if collision.get_collider() == null:
			continue
		else:
			if pathfinding:
				look_at(next_pos)
				

	
	
func random_movement():
	speed()
	
func follow_persons():
	if vision.is_colliding():
		var collider=vision.get_collider()
		if collider !=null:
			if vision.get_collider().is_in_group("persons") : 
				if has_weapon:
					if vision.get_collider().color !=color:
						look_at(collider.global_position)
						rotation.x=0
						rotation.z=0
			elif !collider.is_in_group("base"):
				
				rotate_to_Vector(Vector2(vision.get_collision_normal().x,vision.get_collision_normal().z))
	
func handle_pathfinding():
	if next_pos != Vector3.ZERO:
		look_at(next_pos)
	if (pathfinder.positions!=[] and check_proximity(next_pos)) or (pathfinder.positions!=[] and next_index==0):
		
		if next_index==len(pathfinder.positions):
			end_pathfinding()
			
			#Global.target_positions_blue=[]
		else:
			
			next_pos=pathfinder.positions[next_index]
			look_at(next_pos)
			
			rotation.x=0
			rotation.z=0
			stop=false
			if next_index <len(pathfinder.markers):
				pathfinder.markers[next_index].queue_free()
			next_index+=1
func show_attributes():
	if Global.show_health and color=="blue":
		health_bar.show()
		anti_health_bar.show()
	else:
		health_bar.hide()
		anti_health_bar.hide()
	if $"."==Global.focused:
		focused.show()
	else:
		focused.hide()
		
	
	if clicked:
		$clicked.show()
	else:
		$clicked.hide()
func change_rotation():
	
	rotate_smooth(randf_range(-30,30))
	$Rotation_timer.start(randf_range(0.1,0.3))

func _on_rotation_timer_timeout() -> void:
	change_rotation()
	if !pathfinding and !vision.is_colliding() and !dragged:
		rot_timer.start(1)
		
	else:
		not_rotating=true
	#print(rad_to_deg(Vector2(-1,0).angle()))
	#print(velocity)
	
	#print(rad_to_deg(rotation.y))

func on_update_target(col,num):
	var in_list=false
	for i in range(0,len(col)):
		if col[i]==color and num[i]==number:
			in_list=true
			break
			
	if in_list:
		
		pathfinder.start_pathfinding()
		end_pathfinding()
		rot_timer.paused=true
		pathfinding=true
		stop=true
		
	#look_at(Global.target_pos)
	#rotation.x=0
	#rotation.z=0
func check_proximity(pos:Vector3):
	
	if position.x>=pos.x-0.5 and position.x<=pos.x+0.5 and position.z>=pos.z-0.5 and position.z<=pos.z+0.5:
		return true
		
	else:
		return false

func end_pathfinding():
	for ma in pathfinder.markers:
		if ma != null:
			ma.queue_free()
	pathfinder.markers.clear()
	rotation.y+=randi_range(-90,90)
	pathfinding=false
	next_index=0
	next_pos=Vector3.ZERO
	velocity=Vector3.ZERO
	#print("finished")
	rot_timer.paused=false
func _on_click_check_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_released() and event.button_index==3 and Global.current_tool==0:
		if color=="blue":
			Global.clicked.emit(color,number)
		if !clicked:
			if color=="blue":
				clicked=true
		else:
			clicked=false
			Global.focused=null
		#if event.button_index==0 and event.pressed==true:
func rotate_smooth(deg):
	#if y_rot_tween.is_running():
	if !rotating:
		#print("a")
		y_rot_tween=get_tree().create_tween()
		y_rot_tween.tween_property($".", "rotation:y", rotation.y+deg_to_rad(deg), 0.2)
	#y_rot_tween.tween_callback($".".queue_free)
		
func rotate_to_Vector(vec:Vector2):
	vec.x=-vec.x
	var ang=vec.angle()
	
	#if y_rot_tween.is_running():
	if !rotating:
		
		y_rot_tween=get_tree().create_tween()
		y_rot_tween.tween_property($".", "rotation:y", ang+PI/2, 0.2)
	#y_rot_tween.tween_callback($".".queue_free)


func _on_follow_area_area_entered(area: Area3D) -> void:
	
	if area.is_in_group("weapons") and !has_weapon:
		has_weapon=true
		
		character.godot_animations.play("grab")
		
		area.queue_free()


func attack_players():
	damaging=attack_area.get_overlapping_bodies()
	
	if damaging !=[]:
		for da in damaging:
			if da.is_in_group("persons") and has_weapon:
				if da.color != color:
					
					character.godot_animations.play("hit")
					
					da.get_damage(1,unique_id)
			
	damaging=attack_area.get_overlapping_areas()
	if damaging !=[]:
		for da in damaging:
			
			if da.is_in_group("targets") and color=="red" and has_weapon:
				show_location=true
				character.godot_animations.play("hit")
				da.get_damage(1)
					
func get_damage(val,attacker):
	health-=val
	if health <=0:
		if !has_killed_emitted:
			killed.emit(color,number,attacker)
			has_killed_emitted=true
		
	var sca:float=float(health/100)
	var mat := health_bar.material_override as ShaderMaterial
	mat.set_shader_parameter("Interpolation", health)

	anti_health_bar.scale.x=1-sca
	health_bar.position.x=-(1-sca)
	health_bar.scale.x=sca
	#anti_health_bar.position.x=1-sca
func handle_enemy():
	
	speed()
	follow_persons()
	if  has_weapon:#!vision.is_colliding() and
		look_at(Global.base)
		rotation.z=0
		rotation.x=0
func follow_mouse():
	if clicked and Global.current_tool==0 and Global.dragging:
		dragged=true
		walk_to(Global.drag_pos)
		rotation.x=0
		rotation.z=0
	else:
		dragged=false
func find_closest_enemy():
	var distances=[]
	for pos in Global.red_coords:
		distances.append(get_distance(position,pos))
	var result=distances.min()
	var final_result=distances.find(result)
	return(Global.red_coords[final_result])
func get_distance(from:Vector3,to:Vector3):
	var x=abs(from.x-to.x)
	var z=abs(from.z-to.z)
	var dist=sqrt(pow(x,2)+pow(z,2))
	return(dist)
	
func walk_to(location:Vector3):
	if vision.is_colliding() and vision.get_collider() !=null:
		if vision.get_collider().is_in_group("obstacles"):
			rotate_to_vector_better(Vector3(-vision.get_collision_normal().z,vision.get_collision_normal().y,vision.get_collision_normal().x))
			
	else:
		
		look_at(location)
		rotation.x=0
		rotation.z=0
		
func rotate_to_vector_better(vector:Vector3):
	var vec=Vector2(vector.x,vector.z)
	vec.x=-vec.x
	var ang=vec.angle()
	
	#if y_rot_tween.is_running():
	if !rotating:
		
		y_rot_tween=get_tree().create_tween()
		y_rot_tween.tween_property($".", "rotation:y", ang+PI/2, 0.2)
	#y_rot_tween.tween_callback($".".queue_free)
