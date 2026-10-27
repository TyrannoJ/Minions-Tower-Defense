extends RigidBody3D

@onready var destroy_timer=$destroy_timer
@onready var mesh=$MeshInstance3D
var direction:Vector3
@onready var particles=$GPUParticles3D
@onready var damage_area=$damage_area

var timer_started=false

func instantiate(rot,strength):
	linear_velocity=Vector3.ZERO
	direction=Vector3(sin(rot),0.5,cos(rot))
	direction=direction.normalized()
	linear_velocity=direction*strength
	damage_area.scale.y=0.01
	#angular_velocity=Vector3(randf_range(-10*PI,10*PI),0,0)
	

	
func _process(delta: float) -> void:
	var bodies=get_colliding_bodies()
	damage_area.global_rotation=Vector3.ZERO
	
	
	if bodies !=[]:
		
		linear_velocity=Vector3.ZERO
		angular_velocity=Vector3.ZERO
		#set_collision_mask_value(3,false)
		if !timer_started:
			damage_area.scale.y=1
			damage_area.show()
			
			destroy_timer.start(1)
			timer_started=true
			particles.restart()
			var tween=get_tree().create_tween()
			var tween2=get_tree().create_tween()
			tween.tween_property(damage_area, "scale:x", 7, 0.4)
			tween2.tween_property(damage_area, "scale:z", 7, 0.4)
			await tween.finished
			damage_area.hide()
		mesh.hide()
		
		
		


func _on_destroy_timer_timeout() -> void:
	#print("boom")
	queue_free()


func _on_damage_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("persons"):
		if body.color == "red":
			body.get_damage(randf_range(40,60),-1)
