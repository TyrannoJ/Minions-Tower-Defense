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
var controlled=false
var loading=false
var load_value=0
var markers=[]
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
			elif event.button_index==MOUSE_BUTTON_WHEEL_DOWN:
				rotation.y-=PI/50

func _process(delta: float) -> void:
	controlled=false
	print(shot_marker.global_position.y)
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
			else:
				if load_value <20:
					for m in markers:
						m.queue_free()
					markers.clear()
					hit_marker.show()
					load_value+=5/Engine.get_frames_per_second()
					var null_point=0
					for x in range(0,1000):
						var y=4.975+float(x)/10.0 * tan(atan(0.447214*load_value/load_value))-(9.81*pow(float(x)/10.0,2)/(2*pow(load_value,2)*pow(cos(atan(0.447214*load_value/load_value)),2)))
						if x %10==0:
							var ma=marker.instantiate()
							add_child(ma)
							ma.position=Vector3(0,y,float(x)/10.0)
							markers.append(ma)
						if y<=0:
							null_point=x
							break
					hit_marker.position.z=float(null_point)/10
					
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
	hit_marker.hide()
	for m in markers:
		m.queue_free()
	markers.clear()
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
	bo.position=shot_marker.position
	bo.instantiate(rotation.y,load_value)
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
		
		
			
	


#func _on_click_mouse_entered() -> void:
	#controlled=true
#
#
#func _on_click_mouse_exited() -> void:
	#if loading:
		#fire()
	#controlled=false
