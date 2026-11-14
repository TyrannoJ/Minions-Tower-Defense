extends StaticBody3D
@onready var area=$area
var start_health:float=1000
@onready var animations=$wall_animated/AnimationPlayer
@onready var col=$CollisionShape3D
func _ready() -> void:
	area.kill.connect(kill)
	
	animations.current_animation="crumble"
		
	animations.pause()
		#$wall_animated/AnimationPlayer.seek(3.3,true)
		
func kill():
	col.disabled=true
	area.queue_free()
	queue_free()

func _process(delta: float) -> void:
	
	if has_node("area"):
		if area.health !=start_health:
			animations.play("crumble")
			#print(3.3*(area.health/start_health-1))
			animations.pause()
			#print(animations.current_animation)
			var anim_health=int(area.health/100)*100
			animations.seek(3.3*abs(anim_health/start_health-1),true)
		
	
