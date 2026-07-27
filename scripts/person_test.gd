extends Node3D

func _process(delta: float) -> void:
	$AnimationPlayer.play("rig|Walk")
	#$rig/Skeleton3D/SkeletonIK3D.start()
