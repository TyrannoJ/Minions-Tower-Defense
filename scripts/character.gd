extends Node3D
@onready var weapon=$rig/Skeleton3D/BoneAttachment3D/sword
@onready var animations=$AnimationPlayer
@onready var godot_animations=$AnimationPlayer2
@onready var mat:ShaderMaterial=$rig/Skeleton3D/Cube.get_surface_override_material(1)
@onready var mat2:ShaderMaterial=$rig/Skeleton3D/BoneAttachment3D/sword/Plane.get_surface_override_material(0)
@onready var mat3:ShaderMaterial=$rig/Skeleton3D/BoneAttachment3D/sword/Plane.get_surface_override_material(2)
func _process(delta: float) -> void:
	#$AnimationPlayer.speed_scale=2
	$AnimationPlayer.play("Walk")
	
	
	
func make_red():
	mat.set_shader_parameter("Color", Color(1.0, 0.0, 0.0, 1.0))  # red
	mat2.set_shader_parameter("Color", Color(1.0, 0.0, 0.0, 1.0))  # red
	mat3.set_shader_parameter("Color", Color(1.0, 0.0, 0.0, 1.0))  # red
	
func make_blue():
	mat.set_shader_parameter("Color", Color(0.0, 0.067, 1.0, 1.0))  # red
	mat2.set_shader_parameter("Color", Color(0.0, 0.067, 1.0, 1.0))  # red
	mat3.set_shader_parameter("Color", Color(0.0, 0.067, 1.0, 1.0))  # red
	
