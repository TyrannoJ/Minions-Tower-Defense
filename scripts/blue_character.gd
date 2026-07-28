extends Node3D
@onready var weapon=$rig/Skeleton3D/BoneAttachment3D/sword
@onready var animations=$AnimationPlayer
@onready var godot_animations=$AnimationPlayer2
func _process(delta: float) -> void:
	$AnimationPlayer.speed_scale=2
	$AnimationPlayer.play("Walk")
