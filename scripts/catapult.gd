extends CharacterBody3D
@export var boulder:PackedScene
@onready var shot_marker=$shot_marker
@onready var animations=$catapult/AnimationPlayer
@onready var godot_animations=$AnimationPlayer
@onready var marker_mesh=$marker
@onready var explain=$explain
var controlled=false
var loading=false
var load_value=0
func _ready() -> void:
	explain.position=position
	explain.position.y=5
	explain.position.z-=2
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index==MOUSE_BUTTON_WHEEL_UP:
			rotation.y+=PI/50
		elif event.button_index==MOUSE_BUTTON_WHEEL_DOWN:
			rotation.y-=PI/50

func _process(delta: float) -> void:
	if Global.explanations:
		explain.show()
	else:
		explain.hide()
	
	if controlled:
		marker_mesh.show()
	else:
		marker_mesh.hide()
	if Input.is_action_pressed("catapult"):#is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and controlled :
		if !loading:
			loading=true
			load_value=0
		else:
			if load_value <20:
				load_value+=5/Engine.get_frames_per_second()
				animations.play("fire")
				animations.pause()
				animations.seek(1-load_value/20)
	if Input.is_action_just_released("catapult"):
		#loading=false
		fire()


	
	
	

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
	bo.position=shot_marker.position
	bo.instantiate(rotation.y,load_value)
	go_to_start()
	await animations.animation_finished
	

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
