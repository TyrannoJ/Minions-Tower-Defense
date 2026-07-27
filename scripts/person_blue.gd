extends CharacterBody3D
@onready var vision=$Vision
var delta_v_x
var delta_v_z
var start_v_x
var start_v_z
var Speed=2.5
var number=0
var color="blue"
@onready var pathfinder=$Pathfinder
var pathfinding=false
var next_pos=Vector3.ZERO
var next_index=0
func _ready() -> void:
	#Engine.time_scale=0.2
	rotation.y=deg_to_rad(randf_range(-180,180))
	velocity+=-global_transform.basis.z
	Global.update_target.connect(on_update_target)
func _physics_process(delta: float) -> void:
	#velocity.y+=get_gravity().y*delta
	
	pathfinder.player_position=position
	if pathfinding:
		
		if (pathfinder.positions!=[] and check_proximity(next_pos)) or (pathfinder.positions!=[] and next_index==0):
			
			if next_index==len(pathfinder.positions):
				
				pathfinding=false
				next_index=0
				velocity=Vector3.ZERO
				
				#Global.target_positions_blue=[]
			else:
				
				next_pos=pathfinder.positions[next_index]
				look_at(next_pos)
				rotation.x=0
				rotation.z=0
				Speed=7
				next_index+=1
	else:
		pass
		
	
	if !pathfinding:
		if Speed>=3:
			if Speed>=10:
				Speed-=0.3
			Speed+=randf_range(-0.1,0.1)
		else:
			Speed+=0.5
		if vision.is_colliding():
			if vision.get_collider().is_in_group("walls"):
				
				var tween = get_tree().create_tween()
				tween.tween_property($".", "rotation:y", rotation.y+deg_to_rad(90), 0.2)
	velocity.x=0
	velocity.z=0
	velocity+=-global_transform.basis.z*Speed
	move_and_slide()

func change_rotation():
	var tween = get_tree().create_tween()
	tween.tween_property($".", "rotation:y", rotation.y+deg_to_rad(randf_range(-30,30)), 0.2)
	
	$Rotation_timer.start(randf_range(0.1,0.3))

func _on_rotation_timer_timeout() -> void:
	change_rotation()

func on_update_target():
	pathfinding=true
	Speed=0
	velocity=Vector3.ZERO
	#look_at(Global.target_pos)
	#rotation.x=0
	#rotation.z=0
func check_proximity(pos:Vector3):
	
	if position.x>=pos.x-0.5 and position.x<=pos.x+0.5 and position.z>=pos.z-0.5 and position.z<=pos.z+0.5:
		return true
		
	else:
		return false
