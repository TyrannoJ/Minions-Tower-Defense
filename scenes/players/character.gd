extends Node3D
@onready var weapon=$rig/Skeleton3D/BoneAttachment3D/sword
@onready var animations=$AnimationPlayer
@onready var godot_animations=$AnimationPlayer2
@onready var mat:StandardMaterial3D=$rig/Skeleton3D/Cube.get_surface_override_material(1).duplicate()
@onready var mat2:ShaderMaterial=$rig/Skeleton3D/BoneAttachment3D/sword/Plane.get_surface_override_material(0).duplicate()
@onready var mat3:ShaderMaterial=$rig/Skeleton3D/BoneAttachment3D/sword/Plane.get_surface_override_material(2).duplicate()
@onready var mat4:=$rig/Skeleton3D/Cube.get_surface_override_material(0).duplicate()  as StandardMaterial3D
@onready var mat5:=$rig/Skeleton3D/Cube.get_surface_override_material(2).duplicate() as StandardMaterial3D
@onready var sword_mesh=$rig/Skeleton3D/BoneAttachment3D/sword/Plane
@onready var person_mesh=$rig/Skeleton3D/Cube
var color=""
var wait_till_normal=0
func _process(delta: float) -> void:
	#$AnimationPlayer.speed_scale=2
	#$AnimationPlayer.play("Walk")
	#get_damage()
	#print(color)
	wait_till_normal-=delta
	if wait_till_normal <=0:
		mat4.albedo_color=Color("4d4344")
		mat5.albedo_color=Color("e77224")
		
		if color=="blue":
			mat.albedo_color=  Color(0.0, 0.067, 1.0, 1.0)
		elif color=="red":
			mat.albedo_color= Color(1.0, 0.0, 0.0, 1.0)
	sword_mesh.set_surface_override_material(0,mat2)
	sword_mesh.set_surface_override_material(2,mat3)
	person_mesh.set_surface_override_material(1,mat)
	person_mesh.set_surface_override_material(0,mat4)
	person_mesh.set_surface_override_material(2,mat5)
	
#Head #E77224FF
#Torso #4D4344FF
	
func make_red():
	mat.albedo_color= Color(1.0, 0.0, 0.0, 1.0)
	mat2.set_shader_parameter("Color", Color(1.0, 0.0, 0.0, 1.0))  # red
	mat3.set_shader_parameter("Color", Color(1.0, 0.0, 0.0, 1.0))  # red
	color="red"
	
func make_blue():
	mat.albedo_color= Color(1.0, 0.0, 0.0, 1.0)
	mat2.set_shader_parameter("Color", Color(0.0, 0.067, 1.0, 1.0))  # red
	mat3.set_shader_parameter("Color", Color(0.0, 0.067, 1.0, 1.0))  # red
	#get_damage()
	color="blue"
func get_damage():
	var col=Color()
	if color=="blue":
		col=Color(1.825, 0.0, 0.063, 1.0)
	if color=="red":
		col=Color(1.765, 0.0, 1.825, 1.0)
	mat.albedo_color=col
	mat4.albedo_color=col
	mat5.albedo_color=col
	wait_till_normal=0.3
	
		
	
