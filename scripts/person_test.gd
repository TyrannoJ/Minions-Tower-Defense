extends Node3D

func _process(delta: float) -> void:
	$AnimationPlayer.speed_scale=2
	$AnimationPlayer.play("Walk")
	
	#$rig/Skeleton3D/SkeletonIK3D.start()
